/// range that we can remove labels when we click near them with the removal tool
#define LABEL_REMOVE_RANGE 20
#define MINIMAP_DRAW_OFFSET 8

/// Action that lets you draw on a minimap
/datum/action/minimap/map_drawing
	name = "Toggle Minimap Drawing"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "minimap_drawing"
	/// List of references to the tools we will be using to shape what the map looks like
	var/list/atom/movable/screen/drawing_tools = list(
		/atom/movable/screen/minimap_tool/draw_tool/red,
		/atom/movable/screen/minimap_tool/draw_tool/yellow,
		/atom/movable/screen/minimap_tool/draw_tool/purple,
		/atom/movable/screen/minimap_tool/draw_tool/blue,
		/atom/movable/screen/minimap_tool/draw_tool/erase,
		/atom/movable/screen/minimap_tool/label,
		/atom/movable/screen/minimap_tool/clear,
	)

/datum/action/minimap/map_drawing/Destroy()
	QDEL_LIST(drawing_tools)
	return ..()

/datum/action/minimap/map_drawing/Grant(mob/grant_to)
	. = ..()
	var/list/atom/movable/screen/actions = list()
	for(var/path in drawing_tools)
		actions += new path(FALSE, grant_to, current_z_shown, my_map)
	drawing_tools = actions

/datum/action/minimap/map_drawing/toggle_minimap(force_state)
	. = ..()
	if(minimap_displayed)
		owner.client.screen += drawing_tools
		return
	owner.client.screen -= drawing_tools

/atom/movable/screen/minimap_tool
	icon = 'icons/ui_icons/minimap/minimap_buttons.dmi'
	///x offset of the minimap icon for this zlevel. mostly used for shorthand
	var/x_offset
	///y offset of the minimap icon for this zlevel. mostly used for shorthand
	var/y_offset
	///zlevel that this minimap tool applies to and which it will be drawing on
	var/zlevel
	/// active mouse icon when the tool is selected
	var/active_mouse_icon
	/// the minimap that this tool will be drawing on
	var/datum/tactical_map/my_map
	/// reference to the icon we are manipulating when drawing, fetched during initialize
	var/image/drawn_image

/atom/movable/screen/minimap_tool/Initialize(mapload, datum/hud/hud_owner, zlevel, datum/tactical_map/map)
	. = ..()
	my_map = map
	src.zlevel = zlevel
	if(my_map)
		set_zlevel(zlevel)
		return
	LAZYADDASSOC(my_map.earlyadds, "[zlevel]", CALLBACK(src, PROC_REF(set_zlevel), zlevel))

///Setter for the offsets of the x and y of drawing based on the input z, and the drawn_image
/atom/movable/screen/minimap_tool/proc/set_zlevel(zlevel)
	x_offset = my_map.minimaps_by_z["[zlevel]"].x_offset
	y_offset = my_map.minimaps_by_z["[zlevel]"].y_offset
	drawn_image = my_map.get_drawing_image(zlevel, my_map.minimap_flags)

/atom/movable/screen/minimap_tool/MouseEntered(location, control, params)
	. = ..()
	add_filter("mouseover", 1, outline_filter(1, COLOR_LIME))
	if(desc)
		openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/minimap_tool/MouseExited(location, control, params)
	. = ..()
	remove_filter("mouseover")
	if(desc)
		closeToolTip(usr)

/atom/movable/screen/minimap_tool/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == LEFT_CLICK)
		RegisterSignal(usr.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mousedown))
		usr.client.mouse_pointer_icon = active_mouse_icon
		my_map?.updator_add(drawn_image, my_map.minimap_flags)

/**
 * handles actions when the mouse is held down while the tool is active.
 */
