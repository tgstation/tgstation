#define FLOW_PATH_END 1
/// Datum that describes the shortest path between a source turf and any turfs within a distance
/datum/path_map
	/// Assoc list of turf -> the turf one step closer on the path
	/// Arranged in discovery order, so the last turf here will be the furthest from the start
	var/list/next_closest = list()
	/// List of distances from the starting turf, each index lines up with the next_closest list
	var/list/distances = list()
	/// Our starting turf, the location this map feeds into
	var/turf/start
	/// The tick we were completed on, in case you want to hold onto this for a bit
	var/creation_time
	/// The pass info datum used to create us
	var/datum/can_pass_info/pass_info
	/// Were we allowed to path over space?
	var/pass_space = TRUE
	/// Were we avoiding a turf? If so, which one?
	var/turf/avoid
	/// Are we currently being expanded?
	var/expanding = FALSE
	/// Are we currently being built
	var/building = FALSE

/// Gets a list of turfs reachable by this path_map from the distance first to the distance second, both inclusive
/// first > second or first < second are both respected, and the return order will reflect the arg order
/// We return a list of turf -> distance, or null if we error
/datum/path_map/proc/turfs_in_range(first, second)
	var/list/hand_back = list()
	var/list/distances = src.distances
	var/smaller = min(first, second)
	var/larger = max(first, second)
	var/largest_dist = distances[length(distances)]
	if(smaller < 0 || larger < 0 || largest_dist < larger || largest_dist < smaller)
		return null
	if(first == smaller)
		for(var/i in 1 to length(distances))
			if(i > larger)
				break
			if(i >= smaller)
				hand_back[next_closest[i]] = distances[i]
	else
		for(var/i in length(distances) to 1 step -1)
			if(i < smaller)
				break
			if(i <= larger)
				hand_back[next_closest[i]] = distances[i]

	return hand_back

/**
 * Takes a turf to path to, returns the shortest path to it at the time of this datum's creation
 *
 * skip_first - If we should drop the first step in the path. Used to avoid stepping where we already are
 * min_target_dist - How many, if any, turfs off the end of the path should we drop?
 */
/datum/path_map/proc/get_path_to(turf/path_to, skip_first = FALSE, min_target_dist = 0)
	return generate_path(path_to, skip_first, min_target_dist)

/**
 * Takes a turf to start from, returns a path to the source turf of this datum
 *
 * skip_first - If we should drop the first step in the path. Used to avoid stepping where we already are
 * min_target_dist - How many, if any, turfs off the end of the path should we drop?
 */
/datum/path_map/proc/get_path_from(turf/path_from, skip_first = FALSE, min_target_dist = 0)
	return generate_path(path_from, skip_first, min_target_dist, reverse = TRUE)

/**
 * Takes a turf to use as the other end, returns the path between the source node and it
 *
 * skip_first - If we should drop the first step in the path. Used to avoid stepping where we already are
 * min_target_dist - How many, if any, turfs off the end of the path should we drop?
 * reverse - If true, "reverses" the path generated. You'd want to use this for generating a path to the source node itself
 */
/datum/path_map/proc/generate_path(turf/other_end, skip_first = FALSE, min_target_dist = 0, reverse = FALSE)
	var/list/path = list()
	var/turf/next_turf = other_end
	// Cache for sonic speed
	var/next_closest = src.next_closest
	while(next_turf != FLOW_PATH_END || next_turf == null)
		path += next_turf
		next_turf = next_closest[next_turf] // We take the first entry cause that's the turf

	// This makes sense from a consumer level, I hate double negatives too I promise
	if(!reverse)
		path = reverseList(path)
	if(skip_first && length(path) > 0)
		path.Cut(1,2)
	if(min_target_dist)
		path.Cut(length(path) + 1 - min_target_dist, length(path) + 1)
	return path

