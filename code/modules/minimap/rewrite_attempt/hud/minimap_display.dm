#define MINIMAP_TOOLBAR_ERASE_RANGE 5

/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	var/list/origin_px
	var/atom/movable/screen/minimap_drawing/drawing
	/// Cached list of Z levels to drawings.
	var/alist/cached_drawings = alist()
	/// A reference to the minimap used for this display.
	var/datum/minimap/minimap
	/// Screentext in vis_contents used for the maptext.
	var/atom/movable/screen/minimap_label/screentip
	/// List of user-applied labels.
	var/list/atom/movable/screen/minimap_label/labels = list()
	/// indexed list of currently displayed blips.
	var/list/atom/movable/screen/minimap_blip/blips = list()
	/// Tagged blips currently rendered on this minimap display.
	var/list/atom/movable/screen/minimap_blip/active_tagged_blips = list()
	/// The list of minimap blip tags we're going to read from the globalist and listen for additions to
	var/list/valid_minimap_blip_tags = list()
	var/last_drag_x
	var/last_drag_y
	/// fixed z-level to stay on
	var/fixed_z_level
	/// list of signals we want to keep tied on the hud owner mob
	var/list/hud_signals = list(
		COMSIG_MOVABLE_Z_CHANGED = PROC_REF(on_z_level_change),
		COMSIG_MINIMAP_CHANGE_Z_LEVEL = PROC_REF(z_change_request)
	)
	/// Currently selected draw color. null = erase mode.
	var/draw_color = TACMAP_DRAWING_RED
	/// When TRUE, left-clicking the map places a text label instead of drawing.
	var/label_mode = FALSE
	/// Mouse cursor icon for the currently selected draw/erase tool. Restored when label mode is toggled off.
	var/icon/active_mouse_icon
	/// Maps HUD key → button type path. Used to create/remove toolbar buttons via [/datum/hud].
	var/static/list/toolbar_button_types = list(
		HUD_TAC_MINIMAP_TOOL_RED    = /atom/movable/screen/minimap_toolbar_button/draw/red,
		HUD_TAC_MINIMAP_TOOL_YELLOW = /atom/movable/screen/minimap_toolbar_button/draw/yellow,
		HUD_TAC_MINIMAP_TOOL_PURPLE = /atom/movable/screen/minimap_toolbar_button/draw/purple,
		HUD_TAC_MINIMAP_TOOL_BLUE   = /atom/movable/screen/minimap_toolbar_button/draw/blue,
		HUD_TAC_MINIMAP_TOOL_ERASE  = /atom/movable/screen/minimap_toolbar_button/erase,
		HUD_TAC_MINIMAP_TOOL_LABEL  = /atom/movable/screen/minimap_toolbar_button/label,
		HUD_TAC_MINIMAP_TOOL_CLEAR  = /atom/movable/screen/minimap_toolbar_button/clear,
	)

/atom/movable/screen/minimap_display/Initialize(mapload, datum/hud/hud_owner, datum/minimap/minimap, list/minimap_blip_tags, initial_fixed_z_level)
	. = ..()
	if(isnull(minimap))
		CRASH("[type] created without a minimap reference!")
	if(!isnull(initial_fixed_z_level))
		fixed_z_level = initial_fixed_z_level
		apply_fixed_z_minimap(initial_fixed_z_level)
	if(length(minimap_blip_tags))
		valid_minimap_blip_tags = minimap_blip_tags.Copy()
	set_minimap(minimap)
	screentip = new
	vis_contents += screentip
	if(length(valid_minimap_blip_tags))
		for(var/blip_tag in valid_minimap_blip_tags)
			RegisterSignal(SSdcs, COMSIG_MINIMAP_ADD(blip_tag), PROC_REF(on_tagged_blip_add))
			RegisterSignal(SSdcs, COMSIG_MINIMAP_REMOVE(blip_tag), PROC_REF(on_tagged_blip_remove))
	on_z_level_change(hud_owner.mymob)
	show_tagged_blips()

/atom/movable/screen/minimap_display/proc/apply_fixed_z_minimap(target_z)
	if(QDELETED(src) || isnull(target_z) || fixed_z_level != target_z)
		return
	var/datum/minimap/fixed_minimap = get_minimap_for_z(target_z)
	if(QDELETED(src) || isnull(fixed_minimap) || fixed_z_level != target_z)
		return
	set_minimap(fixed_minimap)

