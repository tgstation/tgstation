SUBSYSTEM_DEF(minimap)
	name = "Minimap"
	init_order = INIT_ORDER_MINIMAP
	runlevels = ALL
	wait = 1
	priority = FIRE_PRIORITY_MINIMAP
	/// The list of minimaps that have been generated
	var/list/datum/minimap_data/minimaps_by_z_level = list()
	/// The list of minimaps pending generation
	var/list/datum/minimap_generation_cache/to_generate = list()
	/// The master datum for the minimap we are currently generating
	var/datum/minimap_generation_cache/generating
	/// The current section we are processing
	var/datum/minimap_generation_section/current_section
	/// The current run of turfs we are processing
	var/list/turf/current_run
	/// Have we announced to world that round start is pending minimap generation?
	var/announced_start_delay = FALSE

/datum/minimap_section
	var/x
	var/y
	var/z
	var/width
	var/height
	var/png_path

/datum/minimap_data
	var/z_level
	var/save_location

	var/tile_offset_x = 0 //! World offset for the lowest x value of the tiles
	var/tile_offset_y = 0 //! World offset for the lowest y value of the tiles
	var/tile_width = 0 //! Total number of tiles in the x direction
	var/tile_height = 0 //! Total number of tiles in the y direction
	var/section_width = 0 //! Number of tiles in a section in the x direction
	var/section_height = 0 //! Number of tiles in a section in the y direction
	var/section_columns = 0 //! Number of sections in the x direction
	var/section_rows = 0 //! Number of sections in the y direction

	var/datum/asset/simple/minimap_asset //! Asset of the minimap, registered on finalization

/datum/minimap_data/proc/save_persistence_data()
	text2file(json_encode(list(
		"map_config_key" = SSmapping.config.config_filename,
		"z_level" = z_level,
		"save_location" = save_location,
		"tile_offset_x" = tile_offset_x,
		"tile_offset_y" = tile_offset_y,
		"tile_width" = tile_width,
		"tile_height" = tile_height,
		"section_width" = section_width,
		"section_height" = section_height,
		"section_columns" = section_columns,
		"section_rows" = section_rows,
		"asset_paths" = json_encode(minimap_asset.assets),
	)), "[save_location]/persistence.json")

/datum/minimap_data/proc/try_load_persistence_data()
	var/persistence_raw = file2text("[save_location]/persistence.json")
	if(!length(persistence_raw))
		return FALSE

	var/list/persistence_data = json_decode(persistence_raw)
	if(!length(persistence_data))
		return FALSE
	if(persistence_data["map_config_key"] != SSmapping.config.config_filename)
		return FALSE
	if(persistence_data["save_location"] != save_location)
		return FALSE

	z_level = persistence_data["z_level"]
	save_location = persistence_data["save_location"]
	tile_offset_x = persistence_data["tile_offset_x"]
	tile_offset_y = persistence_data["tile_offset_y"]
	tile_width = persistence_data["tile_width"]
	tile_height = persistence_data["tile_height"]
	section_width = persistence_data["section_width"]
	section_height = persistence_data["section_height"]
	section_columns = persistence_data["section_columns"]
	section_rows = persistence_data["section_rows"]
	minimap_asset = new /datum/asset/simple
	minimap_asset.assets = json_decode(persistence_data["asset_paths"])
	minimap_asset.register()
	return TRUE

/// Holds information used for generating a minimap.
/datum/minimap_generation_cache
	var/started_at //! When the generation of the minimap was queued
	var/list/datum/minimap_generation_section/sections
	var/datum/minimap_generation_section/current_section

	var/datum/minimap_data/data //! The data for the minimap

/datum/minimap_generation_section
	var/section_x
	var/section_y
	var/icon/section_blank
	var/list/section_turfs = list()

/datum/controller/subsystem/minimap/Initialize()
	for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		generate_minimap_for_z(z_level, allow_persistence_recovery = TRUE)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/minimap/Recover()
	minimaps_by_z_level = SSminimap.minimaps_by_z_level
	to_generate = SSminimap.to_generate
	generating = SSminimap.generating
	current_section = SSminimap.current_section
	current_run = SSminimap.current_run

/datum/controller/subsystem/minimap/stat_entry(msg)
	. = ..()
	if(isnull(generating))
		return .
	return . + "S:[current_section.section_x],[current_section.section_y]|CR:[length(current_run)]"