/datum/path_map/proc/display(delay = 10 SECONDS)
	for(var/index in 1 to length(distances))
		var/turf/next_turf = next_closest[index]
		next_turf.maptext = "[distances[index]]"
		next_turf.color = COLOR_NAVY
		animate(next_turf, color = null, delay)
		animate(maptext = "", world.tick_lag)

/// Copies the passed in path_map into this datum
/// Saves some headache with updating refs if we want to modify a path_map
/datum/path_map/proc/copy_from(datum/path_map/read_from)
	// Copy all the relevant vars over. NOT any of the timer stuff, we want them to still count
	src.next_closest = read_from.next_closest
	src.distances = read_from.distances
	src.start = read_from.start
	src.pass_info = read_from.pass_info
	src.pass_space = read_from.pass_space
	src.avoid = read_from.avoid

/// Returns true if the passed in pass_map's pass logic matches ours
/// False otherwise
/datum/path_map/proc/compare_against(datum/path_map/map)
	return compare_against_args(map.pass_info, map.start, map.pass_space, map.avoid)

/// Returns true if the passed in pass_info and start/pass_space/avoid match ours
/// False otherwise
/datum/path_map/proc/compare_against_args(datum/can_pass_info/pass_info, turf/start, pass_space, turf/avoid)
	if(src.start != start)
		return FALSE
	if(src.pass_space != pass_space)
		return FALSE
	if(src.avoid != avoid)
		return FALSE

	return pass_info.compare_against(pass_info)


/// Returns a new /datum/pathfind/sssp based off our settings
/// Will have an invalid source mob, no max distance, and no ending callback
/datum/path_map/proc/settings_to_path()
	// Default creation to not set any vars incidentally
	var/static/mob/jeremy = new()
	var/datum/pathfind/sssp/based_on_what = new()
	based_on_what.setup(pass_info, null, INFINITY, pass_space, avoid)
	return based_on_what

/// Expands this pathmap to cover a new range, assuming the arg is greater then the current range
/// Returns true if this succeeded or was not required, false otherwise
/datum/path_map/proc/expand(new_range)
	var/list/working_distances = distances
	var/working_index = working_distances.len
	var/max_dist = working_distances[working_distances.len]
	if(new_range <= max_dist)
		return TRUE

	UNTIL(expanding == FALSE)
	// In case max_dist has changed ya feel
	if(new_range <= max_dist)
		return TRUE

	// Walk the start point backwards until we're at the first turf at the max distance
	while(working_distances[working_index] == max_dist)
		working_index -= 1

	var/list/hand_around = list()
	// We're guaranteed that hand_around will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around)

	// We're gonna build a pathfind datum from our settings and set it running
	var/datum/pathfind/sssp/based_off_us = new()

	based_off_us.setup_from_canpass(pass_info, start, new_range, pass_space, avoid, list(await))
	based_off_us.working_queue = next_closest.Copy()
	based_off_us.working_distances = working_distances.Copy()
	based_off_us.working_index = working_index
	if(!SSpathfinder.run_pathfind(based_off_us))
		return FALSE

	expanding = TRUE
	UNTIL(length(hand_around))
	var/datum/path_map/return_val = hand_around[1]
	if(!istype(return_val, /datum/path_map)) // It's trash, we've failed and need to clear away
		return FALSE
	copy_from(return_val)
	expanding = FALSE
	return TRUE

/datum/path_map/proc/sanity_check()
	for(var/index in 1 to length(distances))
		var/turf/next_turf = next_closest[index]
		var/list/path = get_path_from(next_turf)
		if(length(path) != distances[index] + 1)
			stack_trace("[next_turf] had a distance of [length(path)] instead of the expected [distances[index]]")
		if(path.Find(next_turf) != 1)
			stack_trace("Starting turf [next_turf] was not the first entry in its list (instead it's at [path.Find(next_turf)])")
		path = get_path_to(next_turf)
		if(length(path) != distances[index] + 1)
			stack_trace("[next_turf] had a distance of [length(path)] instead of the expected [distances[index]]")
		if(path.Find(next_turf) != length(path))
			stack_trace("Starting turf [next_turf] was not the last entry in its list (instead it's at [path.Find(next_turf)])")