/atom/movable/screen/minimap_display/Destroy()
	if(hud?.mymob?.client)
		hud.mymob.client.mouse_pointer_icon = null
	if(hud)
		for(var/key in toolbar_button_types)
			hud.remove_screen_object(key, update = FALSE)
	minimap = null
	cached_drawings.Cut()
	QDEL_NULL(screentip)
	QDEL_LIST(labels)
	if(length(valid_minimap_blip_tags))
		for(var/blip_tag in valid_minimap_blip_tags)
			UnregisterSignal(SSdcs, COMSIG_MINIMAP_ADD(blip_tag))
			UnregisterSignal(SSdcs, COMSIG_MINIMAP_REMOVE(blip_tag))
	active_tagged_blips.Cut()
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/atom/movable/screen/minimap_display/set_new_hud(datum/hud/hud_owner)
	if(hud)
		for(var/key in toolbar_button_types)
			hud.remove_screen_object(key, update = FALSE)
		for(var/signal in hud_signals)
			UnregisterSignal(hud_owner?.mymob, signal, hud_signals[signal])
	. = ..()
	if(hud?.mymob)
		for(var/signal in hud_signals)
			RegisterSignal(hud_owner.mymob, signal, hud_signals[signal])
	for(var/hud_key, hud_type in toolbar_button_types)
		var/atom/movable/screen/minimap_toolbar_button/button = new hud_type(null, hud_owner, src)
		hud_owner.add_screen_object(button, hud_key, HUD_GROUP_STATIC, update_screen = FALSE)
	reposition_toolbar_buttons()
	hud_owner.show_hud(hud_owner.hud_version)

