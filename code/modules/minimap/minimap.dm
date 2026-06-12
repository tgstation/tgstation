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

	base_map = icon('icons/ui_icons/minimap/minimap.dmi')
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
	base_map.Scale(base_map.Width() * MINIMAP_PIXEL_MULTIPLIER, base_map.Height() * MINIMAP_PIXEL_MULTIPLIER)

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
