/*
 * JPS (Jump Point Search) over the cached navmesh. Structural port of code/__HELPERS/paths/jps.dm,
 * with CAN_STEP swapped for the NAV_CAN_STEP macro (cached bit read instead of LinkBlockedWithAccess).
 * Standalone: no SSpathfinder queue, no tick-chunking, no async callback. Synchronous, like nav_find_path.
 *
 * Why JPS instead of plain A* here: plain grid A* over the navmesh (nav_astar.dm) made every edge
 * check cheap, but on open floor it still visits ~every tile in the search radius, so node-bookkeeping
 * (heap ops, heuristic recompute) dominates and it loses to JPS despite the cache. JPS's jump-scanning
 * skips almost all of those tiles, so pairing it with the cheap cached edge check attacks BOTH costs.
 *
 * Deviation from the original: the original JPS is a /datum/pathfind/jps method set, so unwind_path()
 * can stash the finished path as a side effect on `src` from anywhere in the call stack (lateral scan,
 * diag scan, or a diag's lateral subscan can all set it). This port uses plain procs with no shared
 * datum, so a one-element list `path_box` is threaded through every call instead: path_box[1] is the
 * finished path once found. Every scan checks path_box[1] at loop entry and bails immediately once
 * set, matching the original's `if(path) return` guard.
 */

/// Node datum. No Destroy()/qdel: same reasoning as /datum/nav_node in nav_astar.dm (scoped to one
/// search, no signals/timers, GC'd when the search's own lists fall out of scope).
/datum/nav_jps_node
	var/turf/tile
	var/datum/nav_jps_node/previous_node
	var/f_value
	var/heuristic
	/// Steps taken from start to here (== cost; JPS jumps all cost 1 per tile like cardinal moves).
	var/number_tiles
	/// Steps taken from previous_node to here.
	var/jumps
	var/turf/node_goal

/datum/nav_jps_node/New(turf/our_tile, datum/nav_jps_node/incoming_previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goal) // first/starting node
		node_goal = incoming_goal
	else if(incoming_previous_node) // direct lateral/diagonal scan result, fill out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist_euclidean(tile, node_goal)
		f_value = number_tiles + heuristic
	// else: subscan lateral result awaiting update_parent()

