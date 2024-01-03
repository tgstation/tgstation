SUBSYSTEM_DEF(minimap)
	name = "Minimap"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_MINIMAP
	var/list/datum/minimap_data/minimaps_by_z_level = list()
	var/list/generating = list()
	var/list/too_large_z_levels = list()

/datum/minimap_data
	var/z_level
	var/png_location
	var/minimap_tile_width
	var/minimap_tile_height
	var/minimap_tile_offset_x
	var/minimap_tile_offset_y
	var/minimap_icon_size
	var/minimap_pixel_width
	var/minimap_pixel_height

/datum/controller/subsystem/minimap/Initialize()
	for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		generate_minimap_for_z(z_level)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/minimap/Recover()
	minimaps_by_z_level = SSminimap.minimaps_by_z_level
	generating = SSminimap.generating
	too_large_z_levels = SSminimap.too_large_z_levels

/// Generates a minimap for the given z level
/datum/controller/subsystem/minimap/proc/generate_minimap_for_z(z)
	if(z in generating)
		stack_trace("Attempted to generate minimap for [z] when it is already generating!")
		return

	if(z in too_large_z_levels)
		stack_trace("Attempted to generate minimap for [z] when it is too large!")
		return

	if("[z]" in minimaps_by_z_level)
		stack_trace("Attempted to generate minimap for [z] when it already exists!")
		return

	generating += z

#ifdef TESTING
	var/started_at = REALTIMEOFDAY
#endif

	var/list/turfs_we_care_about = list()
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1
	for(var/turf/turf as anything in Z_TURFS(z))
		if(!do_we_care_about_this_turf(turf))
			continue
		turfs_we_care_about += turf
		if(turf.x < min_x)
			min_x = turf.x
		else if(turf.x > max_x)
			max_x = turf.x
		if(turf.y < min_y)
			min_y = turf.y
		else if(turf.y > max_y)
			max_y = turf.y

	var/datum/minimap_data/minimap_data = new
	minimap_data.z_level = z
	minimap_data.png_location = "data/minimaps/z[z].png"
	minimap_data.minimap_tile_width = (max_x - min_x) + 1
	minimap_data.minimap_tile_height = (max_y - min_y) + 1
	minimap_data.minimap_icon_size = world.icon_size
	minimap_data.minimap_tile_offset_x = min_x
	minimap_data.minimap_tile_offset_y = min_y
	minimap_data.minimap_pixel_width = minimap_data.minimap_tile_width * minimap_data.minimap_icon_size
	minimap_data.minimap_pixel_height = minimap_data.minimap_tile_height * minimap_data.minimap_icon_size

	while(TRUE)
		minimap_data.minimap_pixel_width = minimap_data.minimap_tile_width * minimap_data.minimap_icon_size
		minimap_data.minimap_pixel_height = minimap_data.minimap_tile_height * minimap_data.minimap_icon_size
		if(minimap_data.minimap_pixel_width <= 2048 && minimap_data.minimap_pixel_height <= 2048)
			break
		minimap_data.minimap_icon_size *= 0.5
		if(minimap_data.minimap_icon_size < 8)
			stack_trace("Cannot generate minimap for [z] because it is too large! ([minimap_data.minimap_tile_width]x[minimap_data.minimap_tile_height])")
			too_large_z_levels += z
			generating -= z
			return

	testing("MINIMAP GEN | OFFSETS | [minimap_data.minimap_tile_offset_x],[minimap_data.minimap_tile_offset_y]")
	testing("MINIMAP GEN | TILES | [minimap_data.minimap_tile_width]x[minimap_data.minimap_tile_height]")
	testing("MINIMAP GEN | PIXELS | [minimap_data.minimap_pixel_width]x[minimap_data.minimap_pixel_height]")
	testing("MINIMAP GEN | ICON SIZE | [minimap_data.minimap_icon_size]")
	testing("MINIMAP GEN | PNG LOCATION | [minimap_data.png_location]")

	var/icon/master = icon('icons/blanks/32x32.dmi', "nothing")
	master.Scale(minimap_data.minimap_pixel_width, minimap_data.minimap_pixel_height)

	var/list/turf_map = new(minimap_data.minimap_pixel_width)
	for(var/offset_x in 1 to minimap_data.minimap_tile_width)
		turf_map[offset_x] = new /list(minimap_data.minimap_tile_height)

	for(var/turf/turf as anything in turfs_we_care_about)
		var/offset_x = turf.x - minimap_data.minimap_tile_offset_x
		var/offset_y = turf.y - minimap_data.minimap_tile_offset_y
		var/icon/final_icon = get_final_turf_icon(turf)
		final_icon.Scale(minimap_data.minimap_icon_size, minimap_data.minimap_icon_size)
		master.Blend(
			final_icon,
			ICON_OVERLAY,
			(offset_x * minimap_data.minimap_icon_size) + 1,
			(offset_y * minimap_data.minimap_icon_size) + 1,
		)
		CHECK_TICK

	fcopy(master, minimap_data.png_location)
	minimaps_by_z_level["[z]"] = minimap_data
	generating -= z

#ifdef TESTING
	var/finished_at = REALTIMEOFDAY
	var/total_time = finished_at - started_at
	testing("MINIMAP GEN: Z-[z] | [total_time * 0.1] seconds")
#endif

/datum/controller/subsystem/minimap/proc/get_final_turf_icon(turf/turf)
	var/static/list/known_nulls = list()
	if(turf.type in known_nulls)
		return null

	var/icon/turf_icon = getFlatIcon(turf)
	if(turf_icon == null)
		known_nulls += turf.type
		CRASH("getFlatIcon returned a null icon for [turf] ([turf.type]) at [loc_name(turf)]")

	if(isclosedturf(turf))
		return turf_icon

	var/static/list/types_we_care_about = list(
		/obj/structure/grille,
		/obj/structure/window,
		/obj/structure/plasticflaps,
		/obj/machinery/door,
		/obj/machinery/power/solar,
		/obj/machinery/power/solar_control,
	)

	var/list/things_we_care_about = list()
	for(var/atom/movable/thing in turf)
		if(!is_type_in_list(thing, types_we_care_about))
			continue
		things_we_care_about += thing

	for(var/type in types_we_care_about)
		for(var/atom/movable/thing as anything in things_we_care_about)
			if(!istype(thing, type))
				continue
			turf_icon.Blend(getFlatIcon(thing), BLEND_OVERLAY)

	return turf_icon

/datum/controller/subsystem/minimap/proc/do_we_care_about_this_turf(turf/turf)
	return istype(turf.loc, /area/station)

/datum/controller/subsystem/minimap/proc/get_minimap_for(z_level)
	UNTIL(!(z_level in generating))

	if(!("[z_level]" in minimaps_by_z_level))
		generate_minimap_for_z(z_level)
	return minimaps_by_z_level["[z_level]"]
