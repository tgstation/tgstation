GLOBAL_ALIST_EMPTY(minimaps)

/// Represents a minimap for a single Z-level.
/datum/minimap
	/// The icon of the base map itself.
	var/icon/base_map
	/// Mapping of x/y coords to area names.
	var/alist/map_position_to_name = alist()

	var/x_offset
	var/y_offset

/datum/minimap/proc/load_z(z)
	if(!isnum(z) || z > length(SSmapping.z_list))
		CRASH("Tried to create minimap for invalid Z-level ([z])")
	base_map = icon('icons/ui_icons/minimap/minimap.dmi')

	var/vector/min_xy = vector(world.maxx, world.maxy)
	var/vector/max_xy = vector(1, 1)

	map_position_to_name.Cut()
	for(var/turf/location as anything in Z_TURFS(z))
		if(location.skip_minimap_rendering || isshuttleturf(location))
			continue
		var/x = location.x
		var/y = location.y
		// should prolly benchmark if this is better than just having individual (min/max)_(x/y) variables, but this code is slightly nicer to look at.
		var/vector/xy = vector(x, y)
		min_xy = min(min_xy, xy)
		max_xy = max(max_xy, xy)
		var/area/arealoc = location.loc
		map_position_to_name["[x]:[y]"] = arealoc.name
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

	base_map.Crop(min_xy[1], min_xy[2], max_xy[1], max_xy[2])
	base_map.Scale(base_map.Width() * 2, base_map.Height() * 2)

	// x_offset = floor((SCREEN_PIXEL_SIZE - max_xy[1] - min_xy[1]) / 2) * 2
	// y_offset = floor((SCREEN_PIXEL_SIZE - max_xy[2] - min_xy[2]) / 2) * 2

	// base_map.Shift(EAST, x_offset)
	// base_map.Shift(NORTH, y_offset)

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