/atom/movable/screen/minimap_tool/proc/on_mousedown(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(!(src in source.screen))
		UnregisterSignal(source, COMSIG_CLIENT_MOUSEDOWN)
		source.mouse_pointer_icon = null
		return FALSE
	if(istype(object, /atom/movable/screen/minimap_tool))
		UnregisterSignal(usr.client, COMSIG_CLIENT_MOUSEDOWN)
		usr.client.mouse_pointer_icon = null
		return FALSE
	return TRUE

/atom/movable/screen/minimap_tool/draw_tool
	icon_state = "draw"
	desc = "Draw using a color. Drag to draw a line, right click to place a dot. Right click this button to unselect."
	// color that this draw tool will be drawing in
	color = COLOR_PINK
	///last thing this tool has drawn, stored so it can be reverted with right click
	var/list/last_drawn
	///temporary existing list used to calculate a line between the start of a click and the end of a click
	var/list/starting_coords

/atom/movable/screen/minimap_tool/draw_tool/Click(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == RIGHT_CLICK && last_drawn)
		last_drawn += list(null)
		draw_line(arglist(last_drawn))
		last_drawn = null
		log_minimap_drawing("[key_name(usr)] undid the last [color] line")

/atom/movable/screen/minimap_tool/draw_tool/on_mousedown(client/source, atom/object, location, control, params)
	. = ..()
	if(!.)
		return
	var/list/modifiers = params2list(params)
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	if(modifiers[BUTTON] == RIGHT_CLICK)
		var/icon/mona_lisa = icon(drawn_image.icon)
		pixel_coords = list(pixel_coords[1]-MINIMAP_DRAW_OFFSET, pixel_coords[2]+MINIMAP_DRAW_OFFSET)
		mona_lisa.DrawBox(color, pixel_coords[1], pixel_coords[2], ++pixel_coords[1], ++pixel_coords[2])
		drawn_image.icon = mona_lisa
		log_minimap_drawing("[key_name(source)] has made a dot at [pixel_coords[1]/2], [pixel_coords[2]/2]")
		my_map.process()
		return TRUE
	starting_coords = pixel_coords
	RegisterSignal(source, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouseup))
	return TRUE

///Called when the mouse is released again to finish the drag-draw
/atom/movable/screen/minimap_tool/draw_tool/proc/on_mouseup(client/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_CLIENT_MOUSEUP)
	var/list/modifiers = params2list(params)
	var/list/end_coords = params2screenpixel(modifiers["screen-loc"])
	draw_line(starting_coords, end_coords)
	last_drawn = list(starting_coords, end_coords)
	log_minimap_drawing("[key_name(usr)] drew a [color] line from [starting_coords[1]], [starting_coords[2]] to [end_coords[1]], [end_coords[2]]")
	my_map.process()

/// proc for drawing a line from list(startx, starty) to list(endx, endy) on the screen. yes this is aa ripoff of [/proc/getline]
/atom/movable/screen/minimap_tool/draw_tool/proc/draw_line(list/start_coords, list/end_coords, draw_color = color)
	// converts these into the unscaled minimap version so we have to do less calculating
	var/halved_offset = MINIMAP_DRAW_OFFSET/2
	var/start_x = FLOOR(start_coords[1]/2, 1) - halved_offset
	var/start_y = FLOOR(start_coords[2]/2, 1) + halved_offset
	var/end_x = FLOOR(end_coords[1]/2, 1) - halved_offset
	var/end_y = FLOOR(end_coords[2]/2, 1) + halved_offset
	var/icon/mona_lisa = icon(drawn_image.icon)

	//special case 1, straight line
	if(start_x == end_x)
		mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, end_y*2 + 1)
		drawn_image.icon = mona_lisa
		return
	if(start_y == end_y)
		drawn_image.icon = mona_lisa
		mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, end_x*2 + 1, start_y*2 + 1)
		return

	mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)

	var/abs_dx = abs(end_x - start_x)
	var/abs_dy = abs(end_y - start_y)
	var/sign_dx = SIGN(end_x - start_x)
	var/sign_dy = SIGN(end_y - start_y)

	//special case 2, perfectly diagonal line
	if(abs_dx == abs_dy)
		for(var/j = 1 to abs_dx)
			start_x += sign_dx
			start_y += sign_dy
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
		drawn_image.icon = mona_lisa
		return

	/*x_error and y_error represents how far we are from the ideal line.
	Initialized so that we will check these errors against 0, instead of 0.5 * abs_(dx/dy)*/
	//We multiply every check by the line slope denominator so that we only handles integers
	if(abs_dx > abs_dy)
		var/y_error = -(abs_dx >> 1)
		var/steps = abs_dx
		while(steps--)
			y_error += abs_dy
			if(y_error > 0)
				y_error -= abs_dx
				start_y += sign_dy
			start_x += sign_dx
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
	else
		var/x_error = -(abs_dy >> 1)
		var/steps = abs_dy
		while(steps--)
			x_error += abs_dx
			if(x_error > 0)
				x_error -= abs_dy
				start_x += sign_dx
			start_y += sign_dy
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
	drawn_image.icon = mona_lisa

/atom/movable/screen/minimap_tool/draw_tool/red
	screen_loc = "16,14"
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_red.dmi'
	color = TACMAP_DRAWING_RED