/datum/nav_jps_node/proc/update_parent(datum/nav_jps_node/new_parent)
	previous_node = new_parent
	node_goal = previous_node.node_goal
	jumps = get_dist(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = get_dist_euclidean(tile, node_goal)
	f_value = number_tiles + heuristic

/proc/nav_jps_heap_compare(datum/nav_jps_node/a, datum/nav_jps_node/b)
	return b.f_value - a.f_value

/**
 * Find a path from `start` to `goal` for `pass_info`, using JPS jump-scanning over the cached navmesh.
 * Synchronous, single-z. Returns an ordered list of turfs (start-exclusive), or an empty list.
 */
/proc/nav_jps_find_path(turf/start, turf/goal, datum/can_pass_info/pass_info, max_distance = 30, mintargetdist = 0)
	if(!start || !goal || !pass_info)
		return list()
	if(start.z != goal.z || start == goal)
		return list()
	if(max_distance && get_dist(start, goal) > max_distance)
		return list()

	var/is_flying = NAV_IS_FLYING(pass_info)
	var/datum/heap/open = new /datum/heap(GLOBAL_PROC_REF(nav_jps_heap_compare))
	var/list/found_turfs = list()
	/// One-element out-param: path_box[1] becomes the finished path once any scan finds the goal.
	var/list/path_box = list(null)

	var/datum/nav_jps_node/start_node = new /datum/nav_jps_node(start, null, 0, goal)
	open.insert(start_node)
	found_turfs[start] = TRUE

	while(!open.is_empty() && !path_box[1])
		var/datum/nav_jps_node/current_node = open.pop()
		if(max_distance && current_node.number_tiles > max_distance)
			continue

		var/turf/current_turf = current_node.tile

		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			nav_jps_lateral_scan(current_turf, scan_direction, current_node, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			nav_jps_diag_scan(current_turf, scan_direction, current_node, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)

	// No qdel: nodes hold no signals/timers and every list here is a local about to go out of scope.
	return path_box[1] || list()

/// Unwinds a found node's previous_node chain (which skips jumped-over tiles) into a full turf list.
/proc/nav_jps_unwind(datum/nav_jps_node/unwind_node)
	var/list/path = list()
	var/turf/iter_turf = unwind_node.tile
	path += iter_turf

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)
		for(var/i in 1 to unwind_node.jumps)
			iter_turf = get_step(iter_turf, dir_goal)
			path += iter_turf
		unwind_node = unwind_node.previous_node

	return reverseList(path)

/**
 * Lateral (cardinal) jump scan from original_turf in `heading`. Direct port of jps.dm's
 * lateral_scan_spec, with CAN_STEP -> NAV_CAN_STEP and the found path routed through path_box instead
 * of a datum-level var. Returns a node datum for diagonal-subscan linking, or null; never returns a
 * list (see file header).
 */
/proc/nav_jps_lateral_scan(turf/original_turf, heading, datum/nav_jps_node/parent_node, turf/goal, mintargetdist, max_distance, is_flying, datum/can_pass_info/pass_info, datum/heap/open, list/found_turfs, list/path_box)
	var/steps_taken = 0
	var/turf/current_turf = original_turf

	while(TRUE)
		if(path_box[1])
			return null
		var/turf/next_turf = get_step(current_turf, heading)
		if(!NAV_CAN_STEP_TO(current_turf, heading, next_turf))
			return null
		current_turf = next_turf
		steps_taken++

		if(current_turf == goal || (mintargetdist && get_dist(current_turf, goal) <= mintargetdist && !diagonally_blocked(current_turf, goal)))
			var/datum/nav_jps_node/final_node = new /datum/nav_jps_node(current_turf, parent_node, steps_taken)
			found_turfs[current_turf] = TRUE
			if(parent_node) // direct scan: wrap up now
				path_box[1] = nav_jps_unwind(final_node)
			return final_node // subscan: caller wires up the parent, then unwinds itself
		else if(found_turfs[current_turf])
			return null
		else
			found_turfs[current_turf] = TRUE

		if(parent_node && max_distance && parent_node.number_tiles + steps_taken > max_distance)
			return null

		var/interesting = FALSE
		var/turf/_ns = get_step(current_turf, NORTH)
		var/turf/_ss = get_step(current_turf, SOUTH)
		var/turf/_ew = get_step(current_turf, EAST)
		var/turf/_ww = get_step(current_turf, WEST)
		switch(heading)
			if(NORTH)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, WEST, _ww, NORTHWEST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, EAST, _ew, NORTHEAST) \
					|| NAV_TURF_CANT_WE_CAN_TO(_ew, NORTH, current_turf, NORTHEAST, get_step(current_turf, NORTHEAST)) || NAV_TURF_CANT_WE_CAN_TO(_ww, NORTH, current_turf, NORTHWEST, get_step(current_turf, NORTHWEST)))
					interesting = TRUE
			if(SOUTH)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, WEST, _ww, SOUTHWEST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, EAST, _ew, SOUTHEAST) \
					|| NAV_TURF_CANT_WE_CAN_TO(_ew, SOUTH, current_turf, SOUTHEAST, get_step(current_turf, SOUTHEAST)) || NAV_TURF_CANT_WE_CAN_TO(_ww, SOUTH, current_turf, SOUTHWEST, get_step(current_turf, SOUTHWEST)))
					interesting = TRUE
			if(EAST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, NORTH, _ns, NORTHEAST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, SOUTH, _ss, SOUTHEAST) \
					|| NAV_TURF_CANT_WE_CAN_TO(_ss, EAST, current_turf, SOUTHEAST, get_step(current_turf, SOUTHEAST)) || NAV_TURF_CANT_WE_CAN_TO(_ns, EAST, current_turf, NORTHEAST, get_step(current_turf, NORTHEAST)))
					interesting = TRUE
			if(WEST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, NORTH, _ns, NORTHWEST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, SOUTH, _ss, SOUTHWEST) \
					|| NAV_TURF_CANT_WE_CAN_TO(_ss, WEST, current_turf, SOUTHWEST, get_step(current_turf, SOUTHWEST)) || NAV_TURF_CANT_WE_CAN_TO(_ns, WEST, current_turf, NORTHWEST, get_step(current_turf, NORTHWEST)))
					interesting = TRUE

		if(interesting)
			var/datum/nav_jps_node/newnode = new /datum/nav_jps_node(current_turf, parent_node, steps_taken)
			if(parent_node) // direct scan: we own inserting ourselves; subscans let the diag caller do it
				open.insert(newnode)
			return newnode

/**
 * Diagonal jump scan. Direct port of jps.dm's diag_scan_spec, with CAN_STEP -> NAV_CAN_STEP, the
 * lateral subscan calls routed through nav_jps_lateral_scan, and found paths routed through path_box.
 */