/// Generates a minimap for the given z level. Does not block and will generate the minimap in the background.
/datum/controller/subsystem/minimap/proc/generate_minimap_for_z(z, allow_persistence_recovery = FALSE)
	set waitfor = FALSE
	PRIVATE_PROC(TRUE)

	var/map_name = splittext(lowertext(SSmapping.config.map_name), " ").Join("-")
	var/datum/minimap_data/minimap_data = new
	minimap_data.z_level = z
	minimap_data.save_location = "data/minimaps/[map_name]_z-[z]"

	if(allow_persistence_recovery && minimap_data.try_load_persistence_data())
		minimaps_by_z_level["[z]"] = minimap_data
		return TRUE

	if(generating && generating.data.z_level == z)
		return TRUE

	for(var/datum/minimap_generation_cache/cache as anything in to_generate)
		if(cache.data.z_level != z)
			continue
		return TRUE

	var/datum/minimap_generation_cache/cache = new
	cache.data = minimap_data
	fdel("[cache.data.save_location]/")

	var/list/all_turfs = list()
	var/lowest_x = world.maxx
	var/lowest_y = world.maxy
	var/highest_x = 1
	var/highest_y = 1
	for(var/turf/turf as anything in Z_TURFS(z))
		if(!do_we_care_about_this_turf(turf))
			continue
		all_turfs += turf
		if(turf.x < lowest_x)
			lowest_x = turf.x
		else if(turf.x > highest_x)
			highest_x = turf.x
		if(turf.y < lowest_y)
			lowest_y = turf.y
		else if(turf.y > highest_y)
			highest_y = turf.y

	cache.data.tile_offset_x = lowest_x
	cache.data.tile_offset_y = lowest_y
	cache.data.tile_width = (highest_x - lowest_x) + 1
	cache.data.tile_height = (highest_y - lowest_y) + 1
	cache.data.section_width = cache.data.tile_width
	cache.data.section_height = cache.data.tile_height

	var/section_pixel_width = cache.data.section_width * world.icon_size
	var/section_pixel_height = cache.data.section_height * world.icon_size

	while(section_pixel_width > 2048)
		cache.data.section_width = ROUND_UP(cache.data.section_width * 0.5)
		section_pixel_width = cache.data.section_width * world.icon_size
	cache.data.section_columns = ROUND_UP(cache.data.tile_width / cache.data.section_width)

	while(section_pixel_height > 2048)
		cache.data.section_height = ROUND_UP(cache.data.section_height * 0.5)
		section_pixel_height = cache.data.section_height * world.icon_size
	cache.data.section_rows = ROUND_UP(cache.data.tile_height / cache.data.section_height)

	var/list/datum/minimap_generation_section/indexable_sections = new /list(cache.data.section_columns)
	var/list/sections = list()
	for(var/section_x in 1 to cache.data.section_columns)
		indexable_sections[section_x] = new /list(cache.data.section_rows)
		for(var/section_y in 1 to cache.data.section_rows)
			var/datum/minimap_generation_section/section = new
			section.section_x = section_x
			section.section_y = section_y
			section.section_blank = icon('icons/blanks/32x32.dmi', "nothing")
			section.section_blank.Scale(section_pixel_width, section_pixel_height)
			indexable_sections[section_x][section_y] = section
			sections += section

	for(var/turf/turf as anything in all_turfs)
		var/relative_x = (turf.x - cache.data.tile_offset_x) + 1
		var/relative_y = (turf.y - cache.data.tile_offset_y) + 1
		var/section_x = ROUND_UP(relative_x / cache.data.section_width)
		var/section_y = ROUND_UP(relative_y / cache.data.section_height)
		indexable_sections[section_x][section_y].section_turfs += turf
	cache.sections = sections

#ifdef TESTING
	cache.started_at = REALTIMEOFDAY
#endif

	to_generate += cache
	can_fire = TRUE
	return TRUE

/datum/controller/subsystem/minimap/fire(resumed)
	if(isnull(generating))
		if(length(to_generate) == 0)
			can_fire = FALSE
			return
		generating = to_generate[1]
		to_generate -= generating

	if(isnull(current_section))
		if(length(generating.sections) == 0)
			finalize()
			return
		current_section = generating.sections[1]
		generating.sections.Cut(1, 2)
		src.current_run = current_section.section_turfs

	var/list/current_run = src.current_run
	var/icon/section_blank = current_section.section_blank
	var/section_x = current_section.section_x
	var/section_y = current_section.section_y
	testing("MINIMAP GEN | [generating.data.z_level] | [current_section.section_x],[current_section.section_y] | [length(current_run)] turfs")
	while(length(current_run))
		var/turf/turf = current_run[1]
		current_run.Cut(1, 2)
		var/relative_x = (turf.x - generating.data.tile_offset_x) + 1
		var/relative_y = (turf.y - generating.data.tile_offset_y) + 1
		var/section_relative_x = relative_x - ((section_x - 1) * generating.data.section_width)
		var/section_relative_y = relative_y - ((section_y - 1) * generating.data.section_height)
		var/section_pixel_x = ((section_relative_x - 1) * world.icon_size) + 1
		var/section_pixel_y = ((section_relative_y - 1) * world.icon_size) + 1
		section_blank.Blend(get_final_turf_icon(turf), ICON_OVERLAY, section_pixel_x, section_pixel_y)
		if(MC_TICK_CHECK)
			return
	finalize_section()