/atom/movable/screen/minimap_display/Click(location, control, params)
	if(..() || usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		INVOKE_ASYNC(src, PROC_REF(async_place_label), usr, icon_x, icon_y)
		return
	if(label_mode)
		INVOKE_ASYNC(src, PROC_REF(async_place_label), usr, icon_x, icon_y)

/atom/movable/screen/minimap_display/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/minimap_display/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	if(usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	if(label_mode || LAZYACCESS(modifiers, CTRL_CLICK))
		return
	var/list/mouse_px = params2screenpixel(LAZYACCESS(modifiers, SCREEN_LOC))
	var/x = mouse_px[1] - origin_px[1] + 1
	var/y = mouse_px[2] - origin_px[2] + 1
	var/erase_pixel_range = isnull(draw_color) ? MINIMAP_TOOLBAR_ERASE_RANGE : 0

	if(last_drag_x && last_drag_y)
		drawing.draw_line(draw_color, last_drag_x, last_drag_y, x, y, erase_pixel_range, 1)
		last_drag_x = null
		last_drag_y = null
	else
		drawing.draw_box(draw_color, x, y, x + 1, y + 1, erase_pixel_range, 1)
		last_drag_x = x
		last_drag_y = y

/atom/movable/screen/minimap_display/MouseUp(location, control, params)
	if(usr != get_mob())
		return
	last_drag_x = null
	last_drag_y = null

/atom/movable/screen/minimap_display/MouseMove(location, control, params)
	if(usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	var/x = clamp(MINIMAP_ICON_TO_WORLD(icon_x, minimap.min_x), 1, world.maxx)
	var/y = clamp(MINIMAP_ICON_TO_WORLD(icon_y, minimap.min_y), 1, world.maxy)

	var/area_name = minimap.map_position_to_name["[x]:[y]"]
	if(isnull(area_name))
		var/turf/hovered_loc = locate(x, y, minimap.z)
		area_name = "[hovered_loc?.loc?.name]"
		minimap.map_position_to_name["[x]:[y]"] = area_name
	screentip.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>[area_name]</span>")
	screentip.pixel_w = icon_x
	screentip.pixel_z = icon_y

/atom/movable/screen/minimap_display/MouseExited(location, control, params)
	if(usr != get_mob())
		return
	screentip.maptext = ""
	last_drag_x = null
	last_drag_y = null

/atom/movable/screen/minimap_display/proc/on_z_level_change(mob/source)
	SIGNAL_HANDLER
	var/turf/mob_loc = get_turf(source)
	if(!mob_loc || mob_loc.z != minimap.z)
		if(isnull(fixed_z_level))
			INVOKE_ASYNC(src, PROC_REF(resolve_and_change_z_level), mob_loc.z)
			return
		remove_blip("locator")
		return
	add_blip("locator", "locator", mob_loc.x, mob_loc.y)


/atom/movable/screen/minimap_display/proc/resolve_and_change_z_level(new_z)
	if(isnull(new_z))
		return
	var/datum/minimap/new_minimap = get_minimap_for_z(new_z)
	if(QDELETED(src) || isnull(new_minimap))
		return
	change_z_level(new_z, new_minimap)

/atom/movable/screen/minimap_display/proc/change_z_level(new_z, datum/minimap/new_minimap)
	if(isnull(new_minimap))
		return
	if(!isnull(fixed_z_level))
		fixed_z_level = new_z
	set_minimap(new_minimap)

/atom/movable/screen/minimap_display/proc/set_fixed_z_level(new_fixed_z, apply_immediately = FALSE)
	fixed_z_level = new_fixed_z
	if(apply_immediately)
		INVOKE_ASYNC(src, PROC_REF(resolve_and_change_z_level), new_fixed_z)

/atom/movable/screen/minimap_display/proc/show_tagged_blips()
	if(!length(valid_minimap_blip_tags))
		return
	for(var/blip_flag in valid_minimap_blip_tags)
		var/blip_list = GLOB.minimap_blip_tags[blip_flag]
		for(var/atom/movable/screen/minimap_blip/blip as anything in blip_list)
			on_tagged_blip_add(null, blip)

/atom/movable/screen/minimap_display/proc/on_tagged_blip_add(datum/source, atom/movable/screen/minimap_blip/blip)
	SIGNAL_HANDLER
	if(isnull(blip) || QDELETED(blip) || isnull(minimap))
		return
	if(!(blip.blip_tag in valid_minimap_blip_tags))
		return
	if(blip.track_target?.z != minimap.z)
		return
	if(blip in active_tagged_blips)
		return
	blip.register_target(blip.track_target)
	blip.start_tracking_target()
	active_tagged_blips += blip
	vis_contents += blip

/atom/movable/screen/minimap_display/proc/on_tagged_blip_remove(datum/source, atom/movable/screen/minimap_blip/blip)
	SIGNAL_HANDLER
	if(isnull(blip))
		return
	if(!(blip in active_tagged_blips))
		return
	active_tagged_blips -= blip
	vis_contents -= blip

/atom/movable/screen/minimap_display/proc/set_minimap(datum/minimap/minimap)
	icon = minimap.base_map
	screen_loc = "1:[minimap.base_map.Width() / 2],1:[minimap.base_map.Height() / 2]"
	origin_px = params2screenpixel(screen_loc)
	src.minimap = minimap
	if(cached_drawings[minimap.z])
		vis_contents -= drawing
		drawing = cached_drawings[minimap.z]
		vis_contents |= drawing
	else
		drawing = new
		vis_contents += drawing
		drawing.clear_canvas(minimap.base_map)
		cached_drawings[minimap.z] = drawing
	screentip?.maptext = ""
	for(var/atom/movable/screen/minimap_blip/blip as anything in active_tagged_blips)
		vis_contents -= blip
	active_tagged_blips.Cut()
	show_tagged_blips()
	reposition_toolbar_buttons()

/atom/movable/screen/minimap_display/proc/add_blip(name, icon_state, x, y, large = FALSE)
	if(blips[name])
		return
	var/atom/movable/screen/minimap_blip/new_blip = new(null, null, hud.mymob, icon_state, large)
	new_blip.register_target(hud.mymob)
	new_blip.start_tracking_target()
	blips |= new_blip
	vis_contents |= new_blip

/atom/movable/screen/minimap_display/proc/update_blip(name, x, y)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	var/half_size = blip.large ? 5 : 3
	blip.pixel_w = MINIMAP_WORLD_TO_PIXEL(x, minimap.min_x, half_size)
	blip.pixel_z = MINIMAP_WORLD_TO_PIXEL(y, minimap.min_y, half_size)

/atom/movable/screen/minimap_display/proc/remove_blip(name)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	blips -= name
	vis_contents -= blip
	qdel(blip)

/atom/movable/screen/minimap_display/proc/remove_all_blips()
	blips.Cut()
	vis_contents.Cut()
	vis_contents += screentip // add screentip back in

/atom/movable/screen/minimap_display/proc/z_change_request(mob/hud_owner, new_z_change)
	SIGNAL_HANDLER
	var/current_z = get_viewed_z_level()
	var/new_z = get_clamped_connected_z(current_z + new_z_change, current_z)
	INVOKE_ASYNC(src, PROC_REF(resolve_and_change_z_level), new_z)

/atom/movable/screen/minimap_display/proc/get_viewed_z_level()
	if(!isnull(fixed_z_level))
		return fixed_z_level
	return minimap?.z

/atom/movable/screen/minimap_display/proc/get_clamped_connected_z(requested_z, source_z)
	if(isnull(source_z))
		return requested_z
	var/list/connected_levels = SSmapping.get_connected_levels(source_z)
	if(!length(connected_levels))
		return requested_z
	if(requested_z in connected_levels)
		return requested_z
	var/closest_z = connected_levels[1]
	var/closest_distance = abs(closest_z - requested_z)
	for(var/connected_z as anything in connected_levels)
		var/current_distance = abs(connected_z - requested_z)
		if(current_distance < closest_distance)
			closest_z = connected_z
			closest_distance = current_distance
	return closest_z

/atom/movable/screen/minimap_display/proc/select_draw_tool(color, icon/mouse_icon = null)
	draw_color = color
	label_mode = FALSE
	active_mouse_icon = mouse_icon
	if(hud?.mymob?.client)
		hud.mymob.client.mouse_pointer_icon = mouse_icon

/atom/movable/screen/minimap_display/proc/toggle_label_mode(icon/label_mouse_icon = null)
	label_mode = !label_mode
	if(hud?.mymob?.client)
		hud.mymob.client.mouse_pointer_icon = label_mode ? label_mouse_icon : active_mouse_icon

/atom/movable/screen/minimap_display/proc/reposition_toolbar_buttons()
	if(!hud || !minimap)
		return
	// I hate math. I'm just throwing crap at the wall until this works. ~Lucy
	var/map_w = minimap.base_map.Width()
	var/map_h = minimap.base_map.Height()
	var/btn_x = origin_px[1] - ICON_SIZE_X - 4
	if(btn_x <= (ICON_SIZE_X * 2))
		btn_x = map_w + ICON_SIZE_X + 4
	var/toolbar_h = length(toolbar_button_types) * ICON_SIZE_Y
	var/btn_top_y = clamp(
		origin_px[2] + round(map_h / 2) + toolbar_h,
		ICON_SIZE_Y + toolbar_h,
		SCREEN_PIXEL_SIZE - (ICON_SIZE_Y * 2)
	)
	for(var/key in toolbar_button_types)
		var/atom/movable/screen/minimap_toolbar_button/button = hud.screen_objects[key]
		if(button)
			button.screen_loc = "1:[btn_x],1:[btn_top_y - button.button_slot * ICON_SIZE_Y]"

/atom/movable/screen/minimap_display/proc/clear_canvas_and_labels(mob/user)
	drawing.clear_canvas(minimap?.base_map)
	clear_labels_all(user)

/atom/movable/screen/minimap_display/proc/clear_labels_all(mob/user)
	vis_contents -= labels
	QDEL_LIST(labels)
	log_minimap_drawing("[key_name(user)] has cleared all labels")

/atom/movable/screen/minimap_display/proc/async_place_label(mob/user, icon_x, icon_y)
	var/x = clamp(MINIMAP_ICON_TO_WORLD(icon_x, minimap.min_x), 1, world.maxx)
	var/y = clamp(MINIMAP_ICON_TO_WORLD(icon_y, minimap.min_y), 1, world.maxy)
	var/area_name = minimap.map_position_to_name["[x]:[y]"]
	if(isnull(area_name))
		var/turf/hovered_loc = locate(x, y, minimap.z)
		area_name = "[hovered_loc?.loc?.name]"
		minimap.map_position_to_name["[x]:[y]"] = area_name
	var/label_text = tgui_input_text(user, "What would you like the label at [area_name] to say?", "Add Label", max_length = 25)
	if(!label_text || QDELETED(src))
		return
	var/atom/movable/screen/minimap_label/new_label = new
	new_label.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>[label_text]</span>")
	new_label.pixel_w = icon_x
	new_label.pixel_z = icon_y
	vis_contents += new_label
	labels += new_label
	log_minimap_drawing("[key_name(user)] placed label '[label_text]' at [area_name]")

/atom/movable/screen/minimap_display/nuclear
	valid_minimap_blip_tags = list(MINIMAP_BOMB_BLIP, MINIMAP_NUKEDISK_BLIP, MINIMAP_NUKEOP_BLIP)

#undef MINIMAP_TOOLBAR_ERASE_RANGE
