/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	/// A reference to the minimap used for this display.
	var/datum/minimap/minimap
	/// Screentext in vis_contents used for the maptext.
	var/atom/movable/screen/minimap_label/screentip
	/// Assoc list of "names" to blips.
	var/list/atom/movable/screen/minimap_blip/blips = list()

/atom/movable/screen/minimap_display/Initialize(mapload, datum/hud/hud_owner, datum/minimap/minimap)
	. = ..()
	if(isnull(minimap))
		CRASH("[type] created without a minimap reference!")
	set_minimap(minimap)
	screentip = new
	vis_contents += screentip
	update_owner_blip(hud.mymob)

/atom/movable/screen/minimap_display/Destroy()
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	minimap = null
	QDEL_LIST_ASSOC_VAL(blips)
	QDEL_NULL(screentip)
	return ..()

/atom/movable/screen/minimap_display/set_new_hud(datum/hud/hud_owner)
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	. = ..()
	if(hud?.mymob)
		RegisterSignals(hud.mymob, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(update_owner_blip))

/atom/movable/screen/minimap_display/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/minimap_display/MouseMove(location, control, params)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	var/x = clamp(minimap.min_x + floor((icon_x - 1) / 2), 1, world.maxx)
	var/y = clamp(minimap.min_y + floor((icon_y - 1) / 2), 1, world.maxy)

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

/atom/movable/screen/minimap_display/proc/update_owner_blip(mob/source)
	SIGNAL_HANDLER
	var/turf/mob_loc = get_turf(source)
	if(!mob_loc || mob_loc.z != minimap.z)
		remove_blip("locator")
		return
	add_blip("locator", "locator", mob_loc.x, mob_loc.y)

/atom/movable/screen/minimap_display/proc/set_minimap(datum/minimap/minimap)
	icon = minimap.base_map
	screen_loc = "1:[minimap.base_map.Width() / 2],1:[minimap.base_map.Height() / 2]"
	src.minimap = minimap
	// reset screentip if it exists
	screentip?.maptext = ""

/atom/movable/screen/minimap_display/proc/add_blip(name, icon_state, x, y, large = FALSE)
	if(blips[name])
		if(blips[name].icon_state == icon_state)
			update_blip(name, x, y)
			return
		else
			remove_blip(name)
	var/atom/movable/screen/minimap_blip/new_blip = new(null, null, icon_state, large)
	blips[name] = new_blip
	var/half_size = large ? 5 : 3
	new_blip.pixel_w = (x - minimap.min_x) * 2 + 1 - half_size
	new_blip.pixel_z = (y - minimap.min_y) * 2 + 1 - half_size
	vis_contents += new_blip

/atom/movable/screen/minimap_display/proc/update_blip(name, x, y)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	var/half_size = blip.large ? 5 : 3
	blip.pixel_w = (x - minimap.min_x) * 2 + 1 - half_size
	blip.pixel_z = (y - minimap.min_y) * 2 + 1 - half_size

/atom/movable/screen/minimap_display/proc/remove_blip(name)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	blips -= name
	vis_contents -= blip
	qdel(blip)

/atom/movable/screen/minimap_display/proc/remove_all_blips()
	QDEL_LIST_ASSOC_VAL(blips)
	vis_contents.Cut()
	vis_contents += screentip // add screentip back in

/atom/movable/screen/minimap_label
	name = ""
	layer = MINIMAP_LABELS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	maptext = ""
	maptext_width = 96
	maptext_height = 96

/atom/movable/screen/minimap_blip
	name = ""
	icon = 'icons/ui_icons/minimap/map_blips.dmi'
	layer = MINIMAP_BLIPS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	/// Is this a large blip?
	var/large = FALSE

/atom/movable/screen/minimap_blip/Initialize(mapload, datum/hud/hud_owner, icon_state, large = FALSE)
	. = ..()
	src.icon_state = icon_state
	if(large)
		src.icon = 'icons/ui_icons/minimap/map_blips_large.dmi'
		src.large = TRUE