/datum/controller/subsystem/minimap/proc/finalize()
#ifdef TESTING
	testing("MINIMAP GEN | [generating.data.z_level] | DONE | [(REALTIMEOFDAY - generating.started_at) * 0.1]s")
#endif

	generating.data.minimap_asset = new /datum/asset/simple
	for(var/section_x in 1 to generating.data.section_columns)
		for(var/section_y in 1 to generating.data.section_rows)
			var/minimap_section_name = "minimap_[section_x]-[section_y]_z[generating.data.z_level].png"
			generating.data.minimap_asset.assets[SANITIZE_FILENAME(minimap_section_name)] = "[generating.data.save_location]/[section_x],[section_y].png"
	generating.data.minimap_asset.register()

	minimaps_by_z_level["[generating.data.z_level]"] = generating.data
	generating.data.save_persistence_data()
	generating.data = null
	generating = null

/datum/controller/subsystem/minimap/proc/finalize_section()
	var/section_png = "[generating.data.save_location]/[current_section.section_x],[current_section.section_y].png"
	fcopy(current_section.section_blank, section_png)
	current_section = null

/datum/controller/subsystem/minimap/proc/get_final_turf_icon(turf/turf)
	var/static/list/known_nulls = list()
	if(turf.type in known_nulls)
		return null

	var/icon/turf_icon = getFlatIcon(turf, no_anim = TRUE)
	if(turf_icon == null)
		known_nulls += turf.type
		CRASH("getFlatIcon returned a null icon for [turf] ([turf.type]) at [loc_name(turf)]")

	var/list/things_we_care_about = list()
	for(var/obj/thing in turf)
		switch(thing.minimap_render)
			if(MINIMAP_RENDER_NEVER)
				continue
			if(MINIMAP_RENDER_NORMAL)
				if(thing.invisibility > SEE_INVISIBLE_LIVING)
					continue
		things_we_care_about += thing

#ifdef TESTING
		var/drew_window = FALSE
		var/drew_door = FALSE
#endif

		var/list/sorted_things = sort_list(things_we_care_about, GLOBAL_PROC_REF(cmp_obj_minimap_priority))
		for(var/thing_we_care_about in sorted_things)
			var/thing_icon = getFlatIcon(thing_we_care_about, no_anim = TRUE)
			if(thing_icon == null)
				continue
			turf_icon.Blend(thing_icon, ICON_OVERLAY)

#ifdef TESTING
			if(istype(thing_we_care_about, /obj/structure/grille) && (drew_window || drew_door))
				stack_trace("drew a grille after we drew a window or door!")
			else if(istype(thing_we_care_about, /obj/machinery/door))
				drew_door = TRUE
			else if(istype(thing_we_care_about, /obj/structure/window))
				drew_window = TRUE
#endif

	return turf_icon

/proc/cmp_obj_minimap_priority(obj/left, obj/right)
	if(left.minimap_priority != right.minimap_priority)
		return left.minimap_priority - right.minimap_priority
	if(left.plane != right.plane)
		return left.plane - right.plane
	return left.layer - right.layer

/datum/controller/subsystem/minimap/proc/do_we_care_about_this_turf(turf/turf)
	return istype(turf.loc, /area/station) || istype(turf.loc, /area/space/nearstation)

/// Get the minimap data for the given z level. If it does not exist or is still generating, block for it.
/datum/controller/subsystem/minimap/proc/get_minimap_data(z_level)
	start_generating_minimap_for(z_level)
	UNTIL(. = poll_for_minimap_data(z_level))

/datum/controller/subsystem/minimap/proc/poll_for_minimap_data(z_level)
	return minimaps_by_z_level["[z_level]"]

/datum/controller/subsystem/minimap/proc/start_generating_minimap_for(z_level)
	return generate_minimap_for_z(z_level)

/datum/controller/subsystem/minimap/proc/are_station_minimaps_done(from_ssticker = FALSE)
	var/all_done = TRUE
	for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		if(!poll_for_minimap_data(z_level))
			all_done = FALSE
			break

	if(all_done)
		return TRUE
	if(!from_ssticker || announced_start_delay)
		return FALSE

	announced_start_delay = TRUE
	to_chat(world, span_boldannounce("Station Minimap generation is still in progress. Round start is delaying until it is done. Admins can bypass this delay using '[/datum/admins/proc/startnow::name]'."))
	return FALSE

/datum/controller/subsystem/minimap/ui_state(mob/user)
	return GLOB.always_state