/atom/movable/screen/minimap_tool/draw_tool/yellow
	screen_loc = "16,13"
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_yellow.dmi'
	color = TACMAP_DRAWING_YELLOW

/atom/movable/screen/minimap_tool/draw_tool/purple
	screen_loc = "16,12"
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_purple.dmi'
	color = TACMAP_DRAWING_PURPLE

/atom/movable/screen/minimap_tool/draw_tool/blue
	screen_loc = "16,11"
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_blue.dmi'
	color = TACMAP_DRAWING_BLUE

/atom/movable/screen/minimap_tool/draw_tool/erase
	icon_state = "erase"
	desc = "Drag to erase a line, right click to erase a dot. Right click this button to unselect."
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_erase.dmi'
	screen_loc = "16,10"
	color = null

/atom/movable/screen/minimap_tool/label
	icon_state = "label"
	desc = "Click to place a label. Rightclick a label to remove it. Right click this button to remove all labels."
	active_mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/label.dmi'
	screen_loc = "16,8"
	/// List of turfs that have labels attached to them. kept around so it can be cleared
	var/list/turf/labelled_turfs = list()

/atom/movable/screen/minimap_tool/label/Click(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == RIGHT_CLICK)
		clear_labels(usr)

///Clears all labels and logs who did it
/atom/movable/screen/minimap_tool/label/proc/clear_labels(mob/user)
	log_minimap_drawing("[key_name(usr)] has cleared current labels")
	for(var/turf/label as anything in labelled_turfs)
		my_map.remove_marker(label)

/atom/movable/screen/minimap_tool/label/on_mousedown(client/source, atom/object, location, control, params)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(async_mousedown), source, object, location, control, params)

///async mousedown for the actual label placement handling
/atom/movable/screen/minimap_tool/label/proc/async_mousedown(client/source, atom/object, location, control, params)
	// this is really [/atom/movable/screen/minimap/proc/get_coords_from_click] copypaste since we
	// want to also cancel the click if they click src and I cant be bothered to make it even more generic rn
	var/list/modifiers = params2list(params)
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	var/x = (pixel_coords[1] - x_offset - MINIMAP_DRAW_OFFSET) / 2
	var/y = (pixel_coords[2] - y_offset + MINIMAP_DRAW_OFFSET) / 2
	var/c_x = clamp(CEILING(x, 1), 1, world.maxx)
	var/c_y = clamp(CEILING(y, 1), 1, world.maxy)
	var/turf/target = locate(c_x, c_y, zlevel)
	if(modifiers[BUTTON] == RIGHT_CLICK)
		var/curr_dist
		var/turf/nearest
		for(var/turf/label as anything in labelled_turfs)
			var/dist = get_dist_euclidean(label, target)
			if(dist > LABEL_REMOVE_RANGE)
				continue
			if(!curr_dist || curr_dist > dist)
				curr_dist = dist
				nearest = label
		if(nearest)
			my_map.remove_marker(nearest)
		return
	var/label_text = MAPTEXT(tgui_input_text(source, title = "Label Name", max_length = 35))
	var/filter_result = is_ic_filtered(label_text)
	if(filter_result)
		to_chat(source, span_warning("That label contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[label_text]\"</span>"))
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", label_text, filter_result)
		return
	if(!label_text)
		return
	var/atom/movable/screen/minimap/mini = my_map.fetch_minimap_object(zlevel, my_map.minimap_flags)
	if(!locate(mini) in source?.screen)
		return

	var/mutable_appearance/textbox = new
	textbox.maptext_x = 5
	textbox.maptext_y = 5
	textbox.maptext_width = 64
	textbox.maptext = label_text

	labelled_turfs += target
	var/image/blip = image('icons/ui_icons/minimap/map_blips.dmi', null, "label", MINIMAP_LABELS_LAYER)
	blip.overlays += textbox
	my_map.add_marker(target, my_map.minimap_flags, blip)
	log_minimap_drawing("[key_name(source.ckey)] has added the label [label_text] at [c_x], [c_y]")

/atom/movable/screen/minimap_tool/clear
	icon_state = "clear"
	desc = "Remove all current labels and drawings."
	screen_loc = "16,9"

/atom/movable/screen/minimap_tool/clear/Click()
	drawn_image.icon = icon('icons/ui_icons/minimap/minimap.dmi')
	var/atom/movable/screen/minimap_tool/label/labels = locate() in usr.client?.screen
	labels?.clear_labels(usr)
	log_minimap_drawing("[key_name(usr)] has cleared the minimap")

#undef LABEL_REMOVE_RANGE
#undef MINIMAP_DRAW_OFFSET