/proc/nav_jps_diag_scan(turf/original_turf, heading, datum/nav_jps_node/parent_node, turf/goal, mintargetdist, max_distance, is_flying, datum/can_pass_info/pass_info, datum/heap/open, list/found_turfs, list/path_box)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path_box[1])
			return
		var/turf/next_turf = get_step(current_turf, heading)
		if(!NAV_CAN_STEP_TO(current_turf, heading, next_turf))
			return
		lag_turf = current_turf
		current_turf = next_turf
		steps_taken++

		if(current_turf == goal || (mintargetdist && get_dist(current_turf, goal) <= mintargetdist && !diagonally_blocked(current_turf, goal)))
			var/datum/nav_jps_node/final_node = new /datum/nav_jps_node(current_turf, parent_node, steps_taken)
			found_turfs[current_turf] = TRUE
			path_box[1] = nav_jps_unwind(final_node)
			return
		else if(found_turfs[current_turf])
			return
		else
			found_turfs[current_turf] = TRUE

		if(max_distance && parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE
		var/datum/nav_jps_node/possible_child_node
		var/turf/_ns = get_step(current_turf, NORTH)
		var/turf/_ss = get_step(current_turf, SOUTH)
		var/turf/_ew = get_step(current_turf, EAST)
		var/turf/_ww = get_step(current_turf, WEST)

		switch(heading)
			if(NORTHWEST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, EAST, _ew, NORTHEAST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, SOUTH, _ss, SOUTHWEST) \
					|| NAV_TURF_CANT_WE_CAN_TO(lag_turf, NORTH, current_turf, EAST, _ew) || NAV_TURF_CANT_WE_CAN_TO(lag_turf, WEST, current_turf, SOUTH, _ss))
					interesting = TRUE
				else
					possible_child_node = nav_jps_lateral_scan(current_turf, WEST, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box) \
						|| nav_jps_lateral_scan(current_turf, NORTH, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)
			if(NORTHEAST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, WEST, _ww, NORTHWEST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, SOUTH, _ss, SOUTHEAST) \
					|| NAV_TURF_CANT_WE_CAN_TO(lag_turf, NORTH, current_turf, WEST, _ww) || NAV_TURF_CANT_WE_CAN_TO(lag_turf, EAST, current_turf, SOUTH, _ss))
					interesting = TRUE
				else
					possible_child_node = nav_jps_lateral_scan(current_turf, EAST, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box) \
						|| nav_jps_lateral_scan(current_turf, NORTH, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)
			if(SOUTHWEST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, EAST, _ew, SOUTHEAST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, NORTH, _ns, NORTHWEST) \
					|| NAV_TURF_CANT_WE_CAN_TO(lag_turf, SOUTH, current_turf, EAST, _ew) || NAV_TURF_CANT_WE_CAN_TO(lag_turf, WEST, current_turf, NORTH, _ns))
					interesting = TRUE
				else
					possible_child_node = nav_jps_lateral_scan(current_turf, SOUTH, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box) \
						|| nav_jps_lateral_scan(current_turf, WEST, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)
			if(SOUTHEAST)
				if(NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, WEST, _ww, SOUTHWEST) || NAV_STEP_NOT_HERE_BUT_THERE_TO(current_turf, NORTH, _ns, NORTHEAST) \
					|| NAV_TURF_CANT_WE_CAN_TO(lag_turf, SOUTH, current_turf, WEST, _ww) || NAV_TURF_CANT_WE_CAN_TO(lag_turf, EAST, current_turf, NORTH, _ns))
					interesting = TRUE
				else
					possible_child_node = nav_jps_lateral_scan(current_turf, SOUTH, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box) \
						|| nav_jps_lateral_scan(current_turf, EAST, null, goal, mintargetdist, max_distance, is_flying, pass_info, open, found_turfs, path_box)

		if(path_box[1]) // a lateral subscan may have set the goal path itself while walking a corridor
			return

		if(interesting || possible_child_node)
			var/datum/nav_jps_node/newnode = new /datum/nav_jps_node(current_turf, parent_node, steps_taken)
			open.insert(newnode)
			if(possible_child_node)
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				if(possible_child_node.tile == goal || (mintargetdist && get_dist(possible_child_node.tile, goal) <= mintargetdist))
					path_box[1] = nav_jps_unwind(possible_child_node)
			return

/**
 * Convenience wrapper mirroring get_path_to's shape for A/B benchmarking against JPS and plain nav A*.
 */
/proc/get_nav_jps_path_to(atom/movable/caller_movable, atom/target, max_distance = 30, mintargetdist = 0, list/access = list())
	if(!caller_movable || !target)
		return list()
	var/datum/can_pass_info/pass_info = new /datum/can_pass_info(caller_movable, access)
	return nav_jps_find_path(get_turf(caller_movable), get_turf(target), pass_info, max_distance, mintargetdist)
