#define MINIMAP_TOOLBAR_ERASE_RANGE 5
#define MINIMAP_LABEL_REMOVE_PIXEL_RANGE 5

/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	var/list/origin_px
	var/atom/movable/screen/minimap_element/drawing/drawing
	/// Optional group tag. Displays with the same tag share drawings and labels.
	var/annotation_share_tag
	/// Unified list of currently visible minimap elements (drawings, labels, blips, screentip).
	var/list/atom/movable/screen/minimap_element/visible_minimap_elements = list()
	/// A reference to the minimap used for this display.
	var/datum/minimap/minimap
	/// Screentext in vis_contents used for the maptext.
	var/atom/movable/screen/minimap_element/label/screentip
	/// Named blips indexed by name (added via add_blip()). Tagged blips are rebuilt from globals on z-level change.
	var/list/atom/movable/screen/minimap_element/blip/blips = list()
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
	/// Y-axis offset for drawing to account for mouse cursor icon positioning.
	var/draw_offset_y = -3
	/// Whether this minimap instance allows drawing and labels.
	var/can_draw = TRUE
	/// When TRUE, left-clicking the map places a text label instead of drawing.
	var/label_mode = FALSE
	/// Mouse cursor icon for the currently selected draw/erase tool. Restored when label mode is toggled off.
	var/icon/active_mouse_icon
	/// Tracks which tool button is visually selected. null = nothing selected.
	var/selected_tool_key = null
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

/atom/movable/screen/minimap_display/Initialize(mapload, datum/hud/hud_owner, datum/minimap/minimap, list/minimap_blip_tags, initial_fixed_z_level, annotation_share_tag, can_draw = TRUE)
	src.can_draw = can_draw
	. = ..()
	if(isnull(minimap))
		CRASH("[type] created without a minimap reference!")
	src.annotation_share_tag = isnull(annotation_share_tag) ? "[type]" : annotation_share_tag
	if(isnull(GLOB.minimap_annotation_viewers[src.annotation_share_tag]))
		GLOB.minimap_annotation_viewers[src.annotation_share_tag] = list()
	GLOB.minimap_annotation_viewers[src.annotation_share_tag] |= src
	if(!isnull(initial_fixed_z_level))
		fixed_z_level = initial_fixed_z_level
		INVOKE_ASYNC(src, PROC_REF(apply_fixed_z_minimap), initial_fixed_z_level)
	if(length(minimap_blip_tags))
		valid_minimap_blip_tags = minimap_blip_tags.Copy()
	set_minimap(minimap)
	screentip = new
	show_minimap_element(screentip)
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
		if(hud?.mymob)
			for(var/signal in hud_signals)
				UnregisterSignal(hud.mymob, signal, hud_signals[signal])
		if(hud?.mymob?.client)
			UnregisterSignal(hud.mymob.client, COMSIG_CLIENT_MOUSEUP)
	if(length(GLOB.minimap_annotation_viewers[annotation_share_tag]))
		GLOB.minimap_annotation_viewers[annotation_share_tag] -= src
	minimap = null
	drawing = null
	visible_minimap_elements.Cut()
	annotation_share_tag = null
	QDEL_NULL(screentip)
	if(length(valid_minimap_blip_tags))
		for(var/blip_tag in valid_minimap_blip_tags)
			UnregisterSignal(SSdcs, COMSIG_MINIMAP_ADD(blip_tag))
			UnregisterSignal(SSdcs, COMSIG_MINIMAP_REMOVE(blip_tag))
	blips.Cut()
	return ..()

/atom/movable/screen/minimap_display/set_new_hud(datum/hud/hud_owner)
	if(hud)
		for(var/key in toolbar_button_types)
			hud.remove_screen_object(key, update = FALSE)
		for(var/signal in hud_signals)
			UnregisterSignal(hud_owner?.mymob, signal, hud_signals[signal])
		if(hud?.mymob?.client)
			UnregisterSignal(hud.mymob.client, COMSIG_CLIENT_MOUSEUP)
	. = ..()
	if(hud?.mymob)
		for(var/signal in hud_signals)
			RegisterSignal(hud_owner.mymob, signal, hud_signals[signal])
		if(hud.mymob.client)
			RegisterSignal(hud.mymob.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_client_mouseup))
	if(can_draw)
		for(var/hud_key, hud_type in toolbar_button_types)
			var/atom/movable/screen/minimap_toolbar_button/button = new hud_type(null, hud_owner, src)
			button.tool_key = hud_key
			hud_owner.add_screen_object(button, hud_key, HUD_GROUP_STATIC, update_screen = FALSE)
	reposition_toolbar_buttons()
	hud_owner.show_hud(hud_owner.hud_version)

