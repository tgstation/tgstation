SUBSYSTEM_DEF(area_spawn)
	name = "Area Spawn"
	flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)

	// Can't be on tile or a neighbor.
	// Usually things where it's important to be sure the players can walk up to them, but aren't dense.
	// See restricted_half_height_objects_list for things that you can also reach over.
	var/list/restricted_objects_list = list(
		/obj/machinery/recharge_station,
		/obj/machinery/door,
		/obj/structure/closet,
		/obj/machinery/disposal/bin,
		/obj/structure/table,
		/obj/structure/stairs,
	)

	// Only Blacklist if on same tile because looks bad, etc, but doesn't need to be reached.
	var/list/restricted_overlap_objects_list = list(
		/obj/item/kirbyplants,
	)

	// Things here in some way act as walls. This is the result of extensive tweaking.
	var/list/allowed_diagonal_objects_list = list(
		/obj/structure/grille,
		/obj/structure/window,
		/obj/machinery/door,
	)

	// Wall mounts ironically are better off being on top of squares with dense things since you can click past them,
	// And dense things aren't on walls. These objects should have normal density logic flipped.
	var/list/flip_density_wall_mount_objects_list = list(
		/obj/machinery,
		/obj/structure/table,
		/obj/structure/rack,
		/obj/item/radio/intercom,
		/obj/structure/noticeboard,
		/obj/structure/sign,
		/obj/structure/extinguisher_cabinet,
	)

	/// Cache of area turf info.
	/// [area/area][stringed of AREA_SPAWN_MODE_*][string of priority #][turf index]
	var/list/list/list/list/turf/area_turf_cache = list()

	/// Non-optional area spawns that failed to find an area.
	var/list/datum/area_spawn/failed_area_spawns = list()

/datum/controller/subsystem/area_spawn/Initialize()
	for(var/iterating_type in subtypesof(/datum/area_spawn))
		var/datum/area_spawn/iterating_area_spawn = new iterating_type
		iterating_area_spawn.try_spawn()
		qdel(iterating_area_spawn)
	clear_cache()

	for(var/iterating_type in subtypesof(/datum/area_spawn_over))
		var/datum/area_spawn_over/iterating_area_spawn_over = new iterating_type
		iterating_area_spawn_over.try_spawn()
		qdel(iterating_area_spawn_over)

	return SS_INIT_SUCCESS

/**
 * Clear the cached tiles for optimization or debugging purposes.
 */
/datum/controller/subsystem/area_spawn/proc/clear_cache()
	LAZYCLEARLIST(area_turf_cache)

/**
 * Process the geometry of an area and cache the candidates.
 *
 * Returns turf candidate list. "[priority]" =
 *
 * Arguments:
 * * area - the area to process
 * * mode - The area_spawn_mode we're getting turfs for.
 */
