/// Assoc list of z-levels to `/datum/minimap` instances.
GLOBAL_ALIST_EMPTY(minimaps)

/// Represents a minimap for a single Z-level.
/datum/minimap
	/// The Z-level this minimap was made for.
	VAR_FINAL/z
	/// The icon of the base map itself.
	var/icon/base_map
	/// Mapping of x/y coords to area names.
	var/alist/map_position_to_name = alist()
	/// Minimum world X coordinate included in the cropped map icon.
	var/min_x = 1
	/// Minimum world Y coordinate included in the cropped map icon.
	var/min_y = 1

/datum/minimap/proc/load_z(z)
	. = FALSE
	if(!isnum(z) || z > length(SSmapping.z_list))
		CRASH("Tried to create minimap for invalid Z-level ([z])")

	src.base_map = icon('icons/ui_icons/minimap/minimap.dmi')
	src.z = z

	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1

	map_position_to_name.Cut()
	for(var/turf/location as anything in Z_TURFS(z))
		if(location.skip_minimap_rendering || isshuttleturf(location))
			continue
		var/area/arealoc = location.loc
		if(arealoc.skip_minimap_rendering)
			continue
		var/x = location.x
		var/y = location.y
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(max_x, x)
		max_y = max(max_y, y)
		if(location.density)
			base_map.DrawBox(location.tacmap_color, x, y)
			continue
		var/atom/movable/alttarget = (locate(/obj/machinery/door) in location) || (locate(/obj/structure/window) in location) || (locate(/obj/structure/fence) in location)
		if(alttarget)
			base_map.DrawBox(alttarget.tacmap_color, x, y)
			continue
		if(arealoc.tacmap_color)
			base_map.DrawBox(BlendRGB(location.tacmap_color, arealoc.tacmap_color, 0.5), x, y)
			continue
		if(istype(location, /turf/open/floor/engine/hull))
			var/turf/turf_below = GET_TURF_BELOW(location)
			var/area/below_area = turf_below?.loc
			// we'll draw the below area's color but transparent
			if(below_area?.tacmap_color)
				var/list/below_color = rgb2num(below_area.tacmap_color)
				base_map.DrawBox(rgb(below_color[1], below_color[2], below_color[3], 64), x, y)
				continue
		base_map.DrawBox(location.tacmap_color, x, y)

	src.min_x = min_x
	src.min_y = min_y

	base_map.Crop(min_x, min_y, max_x, max_y)
	base_map.Scale(base_map.Width() * 2, base_map.Height() * 2)

	return TRUE

/// Gets the `/datum/minimap` for a Z-level - generating it if it hasn't been yet.
/proc/get_minimap_for_z(z) as /datum/minimap
	var/static/generating_minimap = FALSE
	UNTIL(!generating_minimap)

	if(GLOB.minimaps[z])
		return GLOB.minimaps[z]

	generating_minimap = TRUE
	var/datum/minimap/minimap = new
	if(minimap.load_z(z))
		GLOB.minimaps[z] = minimap
		. = minimap
	generating_minimap = FALSE

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
	icon = minimap.base_map
	screen_loc = "1:[minimap.base_map.Width() / 2],1:[minimap.base_map.Height() / 2]"
	src.minimap = minimap

	screentip = new
	vis_contents += screentip

/atom/movable/screen/minimap_display/Destroy()
	minimap = null
	QDEL_LIST_ASSOC_VAL(blips)
	QDEL_NULL(screentip)
	return ..()

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

/atom/movable/screen/minimap_display/proc/add_blip(name, icon_state, x, y, large = FALSE)
	if(blips[name])
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

/client/verb/debug_generate_maps()
	set name = "MINIMAP GENERATION TEST (Debug)"
	set desc = "meow meow meow"
	set category = "mrrrp mrrrp mrrrow"

	GLOB.minimaps.Cut()

	rustg_time_reset("meow_all")
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/datum/minimap/z_minimap = new
		GLOB.minimaps[z] = z_minimap
		rustg_time_reset("meow")
		z_minimap.load_z(z)
		var/time_ms = rustg_time_milliseconds("meow")
		message_admins("Minimap generated for Z [z] in [time_ms] ms")
		fcopy(z_minimap.base_map, "tmp/minimaps/minimap_[SSmapping.current_map.map_name].[z].png")
	var/total_ms = rustg_time_milliseconds("meow_all")
	message_admins("total generation time of [total_ms] ms")

/client/verb/debug_toggle_minimap()
	set name = "MINIMAP DISPLAY TEST (Debug)"
	set desc = "Toggle the rewrite minimap on your HUD."
	set category = "mrrrp mrrrp mrrrow"

	var/datum/hud/hud = mob.hud_used
	if(!hud)
		to_chat(src, span_warning("No HUD found."))
		return

	// Toggle off if already visible.
	if(hud.screen_objects[HUD_TAC_MINIMAP])
		hud.remove_screen_object(HUD_TAC_MINIMAP)
		to_chat(src, span_notice("Minimap hidden."))
		return

	var/datum/minimap/minimap = get_minimap_for_z(mob.z)
	if(!minimap)
		to_chat(src, span_notice("No minimap generated for z=[mob.z]."))
		return

	var/atom/movable/screen/minimap_display/display = new(null, hud, minimap)
	hud.add_screen_object(display, HUD_TAC_MINIMAP, HUD_GROUP_STATIC, update_screen = TRUE)
	display.add_blip("locator", "locator", mob.x, mob.y)
	to_chat(src, span_notice("Minimap shown for z=[mob.z]."))