/atom/movable/screen/minimap_display/Click(location, control, params)
	if(..() || usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	if(can_draw && LAZYACCESS(modifiers, CTRL_CLICK))
		INVOKE_ASYNC(src, PROC_REF(async_place_label), usr, icon_x, icon_y)
		return
	if(can_draw && label_mode)
		if(right_click)
			remove_nearest_label(icon_x, icon_y, usr)
			return
		INVOKE_ASYNC(src, PROC_REF(async_place_label), usr, icon_x, icon_y)

/atom/movable/screen/minimap_display/proc/remove_nearest_label(icon_x, icon_y, mob/user)
	var/list/labels_for_z = get_or_create_annotation_list(/atom/movable/screen/minimap_element/label, minimap.z)
	if(!length(labels_for_z))
		return
	var/atom/movable/screen/minimap_element/label/nearest
	var/nearest_dist_sq
	for(var/atom/movable/screen/minimap_element/label/label as anything in labels_for_z)
		var/dx = label.pixel_w - icon_x
		var/dy = label.pixel_z - icon_y
		var/dist_sq = (dx * dx) + (dy * dy)
		if(dist_sq > (MINIMAP_LABEL_REMOVE_PIXEL_RANGE * MINIMAP_LABEL_REMOVE_PIXEL_RANGE))
			continue
		if(isnull(nearest_dist_sq) || dist_sq < nearest_dist_sq)
			nearest_dist_sq = dist_sq
			nearest = label
	if(isnull(nearest))
		return
	labels_for_z -= nearest
	hide_minimap_element(nearest)
	qdel(nearest)
	sync_visible_objects(minimap?.z)
	log_minimap_drawing("[key_name(user)] removed a minimap label")

/atom/movable/screen/minimap_display/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/minimap_display/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	if(usr != get_mob())
		return
	if(!can_draw)
		return
	var/list/modifiers = params2list(params)
	if(label_mode || LAZYACCESS(modifiers, CTRL_CLICK))
		return
	var/list/mouse_px = params2screenpixel(LAZYACCESS(modifiers, SCREEN_LOC))
	if(length(mouse_px) != 2)
		return
	var/x = mouse_px[1] - origin_px[1] + 1
	var/y = mouse_px[2] - origin_px[2] + 1
	var/icon_width = minimap?.base_map?.Width()
	var/icon_height = minimap?.base_map?.Height()
	if(isnull(icon_width) || isnull(icon_height))
		return
	if(!ISINRANGE(x, 1, icon_width) || !ISINRANGE(y, 1, icon_height))
		// End the current stroke when leaving map bounds to avoid long re-entry lines.
		last_drag_x = null
		last_drag_y = null
		return
	var/erase_pixel_range = isnull(draw_color) ? MINIMAP_TOOLBAR_ERASE_RANGE : 0

	if(last_drag_x && last_drag_y)
		drawing.draw_line(draw_color, last_drag_x, last_drag_y + draw_offset_y, x, y + draw_offset_y, erase_pixel_range, 1)
		last_drag_x = x
		last_drag_y = y
	else
		drawing.draw_box(draw_color, x, y + draw_offset_y, x + 1, y + 1 + draw_offset_y, erase_pixel_range, 1)
		last_drag_x = x
		last_drag_y = y

/atom/movable/screen/minimap_display/proc/on_client_mouseup(client/source)
	SIGNAL_HANDLER
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
	var/hover_text = get_hover_text(x, y)
	screentip.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>[hover_text]</span>")
	screentip.pixel_w = icon_x
	screentip.pixel_z = icon_y

/atom/movable/screen/minimap_display/proc/get_hover_text(x, y)
	var/closest_blip_name
	var/closest_blip_distance
	for(var/atom/movable/screen/minimap_element/blip/blip in visible_minimap_elements)
		if(isnull(blip.track_target) || blip.track_target.z != minimap.z)
			continue
		if(!length(blip.name))
			continue
		var/hover_range = blip.large ? 2 : 1
		var/x_distance = abs(blip.track_target.x - x)
		var/y_distance = abs(blip.track_target.y - y)
		if(x_distance > hover_range || y_distance > hover_range)
			continue
		var/distance = x_distance + y_distance
		if(isnull(closest_blip_distance) || distance < closest_blip_distance)
			closest_blip_distance = distance
			closest_blip_name = blip.name

	if(!isnull(closest_blip_name))
		return closest_blip_name

	var/area_name = minimap.map_position_to_name["[x]:[y]"]
	if(isnull(area_name))
		var/turf/hovered_loc = locate(x, y, minimap.z)
		area_name = "[hovered_loc?.loc?.name]"
		minimap.map_position_to_name["[x]:[y]"] = area_name
	return area_name

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
	add_blip("locator", "locator", mob_loc.x, mob_loc.y, layer = 15)


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
		if(!blip_list)
			continue
		for(var/atom/movable/screen/minimap_element/blip/blip as anything in blip_list)
			on_tagged_blip_add(null, blip)

/atom/movable/screen/minimap_display/proc/on_tagged_blip_add(datum/source, atom/movable/screen/minimap_element/blip/blip)
	SIGNAL_HANDLER
	if(isnull(blip) || QDELETED(blip) || isnull(minimap))
		return
	if(!(blip.blip_tag in valid_minimap_blip_tags))
		return
	if(isnull(blip.track_target))
		return
	var/turf/blip_turf = get_turf(blip.track_target)
	if(blip_turf?.z != minimap.z)
		return
	blip.start_tracking_target()
	show_minimap_element(blip)

/atom/movable/screen/minimap_display/proc/on_tagged_blip_remove(datum/source, atom/movable/screen/minimap_element/blip/blip)
	SIGNAL_HANDLER
	if(isnull(blip))
		return
	hide_minimap_element(blip)

/atom/movable/screen/minimap_display/proc/set_minimap(datum/minimap/minimap)
	if(isnull(minimap))
		return
	icon = minimap.base_map
	var/map_w = minimap.base_map.Width()
	var/map_h = minimap.base_map.Height()
	var/screen_size = get_screen_pixel_size()
	var/map_offset_y = 32
	screen_loc = "1:[screen_size / 2 - map_w / 2],1:[screen_size / 2 - map_h / 2 - map_offset_y]"
	origin_px = params2screenpixel(screen_loc)
	src.minimap = minimap
	refresh_visible_annotations()
	screentip?.maptext = ""
	clear_tagged_blips()
	show_tagged_blips()
	reposition_toolbar_buttons()

/// adds a local blip that's not added to the global list
/atom/movable/screen/minimap_display/proc/add_blip(name, icon_state, x, y, large = FALSE, layer = 12)
	if(blips[name])
		return
	var/atom/movable/screen/minimap_element/blip/new_blip = new(null, null, hud.mymob, icon_state, large)
	new_blip.layer = layer
	new_blip.start_tracking_target()
	blips[name] = new_blip
	show_minimap_element(new_blip)

/atom/movable/screen/minimap_display/proc/update_blip(name, x, y)
	var/atom/movable/screen/minimap_element/blip/blip = blips[name]
	if(!blip)
		return
	var/half_size = blip.large ? 5 : 3
	blip.pixel_w = MINIMAP_WORLD_TO_PIXEL(x, minimap.min_x, half_size)
	blip.pixel_z = MINIMAP_WORLD_TO_PIXEL(y, minimap.min_y, half_size)

/atom/movable/screen/minimap_display/proc/remove_blip(name)
	var/atom/movable/screen/minimap_element/blip/blip = blips[name]
	if(!blip)
		return
	blips -= name
	hide_minimap_element(blip)
	qdel(blip)

/atom/movable/screen/minimap_display/proc/remove_all_blips()
	for(var/blip_name in blips)
		var/atom/movable/screen/minimap_element/blip/blip = blips[blip_name]
		hide_minimap_element(blip)
		qdel(blip)
	blips.Cut()
	hide_visible_elements_by_type(/atom/movable/screen/minimap_element/blip)

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
	for(var/connected_z in connected_levels)
		var/current_distance = abs(connected_z - requested_z)
		if(current_distance < closest_distance)
			closest_z = connected_z
			closest_distance = current_distance
	return closest_z

/atom/movable/screen/minimap_display/proc/select_draw_tool(color, icon/mouse_icon = null, tool_key = null)
	if(!can_draw)
		return
	// Toggle: if clicking the same tool, deselect it
	if(selected_tool_key == tool_key && tool_key != null)
		selected_tool_key = null
		draw_color = null
		active_mouse_icon = null
		if(hud?.mymob?.client)
			hud.mymob.client.mouse_pointer_icon = null
		return
	selected_tool_key = tool_key
	draw_color = color
	label_mode = FALSE
	active_mouse_icon = mouse_icon
	if(hud?.mymob?.client)
		hud.mymob.client.mouse_pointer_icon = mouse_icon

/atom/movable/screen/minimap_display/proc/toggle_label_mode(icon/label_mouse_icon = null)
	if(!can_draw)
		return
	label_mode = !label_mode
	if(hud?.mymob?.client)
		hud.mymob.client.mouse_pointer_icon = label_mode ? label_mouse_icon : active_mouse_icon
	update_toolbar_button_states()

/// Calculates the actual screen pixel size based on the client's view
/atom/movable/screen/minimap_display/proc/get_screen_pixel_size()
	if(!hud?.mymob?.client)
		return SCREEN_PIXEL_SIZE  // fallback to constant if no client
	var/list/view_pixels = view_to_pixels(hud.mymob.client.view_size.getView())
	// Return the maximum dimension (typically square, but handle non-square views)
	return max(view_pixels[1], view_pixels[2])

/atom/movable/screen/minimap_display/proc/update_toolbar_button_states()
	if(!hud)
		return
	for(var/hud_key in toolbar_button_types)
		var/atom/movable/screen/minimap_toolbar_button/button = hud.screen_objects[hud_key]
		if(button)
			button.update_active_state()

/atom/movable/screen/minimap_display/proc/reposition_toolbar_buttons()
	if(!hud || !minimap)
		return
	// origin_px[1] is the minimap's left edge; place toolbar one icon-width to its left.
	var/btn_x = origin_px[1] - ICON_SIZE_X - 4
	if(btn_x < 0)
		btn_x = origin_px[1] + minimap.base_map.Width() + 4  // fall back to right side
	// Toolbar is vertically centered relative to the minimap's current position.
	var/screen_size = get_screen_pixel_size()
	var/toolbar_h = length(toolbar_button_types) * ICON_SIZE_Y
	var/map_center_y = origin_px[2] + minimap.base_map.Height() / 2
	var/btn_top_y = clamp(map_center_y + toolbar_h / 2, toolbar_h, screen_size)
	for(var/key in toolbar_button_types)
		var/atom/movable/screen/minimap_toolbar_button/button = hud.screen_objects[key]
		if(button)
			button.screen_loc = "1:[btn_x],1:[btn_top_y - ICON_SIZE_Y - button.button_slot * ICON_SIZE_Y]"

/atom/movable/screen/minimap_display/proc/clear_canvas_and_labels(mob/user)
	if(!can_draw)
		return
	drawing.clear_canvas(minimap?.base_map)
	clear_all_annotations(user, /atom/movable/screen/minimap_element/label)
	sync_visible_objects(minimap?.z)

/atom/movable/screen/minimap_display/proc/clear_all_annotations(mob/user, annotation_type = /atom/movable/screen/minimap_element/label)
	var/alist/annotation_store = GLOB.minimap_annotations[annotation_share_tag]
	var/alist/items_by_z = annotation_store?[annotation_type]
	if(isnull(items_by_z))
		return
	var/list/cleared_levels = list()
	for(var/z_level in items_by_z)
		var/list/items = items_by_z[z_level]
		if(!length(items))
			continue
		QDEL_LIST(items)
		items_by_z[z_level] = list()
		cleared_levels += z_level
	refresh_visible_annotations()
	for(var/z_level in cleared_levels)
		sync_visible_objects(z_level)
	var/user_name = user ? key_name(user) : "System"
	log_minimap_drawing("[user_name] has cleared all [annotation_type] annotations")

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
	var/list/filter_result = is_ic_filtered(label_text)
	if(filter_result)
		to_chat(user, span_warning("That label contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[label_text]\"</span>"))
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, LOWER_TEXT(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", label_text, filter_result)
		return
	var/atom/movable/screen/minimap_element/label/new_label = new
	new_label.icon = 'icons/ui_icons/minimap/map_blips.dmi'
	new_label.icon_state = "label"
	new_label.maptext_x = 5
	new_label.maptext_y = 5
	new_label.maptext_width = 64
	new_label.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>[label_text]</span>")
	var/icon/label_icon = icon(new_label.icon, new_label.icon_state)
	var/half_width = round(label_icon.Width() / 2)
	var/half_height = round(label_icon.Height() / 2)
	new_label.pixel_w = MINIMAP_WORLD_TO_PIXEL(x, minimap.min_x, half_width)
	new_label.pixel_z = MINIMAP_WORLD_TO_PIXEL(y, minimap.min_y, half_height)
	var/list/labels_for_z = get_or_create_annotation_list(/atom/movable/screen/minimap_element/label, minimap.z)
	labels_for_z += new_label
	sync_visible_objects(minimap?.z)
	log_minimap_drawing("[key_name(user)] placed label '[label_text]' at [area_name]")

/atom/movable/screen/minimap_display/proc/get_or_create_annotation_list(annotation_type, z_level)
	var/alist/annotation_store = GLOB.minimap_annotations[annotation_share_tag]
	if(isnull(annotation_store))
		annotation_store = alist()
		GLOB.minimap_annotations[annotation_share_tag] = annotation_store
	var/alist/by_z = annotation_store[annotation_type]
	if(isnull(by_z))
		by_z = alist()
		annotation_store[annotation_type] = by_z
	var/list/items = by_z[z_level]
	if(isnull(items))
		items = list()
		by_z[z_level] = items
	return items

/atom/movable/screen/minimap_display/proc/refresh_visible_annotations()
	if(isnull(minimap))
		return
	var/list/drawings = get_or_create_annotation_list(/atom/movable/screen/minimap_element/drawing, minimap.z)
	var/atom/movable/screen/minimap_element/drawing/target_drawing = length(drawings) ? drawings[1] : null
	if(isnull(target_drawing))
		target_drawing = new
		target_drawing.clear_canvas(minimap.base_map)
		drawings += target_drawing
	if(drawing != target_drawing)
		if(!isnull(drawing))
			hide_minimap_element(drawing)
		drawing = target_drawing
	show_minimap_element(drawing)

	hide_visible_elements_by_type(/atom/movable/screen/minimap_element/label)
	var/list/labels_for_z = get_or_create_annotation_list(/atom/movable/screen/minimap_element/label, minimap.z)
	if(length(labels_for_z))
		show_minimap_elements(labels_for_z)
	show_minimap_element(screentip)

/atom/movable/screen/minimap_display/proc/sync_visible_objects(z_level)
	if(isnull(z_level))
		return
	var/list/displays_for_tag = GLOB.minimap_annotation_viewers[annotation_share_tag]
	if(!length(displays_for_tag))
		return
	for(var/atom/movable/screen/minimap_display/display as anything in displays_for_tag)
		if(QDELETED(display) || display.minimap?.z != z_level)
			continue
		display.refresh_visible_annotations()

/atom/movable/screen/minimap_display/proc/show_minimap_element(atom/movable/screen/minimap_element/element)
	if(isnull(element))
		return
	if(!(element in visible_minimap_elements))
		visible_minimap_elements += element
	vis_contents |= element

/atom/movable/screen/minimap_display/proc/hide_minimap_element(atom/movable/screen/minimap_element/element)
	if(isnull(element))
		return
	visible_minimap_elements -= element
	vis_contents -= element

/atom/movable/screen/minimap_display/proc/show_minimap_elements(list/elements)
	for(var/atom/movable/screen/minimap_element/element as anything in elements)
		show_minimap_element(element)

/atom/movable/screen/minimap_display/proc/hide_minimap_elements(list/elements)
	for(var/atom/movable/screen/minimap_element/element as anything in elements)
		hide_minimap_element(element)

/atom/movable/screen/minimap_display/proc/hide_visible_elements_by_type(element_type)
	if(isnull(element_type))
		return
	for(var/atom/movable/screen/minimap_element/element as anything in visible_minimap_elements.Copy())
		if(istype(element, element_type))
			hide_minimap_element(element)

/atom/movable/screen/minimap_display/proc/clear_tagged_blips()
	for(var/atom/movable/screen/minimap_element/blip/blip as anything in visible_minimap_elements.Copy())
		if(!length(blip.blip_tag))
			continue
		hide_minimap_element(blip)

/atom/movable/screen/minimap_display/nuclear
	annotation_share_tag = MINIMAP_ANNOTATION_TAG_NUCLEAR
	valid_minimap_blip_tags = list(MINIMAP_BOMB_BLIP, MINIMAP_NUKEDISK_BLIP, MINIMAP_NUKEOP_BLIP, MINIMAP_SYNDICATE_MECH_BLIP, MINIMAP_SYNDIE_TURRET_BLIP, MINIMAP_LADDER_BLIP, MINIMAP_STAIR_BLIP)

#undef MINIMAP_TOOLBAR_ERASE_RANGE
#undef MINIMAP_LABEL_REMOVE_PIXEL_RANGE
