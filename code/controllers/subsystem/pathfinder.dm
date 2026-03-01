/// Queues and manages JPS pathfinding steps
SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
	priority = FIRE_PRIORITY_PATHFINDING
	wait = 0.5
	/// List of pathfind datums we are currently trying to process
	var/list/datum/pathfind/active_pathing = list()
	/// List of pathfind datums being ACTIVELY processed. exists to make subsystem stats readable
	var/list/datum/pathfind/currentrun = list()
	/// List of uncheccked source_to_map entries
	var/list/currentmaps = list()
	/// Assoc list of target turf -> list(/datum/path_map) centered on the turf
	var/list/source_to_maps = list()
	var/static/space_type_cache

/datum/controller/subsystem/pathfinder/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/pathfinder/stat_entry(msg)
	msg = "P:[length(active_pathing)]"
	return ..()

// This is another one of those subsystems (hey lighting) in which one "Run" means fully processing a queue
// We'll use a copy for this just to be nice to people reading the mc panel
/datum/controller/subsystem/pathfinder/fire(resumed)
	if(!resumed)
		src.currentrun = active_pathing.Copy()
		src.currentmaps = deep_copy_list(source_to_maps)

	// Dies of sonic speed from caching datum var reads
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/pathfind/path = currentrun[length(currentrun)]
		if(!path.search_step()) // Something's wrong
			path.early_exit()
			currentrun.len--
			continue
		if(MC_TICK_CHECK)
			return
		path.finished()
		// Next please
		currentrun.len--

	// Go over our existing pathmaps, clear out the ones we aren't using
	var/list/currentmaps = src.currentmaps
	var/oldest_time = world.time - MAP_REUSE_SLOWEST
	while(length(currentmaps))
		var/turf/source = currentmaps[length(currentmaps)]
		var/list/datum/path_map/owned_maps = currentmaps[source]
		for(var/datum/path_map/map as anything in owned_maps)
			if(map.creation_time < oldest_time && !map.building)
				source_to_maps[source] -= map
			owned_maps.len--
			if(MC_TICK_CHECK)
				return
		if(!length(source_to_maps[source]))
			source_to_maps -= source

		currentmaps.len--

/// Initiates a pathfind. Returns true if we're good, FALSE if something's failed
/datum/controller/subsystem/pathfinder/proc/pathfind(atom/movable/requester, atom/end, max_distance = 30, mintargetdist, access = list(), simulated_only = TRUE, turf/exclude, skip_first = TRUE, diagonal_handling = DIAGONAL_REMOVE_CLUNKY, list/datum/callback/on_finish)
	var/datum/pathfind/jps/path = new()
	path.setup(requester, access, max_distance, simulated_only, exclude, on_finish, end, mintargetdist, skip_first, diagonal_handling)
	if(path.start())
		active_pathing += path
		return TRUE
	return FALSE

/// Initiates a swarmed pathfind. Returns TRUE if we're good, FALSE if something's failed
/// If a valid pathmap exists for the TARGET turf we'll use that, otherwise we have to build a new one
/datum/controller/subsystem/pathfinder/proc/swarmed_pathfind(atom/movable/requester, atom/end, max_distance = 30, mintargetdist = 0, age = MAP_REUSE_INSTANT, access = list(), simulated_only = TRUE, turf/exclude, skip_first = TRUE, list/datum/callback/on_finish)
	var/turf/target = get_turf(end)
	var/datum/can_pass_info/pass_info = new(requester, access)
	// If there's a map we can use already, use it
	var/datum/path_map/valid_map = get_valid_map(pass_info, target, simulated_only, exclude, age, include_building = TRUE)
	if(valid_map && valid_map.expand(max_distance))
		path_map_passalong(on_finish, get_turf(requester), mintargetdist, skip_first, valid_map)
		return TRUE

	// Otherwise we're gonna make a new one, and turn it into a path for the callbacks passed into us
	var/list/datum/callback/pass_in = list()
	pass_in += CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(path_map_passalong), on_finish, get_turf(requester), mintargetdist, skip_first)
	// And to allow subsequent calls to reuse the same map, we'll put a placeholder in the cache, and fill it up when the pathing finishes
	var/datum/path_map/empty = new()
	empty.pass_info = new(requester, access)
	empty.start = target
	empty.pass_space = simulated_only
	empty.avoid = exclude
	empty.building = TRUE
	path_map_cache(target, empty)
	pass_in += CALLBACK(src, PROC_REF(path_map_fill), target, empty)
	if(!SSpathfinder.can_pass_build_map(pass_info, target, max_distance, simulated_only, exclude, pass_in))
		return FALSE
	return TRUE

/// We generate a path for the passed in callbacks, and then pipe it over
/proc/path_map_passalong(list/datum/callback/return_callbacks, turf/target, mintargetdist = 0, skip_first = TRUE, datum/path_map/hand_back)
	var/list/requested_path
	if(istype(hand_back, /datum/path_map))
		requested_path = hand_back.get_path_from(target, skip_first, mintargetdist)
	for(var/datum/callback/return_callback as anything in return_callbacks)
		return_callback.Invoke(requested_path)