/// Single source shortest path
/// Generates a flow map of a reachable turf -> the turf next closest to the map's center
/datum/pathfind/sssp
	/// Ever expanding list of turfs to visit/visited, associated with the turf that's next closest to them
	var/list/working_queue
	/// List of distances, each entry mirrors an entry in the working_queue
	var/list/working_distances
	/// Our current position in the working queue
	var/working_index

/datum/pathfind/sssp/proc/setup(atom/movable/requester, list/access, turf/center, max_distance, simulated_only, turf/avoid, list/datum/callback/on_finish)
	src.pass_info = new(requester, access)
	src.start = center
	src.max_distance = max_distance
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.on_finish = on_finish

/datum/pathfind/sssp/proc/setup_from_canpass(datum/can_pass_info/info, turf/center, max_distance, simulated_only, turf/avoid, list/datum/callback/on_finish)
	src.pass_info = info
	src.start = center
	src.max_distance = max_distance
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.on_finish = on_finish

/datum/pathfind/sssp/start()
	. = ..()
	if(!.)
		return .
	working_queue = list()
	working_distances = list()
	working_queue[start] = FLOW_PATH_END
	working_distances += 0
	working_index = 0
	return TRUE

/datum/pathfind/sssp/search_step()
	. = ..()
	if(!.)
		return .

	var/datum/can_pass_info/pass_info = src.pass_info
	while(working_index < length(working_queue))
		working_index += 1

		var/turf/next_turf = working_queue[working_index]
		var/distance = working_distances[working_index] + 1
		if(distance > max_distance)
			if(TICK_CHECK)
				return TRUE
			continue
		for(var/turf/adjacent in TURF_NEIGHBORS(next_turf))
			// Already have a path? then we're gooood baby
			if(working_queue[adjacent])
				continue

			// If it's blocked, go home
			if(!CAN_STEP(next_turf, adjacent, simulated_only, pass_info, avoid))
				continue
			// I want to prevent diagonal moves around corners
			// We do this first because blocked diagonals are more common then non blocked ones.
			if(next_turf.x != adjacent.x && next_turf.y != adjacent.y)
				var/movement_dir = get_dir(next_turf, adjacent)
				// If either of the move components would bump into something, replace it with an explicit move around
				var/turf/vertical_move = get_step(next_turf, movement_dir & (NORTH|SOUTH))
				var/turf/horizontal_move = get_step(next_turf, movement_dir & (EAST|WEST))
				if(!working_queue[vertical_move])
					if(CAN_STEP(next_turf, vertical_move, simulated_only, pass_info, avoid))
						working_queue[vertical_move] = next_turf
						working_distances += distance
					else
						// Can't do a vertical move? let's do a horizontal move first
						if(!working_queue[horizontal_move])
							working_queue[horizontal_move] = next_turf
							working_distances += distance
						continue
				if(!working_queue[horizontal_move])
					if(CAN_STEP(next_turf, horizontal_move, simulated_only, pass_info, avoid))
						working_queue[horizontal_move] = next_turf
						working_distances += distance
					else
						if(!working_queue[vertical_move])
							working_queue[vertical_move] = next_turf
							working_distances += distance
						continue

			// Otherwise, this new turf's next closest turf is our source, so we'll mark as such and continue
			// This is a breadth first search, we're essentially moving out in layers from the start position
			working_queue[adjacent] = next_turf
			working_distances += distance

		if(TICK_CHECK)
			return TRUE
	return TRUE

/datum/pathfind/sssp/finished()
	var/datum/path_map/flow_map = new()
	flow_map.start = start
	flow_map.pass_info = pass_info
	flow_map.pass_space = simulated_only
	flow_map.avoid = avoid
	flow_map.next_closest = working_queue
	flow_map.distances = working_distances
	flow_map.creation_time = world.time
	hand_back(flow_map)
	return ..()
