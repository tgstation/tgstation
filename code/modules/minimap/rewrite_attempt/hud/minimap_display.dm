/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	var/atom/movable/screen/minimap_drawing/drawing
	/// A reference to the minimap used for this display.
	var/datum/minimap/minimap
	/// Screentext in vis_contents used for the maptext.
	var/atom/movable/screen/minimap_label/screentip
	/// indexed list of currently displayed blips.
	var/list/atom/movable/screen/minimap_blip/blips = list()
	/// The list of minimap blip tags we're going to read from the globalist and listen for additions to
	var/list/valid_minimap_blip_tags = list(MINIMAP_BOMB_BLIP, MINIMAP_NUKEDISK_BLIP, MINIMAP_NUKEOP_BLIP)
	var/last_drag_x
	var/last_drag_y
	/// fixed z-level to stay on
	var/fixed_z_level
	/// list of signals we want to keep tied on the hud owner mob
	var/list/hud_signals = list(
		COMSIG_MOVABLE_Z_CHANGED = PROC_REF(on_z_level_change),
		COMSIG_MINIMAP_CHANGE_Z_LEVEL = PROC_REF(z_change_request)
	)

/atom/movable/screen/minimap_display/Initialize(mapload, datum/hud/hud_owner, datum/minimap/minimap)
	. = ..()
	if(isnull(minimap))
		CRASH("[type] created without a minimap reference!")
	drawing = new
	vis_contents += drawing
	set_minimap(minimap)
	screentip = new
	vis_contents += screentip
	on_z_level_change(hud.mymob)
	show_tagged_blips()

/atom/movable/screen/minimap_display/Destroy()
	minimap = null
	QDEL_NULL(drawing)
	QDEL_NULL(screentip)
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/atom/movable/screen/minimap_display/set_new_hud(datum/hud/hud_owner)
	if(hud?.mymob)
		for(var/signal in hud_signals)
			RegisterSignal(hud_owner.mymob, signal, hud_signals[signal])
	. = ..()
	for(var/signal in hud_signals)
		UnregisterSignal(src, signal, hud_signals[signal])

/atom/movable/screen/minimap_display/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/minimap_display/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	var/list/modifiers = params2list(params)
	var/x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/erase_pixel_range = LAZYACCESS(modifiers, RIGHT_CLICK) ? 5 : 0
	var/color = LAZYACCESS(modifiers, RIGHT_CLICK) ? null : COLOR_RED

	if(last_drag_x && last_drag_y)
		drawing.draw_line(color, last_drag_x, last_drag_y, x, y, erase_pixel_range, 1)
		last_drag_x = null
		last_drag_y = null
	else
		drawing.draw_box(color, x, y, x + 1, y + 1, erase_pixel_range, 1)
		last_drag_x = x
		last_drag_y = y
	testing("minimapdisplay MouseDrag: [over_object], [src_location], [over_location], [src_control], [json_encode(modifiers)]")

/atom/movable/screen/minimap_display/MouseUp(location, control, params)
	last_drag_x = null
	last_drag_y = null

/atom/movable/screen/minimap_display/MouseMove(location, control, params)
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
	screentip.maptext = ""
	last_drag_x = null
	last_drag_y = null

/atom/movable/screen/minimap_display/proc/on_z_level_change(mob/source)
	SIGNAL_HANDLER
	var/turf/mob_loc = get_turf(source)
	if(!mob_loc || mob_loc.z != minimap.z)
		if(isnull(fixed_z_level))
			INVOKE_ASYNC(src, PROC_REF(change_z_level), mob_loc.z)
			return
		remove_blip("locator")
		return
	add_blip("locator", "locator", mob_loc.x, mob_loc.y)

/atom/movable/screen/minimap_display/proc/change_z_level(new_z)
	var/new_minimap = get_minimap_for_z(new_z)
	if(isnull(new_minimap))
		return
	set_minimap(new_minimap)

/atom/movable/screen/minimap_display/proc/show_tagged_blips()
	for(var/blip_flag in valid_minimap_blip_tags)
		var/blip_list = GLOB.minimap_blip_tags[blip_flag]
		for(var/atom/movable/screen/minimap_blip/blip as anything in blip_list)
			if(blip.track_target.z == minimap.z)
				blip.register_target(blip.track_target)
				blip.start_tracking_target()
				blips += blip
				vis_contents += blip

/atom/movable/screen/minimap_display/proc/set_minimap(datum/minimap/minimap)
	icon = minimap.base_map
	screen_loc = "1:[minimap.base_map.Width() / 2],1:[minimap.base_map.Height() / 2]"
	src.minimap = minimap
	drawing.clear_canvas(minimap.base_map)
	// reset screentip if it exists
	screentip?.maptext = ""

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

/atom/movable/screen/minimap_display/proc/z_change_request(new_z_change)
	SIGNAL_HANDLER
	var/new_z = minimap.z + new_z_change
	INVOKE_ASYNC(src, PROC_REF(change_z_level), new_z)