/// Caches the passed in path_map, allowing for reuse in future
/datum/controller/subsystem/pathfinder/proc/path_map_cache(turf/target, datum/path_map/hand_back)
	// Cache our path_map
	if(!target || !hand_back)
		return
	source_to_maps[target] += list(hand_back)

/datum/controller/subsystem/pathfinder/proc/path_map_fill(turf/target, datum/path_map/fill_into, datum/path_map/hand_back)
	fill_into.building = FALSE
	if(!fill_into.compare_against(hand_back))
		source_to_maps[target] -= fill_into
		return
	fill_into.copy_from(hand_back)
	fill_into.creation_time = hand_back.creation_time
	// If we aren't in the source list anymore don't go trying to clear it out yeah?
	if(!source_to_maps[target] || !(fill_into in source_to_maps[target]))
		return
	// Let's remove anything we're better than
	for(var/datum/path_map/same_target as anything in source_to_maps[target])
		if(fill_into == same_target || !same_target.compare_against(hand_back))
			continue
		// If it's still being made it'll be fresher then us
		if(same_target.building)
			continue
		// We assume that we are fresher, and that's all we care about
		// If it's being expanded it'll get updated when that finishes, then clear when all the refs drop
		source_to_maps[target] -= same_target

/// Initiates a SSSP run. Returns true if we're good, FALSE if something's failed
/datum/controller/subsystem/pathfinder/proc/build_map(atom/movable/requester, turf/source, max_distance = 30, access = list(), simulated_only = TRUE, turf/exclude, list/datum/callback/on_finish)
	var/datum/pathfind/sssp/path = new()
	path.setup(requester, access, source, max_distance, simulated_only, exclude, on_finish)
	if(path.start())
		active_pathing += path
		return TRUE
	return FALSE

/// Initiates a SSSP run from a pass_info datum. Returns true if we're good, FALSE if something's failed
/datum/controller/subsystem/pathfinder/proc/can_pass_build_map(datum/can_pass_info/pass_info, turf/source, max_distance = 30, simulated_only = TRUE, turf/exclude, list/datum/callback/on_finish)
	var/datum/pathfind/sssp/path = new()
	path.setup_from_canpass(pass_info, source, max_distance, simulated_only, exclude, on_finish)
	if(path.start())
		active_pathing += path
		return TRUE
	return FALSE

/// Begins to handle a pathfinding run based off the input /datum/pathfind datum
/// You should not use this, it exists to allow for shenanigans. You do not know how to do shenanigans
/datum/controller/subsystem/pathfinder/proc/run_pathfind(datum/pathfind/run)
	active_pathing += run
	return TRUE

/// Takes a set of pathfind info, returns the first valid pathmap that would work if one exists
/// Optionally takes a max age to accept (defaults to 0 seconds) and a minimum acceptable range
/// If include_building is true and we can only find a building path, we'll use that instead. tho we will wait for it to finish first
/datum/controller/subsystem/pathfinder/proc/get_valid_map(datum/can_pass_info/pass_info, turf/target, simulated_only = TRUE, turf/exclude, age = MAP_REUSE_INSTANT, min_range = -INFINITY, include_building = FALSE)
	// Walk all the maps that match our requester's turf OR our target's
	// Then hold onto em. If their cache time is short we can reuse/expand them, if not we'll have to make a new one
	var/oldest_time = world.time - age
	/// Backup return value used if no finished pathmaps are found
	var/datum/path_map/constructing
	for(var/datum/path_map/shared_source as anything in source_to_maps[target])
		if(!shared_source.compare_against_args(pass_info, target, simulated_only, exclude))
			continue
		var/max_dist = 0
		if(shared_source.distances.len)
			max_dist = shared_source.distances[shared_source.distances.len]
		if(max_dist < min_range)
			continue
		if(oldest_time > shared_source.creation_time && !shared_source.building)
			continue
		if(shared_source.building)
			if(include_building)
				constructing = constructing || shared_source
			continue

		return shared_source
	if(constructing)
		UNTIL(constructing.building == FALSE)
		return constructing
	return null

/// Takes a set of pathfind info, returns all valid pathmaps that would work
/// Takes an optional minimum range arg
/datum/controller/subsystem/pathfinder/proc/get_valid_maps(datum/can_pass_info/pass_info, turf/target, simulated_only = TRUE, turf/exclude, age = MAP_REUSE_INSTANT, min_range = -INFINITY, include_building = FALSE)
	// Walk all the maps that match our requester's turf OR our target's
	// Then hold onto em. If their cache time is short we can reuse/expand them, if not we'll have to make a new one
	var/list/valid_maps = list()
	var/oldest_time = world.time - age
	for(var/datum/path_map/shared_source as anything in source_to_maps[target])
		if(shared_source.compare_against_args(pass_info, target, simulated_only, exclude))
			continue
		var/max_dist = shared_source.distances[shared_source.distances.len]
		if(max_dist < min_range)
			continue
		if(oldest_time > shared_source.creation_time)
			continue
		if(!include_building && shared_source.building)
			continue
		valid_maps += shared_source
	return valid_maps