/datum/controller/subsystem/area_spawn/proc/get_turf_candidates(area/area, mode)
	var/list/list/list/turf/area_turf_info

	// Get area cache or make a new one.
	if(!area_turf_cache[area.type])
		area_turf_info = area_turf_cache[area.type] = list(AREA_SPAWN_MODE_COUNT)
	else
		area_turf_info = area_turf_cache[area.type]

	// Different use cases have different lists of turfs.
	// Get or create the cached list.
	var/list/list/turf/turf_list
	if(area_turf_info["[mode]"])
		return area_turf_info["[mode]"]
	turf_list = area_turf_info["[mode]"] = list()

	// Get highest priority items
	for(var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
		for(var/turf/iterating_turf as anything in zlevel_turfs)
			// Only retain turfs of the highest priority
			var/priority = process_turf(iterating_turf, mode)
			if(priority > 0)
				LAZYADDASSOC(turf_list, "[priority]", list(iterating_turf))

	// Sort the priorities descending
	return sortTim(turf_list, GLOBAL_PROC_REF(cmp_num_string_asc))

/**
 * Process a specific turf and return priority number from 0 to infinity.
 *
 * Turfs with highest priority will be picked. Priority 0 means NEVER.
 *
 * Arguments:
 * * turf - The turf to process
 * * mode - The area_spawn_mode we're getting turfs for.
 */
/datum/controller/subsystem/area_spawn/proc/process_turf(turf/turf, mode)
	// Only spawn on actual floors
	if(!isfloorturf(turf))
		return 0

	// Turf completely empty?
	var/totally_empty = TRUE
	for(var/atom/movable/found_movable in turf)
		if(istype(found_movable, /obj/effect))
			continue

		// Some tile conditions for no-go
		if(mode == AREA_SPAWN_MODE_MOUNT_WALL)
			// Different blacklist logic than normal. See flip_density_wall_mount_objects_list
			var/flip_density = is_type_in_list(found_movable, flip_density_wall_mount_objects_list)
			if(
				found_movable.density != flip_density \
				|| (!flip_density && is_type_in_list(found_movable, restricted_objects_list))
			)
				return 0

			// For wall mounts, we actually don't want to overlap wall items.
			if(found_movable.layer > LOW_OBJ_LAYER)
				totally_empty = FALSE

			continue

		// Every other mode.
		if(
			found_movable.density \
			|| is_type_in_list(found_movable, restricted_objects_list) \
			|| is_type_in_list(found_movable, restricted_overlap_objects_list)
		)
			return 0

		if(found_movable.layer > LOW_OBJ_LAYER && found_movable.layer < ABOVE_MOB_LAYER)
			totally_empty = FALSE

	// Number of directions that have a closed wall
	var/num_walls_found = 0
	// Found a dense object?
	var/found_dense_object = FALSE
	// Number of directions that have anything dense
	var/num_dense_found = 0
	// Number of directions that have 2 squares of open space.
	var/num_very_open_floors = 0
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor_turf = get_step(turf, dir)
		if(isclosedturf(neighbor_turf))
			num_walls_found++
			num_dense_found++
			continue
		if(mode == AREA_SPAWN_MODE_HUG_WALL)
			var/turf/long_test_turf = get_step(neighbor_turf, dir)
			if(isopenturf(long_test_turf))
				num_very_open_floors++
		for(var/atom/movable/found_movable in neighbor_turf)
			if(istype(found_movable, /obj/effect))
				continue

			if(found_movable.density || is_type_in_list(found_movable, restricted_objects_list))
				found_dense_object = TRUE
				num_dense_found++
				break

	// Wall hugging also, as a low priority, doesn't even want diagonal things.
	var/num_diagonal_objects = 0
	if(mode == AREA_SPAWN_MODE_HUG_WALL)
		for(var/dir in GLOB.diagonals)
			var/turf/neighbor_turf = get_step(turf, dir)
			for(var/atom/movable/found_movable in neighbor_turf)
				if(istype(found_movable, /obj/effect))
					continue

				if(
					!is_type_in_list(found_movable, allowed_diagonal_objects_list) \
					&& (found_movable.density || is_type_in_list(found_movable, restricted_objects_list))
				)
					num_diagonal_objects++
					break

	switch(mode)
		if(AREA_SPAWN_MODE_OPEN)
			// For non-wall hug
			// #1 priority is totally empty
			// #2 priority is being in the middle of the room
			return (totally_empty ? 10 : 0) + (4 - num_dense_found)

		if(AREA_SPAWN_MODE_HUG_WALL)
			// For wall hugging, must be against wall, and not touching another dense object as it may completely block it.
			if(num_walls_found == 0 || found_dense_object || num_walls_found == 4)
				return 0

			// #1 Priority after that: be in a totally empty square
			// #2 (marginally) have clear diagnals
			// #3 favor being in a cozy wall nook
			// #4 be in a big room/hallway so we don't pinch a room down to 1 square of passage.
			return (totally_empty ? 1000 : 0) + (400 - num_diagonal_objects * 100) + (num_walls_found * 10) + num_very_open_floors

		if(AREA_SPAWN_MODE_MOUNT_WALL)
			// For mounting to walls. Must be against wall.
			if(num_walls_found == 0 || num_walls_found == 4)
				return 0

			// #1 Priority after that: be in a totally empty square
			// #2, actually don't be in a nook!
			return (totally_empty ? 10 : 0) + (4 - num_walls_found)

	CRASH("Invalid area spawn mode [mode]!")

/**
 * Pick a turf candidate and remove from the list.
 *
 * Only picks one of the highest priority ones.
 *
 * Arguments:
 * * turf_candidates - Turf candidate list produced by
 */
/datum/controller/subsystem/area_spawn/proc/pick_turf_candidate(list/list/turf/turf_candidates)
	// Pick-n-take highest priority.
	var/list/turf/sublist = turf_candidates[peek(turf_candidates)]
	var/turf/winner = pick_n_take(sublist)

	// To be safe, remove the neighbors too.
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(winner, dir)
		sublist -= neighbor

	// Remove this priority if it's now empty.
	if(!LAZYLEN(sublist))
		pop(turf_candidates)

	// Extremely specific, but landmarks are immediately destroyed when created so can't be detected another way.
	// This is the only landmark list that normally creates solid objects in non-maintenance spaces.
	GLOB.secequipment -= winner

	return winner

/**
 * Area spawn datums
 *
 * Use these to spawn atoms in areas instead of placing them on a map. It will select any available open and entering turf.
 */
/datum/area_spawn
	/// The target area for us to spawn the desired atom, the list is formatted, highest priority first.
	var/list/target_areas
	/// The atom that we want to spawn
	var/desired_atom
	/// The amount we want to spawn
	var/amount_to_spawn = 1
	/// See code/__DEFINES/~doppler_defines/automapper.dm
	var/mode = AREA_SPAWN_MODE_OPEN
	/// Map blacklist, this is used to determine what maps we should not spawn on.
	var/list/blacklisted_stations = list("Void Raptor", "Ouroboros", "Snowglobe Station", "Runtime Station", "MultiZ Debug", "Gateway Test", "Blueshift", "SerenityStation")
	/// If failing to find a suitable area is OK, then this should be TRUE or CI will fail.
	/// Should probably be true if the target_areas are random, such as ruins.
	var/optional = FALSE

/**
 * Attempts to find a location using an algorithm to spawn the desired atom.
 */
/datum/area_spawn/proc/try_spawn()
	if(SSmapping.current_map.map_name in blacklisted_stations)
		return

	// Turfs that are available
	var/list/available_turfs

	for(var/area_type in target_areas)
		var/area/found_area = GLOB.areas_by_type[area_type]
		if(isnull(found_area))
			continue
		available_turfs = SSarea_spawn.get_turf_candidates(found_area, mode)
		if(LAZYLEN(available_turfs))
			break

	if(!LAZYLEN(available_turfs))
		if(!optional)
			log_mapping("[src.type] could not find any suitable turfs on map [SSmapping.current_map.map_name]!")
			SSarea_spawn.failed_area_spawns += list(list(src.type = SSmapping.current_map.map_name))
		return

	for(var/i in 1 to amount_to_spawn)
		var/turf/candidate_turf = SSarea_spawn.pick_turf_candidate(available_turfs)

		var/final_desired_atom = desired_atom

		if(mode == AREA_SPAWN_MODE_MOUNT_WALL)
			// For wall mounts, we have to find the wall and spawn the right directional.
			for(var/dir in GLOB.cardinals)
				var/turf/neighbor_turf = get_step(candidate_turf, dir)
				if(isopenturf(neighbor_turf))
					continue

				final_desired_atom = text2path("[desired_atom]/directional/[dir2text(dir)]")
				break

		new final_desired_atom(candidate_turf)

/**
 * Spawns an atom on any turf that contains specific over atoms.
 */
/datum/area_spawn_over
	/// The target area types for us to search for the over_atoms.
	var/list/target_areas
	/// The list of atom types to spawn the desired atom over.
	var/list/over_atoms
	/// The atom type that we want to spawn
	var/desired_atom
	/// Map blacklist, this is used to determine what maps we should not spawn on.
	var/list/blacklisted_stations = list("Void Raptor", "Runtime Station", "MultiZ Debug", "Gateway Test")

/**
 * Spawn the atoms.
 */
/datum/area_spawn_over/proc/try_spawn()
	if(SSmapping.current_map.map_name in blacklisted_stations)
		return

	for(var/area_type in target_areas)
		var/area/found_area = GLOB.areas_by_type[area_type]
		if(!found_area)
			continue

		for(var/list/zlevel_turfs as anything in found_area.get_zlevel_turf_lists())
			for(var/turf/candidate_turf as anything in zlevel_turfs)
				// Don't spawn if there's already a desired_atom here.
				if(is_type_on_turf(candidate_turf, desired_atom))
					continue

				for(var/over_atom_type in over_atoms)
					// Spawn on the first one we find in the turf and stop.
					if(is_type_on_turf(candidate_turf, over_atom_type))
						new desired_atom(candidate_turf)
						// Break the over_atom_type loop.
						break

/obj/effect/turf_test
	name = "PASS"
	icon = 'modular_doppler/automapper/icons/area_test.dmi'
	icon_state = "area_test"
	color = COLOR_BLUE
	anchored = TRUE
	layer = LOW_OBJ_LAYER

/**
 * Show overlay over area of priorities. Wall priority over open priority.
 */
ADMIN_VERB(test_area_spawner, R_DEBUG, "Test Area Spawner", "Show area spawner placement candidates as an overlay.", ADMIN_CATEGORY_DEBUG, area/area)
	for(var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/effect/turf_test/old_test in area_turf)
				qdel(old_test)

	SSarea_spawn.clear_cache()
	for(var/mode in 0 to AREA_SPAWN_MODE_COUNT - 1)
		var/list/list/turf/mode_candidates = SSarea_spawn.get_turf_candidates(area, mode)

		for(var/priority in mode_candidates)
			var/list/turf/turfs = mode_candidates[priority]
			for(var/turf/turf as anything in turfs)
				var/obj/overlay = new /obj/effect/turf_test(turf)
				overlay.maptext = MAPTEXT(priority)
				overlay.maptext_y = mode * 10
