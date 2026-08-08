/// DM navmap JPS node. The heap stores the lowest f-value first.
/datum/navmap_jps_node
	var/turf/tile
	var/f_value
	var/datum/navmap_jps_node/previous_node
	var/heuristic
	var/number_tiles
	var/jumps
	var/turf/node_goal

/datum/navmap_jps_node/New(turf/our_tile, datum/navmap_jps_node/incoming_previous_node, incoming_jumps, turf/incoming_goal)
	tile = our_tile
	jumps = incoming_jumps
	if(incoming_goal)
		node_goal = incoming_goal
	else if(incoming_previous_node)
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist_euclidean(tile, node_goal)
		f_value = number_tiles + heuristic

/datum/navmap_jps_node/Destroy(force)
	previous_node = null
	return ..()

/// The navmap_jps heap stores the lowest f-value first, with older entries winning ties.
#define NAVMAP_JPS_NODE_BEFORE(a, b) ((a).f_value < (b).f_value)

#define NAVMAP_JPS_MAKE_START_NODE(TILE, RESULT) \
	RESULT = new /datum/navmap_jps_node((TILE), null, 0, (src).end)

#define NAVMAP_JPS_MAKE_NODE(TILE, PARENT, JUMPS, RESULT) \
	RESULT = new /datum/navmap_jps_node((TILE), (PARENT), (JUMPS))

// nav_pass already contains the cached directional bits. Use those bits directly and only
// walk nav_blockers when the edge was classified as conditional, preserving live blocker checks.
// The caller owns the turf variables so the hot scan does not repeatedly assign source/destination
// temporaries inside this macro.
#define NAVMAP_JPS_DESTINATION_OPEN(DESTINATION) \
	((DESTINATION) && !(DESTINATION).density && (DESTINATION) != avoid \
		&& (!simulated_only || !SSpathfinder.space_type_cache[(DESTINATION).type]))

#define NAVMAP_JPS_TURF_OPEN(TILE, RESULT) \
	RESULT = NAVMAP_JPS_DESTINATION_OPEN(TILE)

#define NAVMAP_JPS_CAN_CARDINAL_BAKED(SOURCE, DESTINATION, DIRECTION, RESULT) \
	do { \
		RESULT = FALSE; \
		if(NAVMAP_JPS_DESTINATION_OPEN(DESTINATION)) { \
			NAV_EDGE_OPEN_BAKED((SOURCE), (DIRECTION), is_flying, pass_info, RESULT); \
		} \
	} while(FALSE)

#define NAVMAP_JPS_CAN_CARDINAL(SOURCE, DESTINATION, DIRECTION, RESULT) \
	do { \
		RESULT = FALSE; \
		if(NAVMAP_JPS_DESTINATION_OPEN(DESTINATION)) { \
			NAV_ENSURE_BAKED((SOURCE)); \
			NAV_EDGE_OPEN_BAKED((SOURCE), (DIRECTION), is_flying, pass_info, RESULT); \
		} \
	} while(FALSE)

#define NAVMAP_JPS_CAN_DIAGONAL_BAKED(SOURCE, DESTINATION, DIRECTION, RESULT) \
	do { \
		RESULT = FALSE; \
		if(NAVMAP_JPS_DESTINATION_OPEN(DESTINATION)) { \
			NAV_DIAGONAL_OPEN((SOURCE), (DIRECTION), is_flying, pass_info, RESULT); \
		} \
	} while(FALSE)

#define NAVMAP_JPS_CAN_DIAGONAL(SOURCE, DESTINATION, DIRECTION, RESULT) \
	do { \
		RESULT = FALSE; \
		if(NAVMAP_JPS_DESTINATION_OPEN(DESTINATION)) { \
			NAV_ENSURE_BAKED((SOURCE)); \
			NAV_DIAGONAL_OPEN((SOURCE), (DIRECTION), is_flying, pass_info, RESULT); \
		} \
	} while(FALSE)

// For a cardinal scan, a side is forced when either the side step is blocked or
// the side turf cannot continue with us, but the matching diagonal is open.
// Grouping those two cases means the diagonal is evaluated at most once.
#define NAVMAP_JPS_LATERAL_SIDE_FORCED(CURRENT, SIDE_DIRECTION, HEADING, DIAGONAL_DIRECTION, RESULT) \
	do { \
		var/turf/_navjps_lsf_side = get_step((CURRENT), (SIDE_DIRECTION)); \
		var/_navjps_lsf_side_open; \
		NAVMAP_JPS_CAN_CARDINAL_BAKED((CURRENT), _navjps_lsf_side, (SIDE_DIRECTION), _navjps_lsf_side_open); \
		var/_navjps_lsf_continues = FALSE; \
		if(_navjps_lsf_side_open) { \
			var/turf/_navjps_lsf_forward = get_step(_navjps_lsf_side, (HEADING)); \
			NAVMAP_JPS_CAN_CARDINAL(_navjps_lsf_side, _navjps_lsf_forward, (HEADING), _navjps_lsf_continues); \
		} \
		RESULT = FALSE; \
		if(!_navjps_lsf_side_open || !_navjps_lsf_continues) { \
			var/turf/_navjps_lsf_diagonal = get_step((CURRENT), (DIAGONAL_DIRECTION)); \
			NAVMAP_JPS_CAN_DIAGONAL_BAKED((CURRENT), _navjps_lsf_diagonal, (DIAGONAL_DIRECTION), RESULT); \
		} \
	} while(FALSE)

// For a diagonal scan, each forced-neighbour pair shares the current cardinal
// step. If that step is open we only need to test the lagging edge; otherwise we
// only need to test the outward diagonal.
#define NAVMAP_JPS_DIAGONAL_SIDE_FORCED(LAG, CURRENT, SIDE_DIRECTION, OUTWARD_DIAGONAL, LAG_DIRECTION, RESULT) \
	do { \
		var/turf/_navjps_dsf_side = get_step((CURRENT), (SIDE_DIRECTION)); \
		var/_navjps_dsf_side_open; \
		NAVMAP_JPS_CAN_CARDINAL_BAKED((CURRENT), _navjps_dsf_side, (SIDE_DIRECTION), _navjps_dsf_side_open); \
		if(_navjps_dsf_side_open) { \
			var/turf/_navjps_dsf_lag_destination = get_step((LAG), (LAG_DIRECTION)); \
			var/_navjps_dsf_lag_open; \
			NAVMAP_JPS_CAN_CARDINAL_BAKED((LAG), _navjps_dsf_lag_destination, (LAG_DIRECTION), _navjps_dsf_lag_open); \
			RESULT = !_navjps_dsf_lag_open; \
		} else { \
			var/turf/_navjps_dsf_diagonal = get_step((CURRENT), (OUTWARD_DIAGONAL)); \
			NAVMAP_JPS_CAN_DIAGONAL_BAKED((CURRENT), _navjps_dsf_diagonal, (OUTWARD_DIAGONAL), RESULT); \
		} \
	} while(FALSE)

#define NAVMAP_JPS_LATERAL_FORCED(CURRENT, HEADING, RESULT) \
	do { \
		RESULT = FALSE; \
		NAV_ENSURE_BAKED((CURRENT)); \
		switch(HEADING) { \
			if(NORTH) { \
				NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), WEST, NORTH, NORTHWEST, RESULT); \
				if(!RESULT) { NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), EAST, NORTH, NORTHEAST, RESULT); } \
			} \
			if(SOUTH) { \
				NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), WEST, SOUTH, SOUTHWEST, RESULT); \
				if(!RESULT) { NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), EAST, SOUTH, SOUTHEAST, RESULT); } \
			} \
			if(EAST) { \
				NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), NORTH, EAST, NORTHEAST, RESULT); \
				if(!RESULT) { NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), SOUTH, EAST, SOUTHEAST, RESULT); } \
			} \
			if(WEST) { \
				NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), NORTH, WEST, NORTHWEST, RESULT); \
				if(!RESULT) { NAVMAP_JPS_LATERAL_SIDE_FORCED((CURRENT), SOUTH, WEST, SOUTHWEST, RESULT); } \
			} \
		} \
	} while(FALSE)

#define NAVMAP_JPS_DIAGONAL_FORCED(LAG, CURRENT, HEADING, RESULT) \
	do { \
		RESULT = FALSE; \
		NAV_ENSURE_BAKED((LAG)); \
		NAV_ENSURE_BAKED((CURRENT)); \
		switch(HEADING) { \
			if(NORTHWEST) { \
				NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), EAST, NORTHEAST, NORTH, RESULT); \
				if(!RESULT) { NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), SOUTH, SOUTHWEST, WEST, RESULT); } \
			} \
			if(NORTHEAST) { \
				NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), WEST, NORTHWEST, NORTH, RESULT); \
				if(!RESULT) { NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), SOUTH, SOUTHEAST, EAST, RESULT); } \
			} \
			if(SOUTHWEST) { \
				NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), EAST, SOUTHEAST, SOUTH, RESULT); \
				if(!RESULT) { NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), NORTH, NORTHWEST, WEST, RESULT); } \
			} \
			if(SOUTHEAST) { \
				NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), WEST, SOUTHWEST, SOUTH, RESULT); \
				if(!RESULT) { NAVMAP_JPS_DIAGONAL_SIDE_FORCED((LAG), (CURRENT), NORTH, NORTHEAST, EAST, RESULT); } \
			} \
		} \
	} while(FALSE)

#define NAVMAP_JPS_REACHED(TILE, RESULT) \
	do { \
		RESULT = ((TILE) == end); \
		if(!RESULT && minimum_distance && get_dist((TILE), end) <= minimum_distance && !diagonally_blocked((TILE), end)) { \
			RESULT = TRUE; \
		} \
	} while(FALSE)

#define NAVMAP_JPS_HEAP_INSERT(OPEN_LIST, NODE) \
	do { \
		(OPEN_LIST) += (NODE); \
		var/_navhi_index = (OPEN_LIST).len; \
		while(_navhi_index > 1) { \
			var/_navhi_parent = _navhi_index >> 1; \
			if(!NAVMAP_JPS_NODE_BEFORE((OPEN_LIST)[_navhi_index], (OPEN_LIST)[_navhi_parent])) { \
				break; \
			} \
			(OPEN_LIST).Swap(_navhi_index, _navhi_parent); \
			_navhi_index = _navhi_parent; \
		} \
	} while(FALSE)

#define NAVMAP_JPS_HEAP_POP(OPEN_LIST, RESULT) \
	do { \
		RESULT = null; \
		var/_navhp_length = (OPEN_LIST).len; \
		if(_navhp_length) { \
			RESULT = (OPEN_LIST)[1]; \
			if(_navhp_length == 1) { \
				(OPEN_LIST).len = 0; \
			} else { \
				var/_navhp_last_node = (OPEN_LIST)[_navhp_length]; \
				(OPEN_LIST).len--; \
				(OPEN_LIST)[1] = _navhp_last_node; \
				var/_navhp_index = 1; \
				var/_navhp_last_index = _navhp_length - 1; \
				while(TRUE) { \
					var/_navhp_left_child = _navhp_index * 2; \
					if(_navhp_left_child > _navhp_last_index) { \
						break; \
					} \
					var/_navhp_better_child = _navhp_left_child; \
					var/_navhp_right_child = _navhp_left_child + 1; \
					if(_navhp_right_child <= _navhp_last_index && NAVMAP_JPS_NODE_BEFORE((OPEN_LIST)[_navhp_right_child], (OPEN_LIST)[_navhp_left_child])) { \
						_navhp_better_child = _navhp_right_child; \
					} \
					if(!NAVMAP_JPS_NODE_BEFORE((OPEN_LIST)[_navhp_better_child], (OPEN_LIST)[_navhp_index])) { \
						break; \
					} \
					(OPEN_LIST).Swap(_navhp_index, _navhp_better_child); \
					_navhp_index = _navhp_better_child; \
				} \
			} \
		} \
	} while(FALSE)

/// A path datum used by both the navmap DLL and the DM navmap_jps.
/datum/pathfind/navmap
	var/atom/movable/requester
	var/turf/end
	var/minimum_distance
	var/skip_first
	var/diagonal_handling
	var/job_id
	var/complete = FALSE
	var/list/path
	var/force_dm = FALSE
	var/use_native = FALSE
	var/allow_tick_yield = TRUE

	// DM navmap_jps state. Static directional bits come from nav_pass; conditional blockers are checked live.
	var/list/navmap_jps_open
	var/list/navmap_jps_found
	var/navmap_jps_is_flying = FALSE

/datum/pathfind/navmap/proc/setup(atom/movable/requester, atom/goal, max_distance, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	var/datum/can_pass_info/info = new /datum/can_pass_info(requester, access, no_id = !length(access))
	setup_with_pass_info(requester, goal, max_distance, minimum_distance, info, simulated_only, avoid, skip_first, diagonal_handling, on_finish)

/datum/pathfind/navmap/proc/setup_with_pass_info(atom/movable/requester, atom/goal, max_distance, minimum_distance, datum/can_pass_info/pass_info, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(goal)
	src.max_distance = max_distance
	src.minimum_distance = minimum_distance || 0
	src.pass_info = pass_info
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	src.on_finish = on_finish

/datum/pathfind/navmap/start()
	start = get_turf(requester) // start needs to be set
	. = ..()
	if(!. || !end || start.z != end.z)
		return FALSE

	use_native = !force_dm && navmap_pathfinder_available()
	if(!use_native)
		navmap_jps_initialize()
		return TRUE

	var/list/result
	try
		result = navmap_pathfinder_start(start, end, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/search_step()
	if(QDELETED(requester) || QDELETED(end))
		return FALSE
	if(complete)
		return TRUE
	if(!use_native)
		return navmap_jps_search_step()

	var/list/result
	try
		result = navmap_pathfinder_resume(job_id, pass_info)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/proc/handle_result(list/result)
	if(!islist(result))
		return FALSE
	switch(result["status"])
		if(NAVMAP_PATH_IN_PROGRESS)
			job_id = result["job_id"]
			return !!job_id
		if(NAVMAP_PATH_COMPLETE, NAVMAP_PATH_NO_PATH)
			path = result["path"] || list()
			complete = TRUE
			return TRUE
		if(NAVMAP_PATH_ERROR)
			path = list()
			complete = TRUE
			return TRUE
	return FALSE

/datum/pathfind/navmap/proc/navmap_jps_initialize()
	navmap_jps_open = list()
	navmap_jps_found = list()
	navmap_jps_is_flying = NAV_IS_FLYING(pass_info)
	var/simulated_only = src.simulated_only
	var/turf/avoid = src.avoid
	path = null
	complete = FALSE
	var/start_distance = get_dist(start, end)
	if(start == end || start == avoid || (max_distance && start_distance > max_distance + minimum_distance))
		path = list()
		complete = TRUE
		return
	var/start_open
	NAVMAP_JPS_TURF_OPEN(start, start_open)
	if(!start_open)
		path = list()
		complete = TRUE
		return
	navmap_jps_found[start] = TRUE
	var/datum/navmap_jps_node/start_node
	NAVMAP_JPS_MAKE_START_NODE(start, start_node)
	NAVMAP_JPS_HEAP_INSERT(navmap_jps_open, start_node)

/datum/pathfind/navmap/proc/navmap_jps_reconstruct(datum/navmap_jps_node/goal_node)
	var/datum/can_pass_info/pass_info = src.pass_info
	var/is_flying = navmap_jps_is_flying
	var/simulated_only = src.simulated_only
	var/turf/avoid = src.avoid
	var/list/reversed_path = list(goal_node.tile)
	var/turf/current = goal_node.tile
	var/datum/navmap_jps_node/current_node = goal_node
	while(current_node.previous_node)
		var/direction = get_dir(current, current_node.previous_node.tile)
		for(var/i in 1 to current_node.jumps)
			current = get_step(current, direction)
			reversed_path += current
		current_node = current_node.previous_node

	var/list/final_path = reverseList(reversed_path)

	var/list/expanded_path = list(final_path[1])
	for(var/i in 1 to (length(final_path) - 1))
		var/turf/from = final_path[i]
		var/turf/next_turf = final_path[i + 1]
		var/step_direction = get_dir(from, next_turf)
		if(step_direction & (step_direction - 1))
			var/vertical_direction = step_direction & (NORTH|SOUTH)
			var/turf/vertical_turf = get_step(from, vertical_direction)
			var/vertical_open
			NAVMAP_JPS_CAN_CARDINAL(from, vertical_turf, vertical_direction, vertical_open)
			if(diagonal_handling == DIAGONAL_REMOVE_ALL)
				if(vertical_open)
					expanded_path += get_step(from, step_direction & (NORTH|SOUTH))
				else
					expanded_path += get_step(from, step_direction & (EAST|WEST))
			else if(diagonal_handling == DIAGONAL_REMOVE_CLUNKY && !vertical_open)
				expanded_path += get_step(from, step_direction & (EAST|WEST))
		expanded_path += next_turf

	if(skip_first && length(expanded_path))
		expanded_path.Cut(1, 2)
	path = expanded_path
	complete = TRUE

/datum/pathfind/navmap/proc/navmap_jps_lateral_scan(turf/original_turf, heading, datum/navmap_jps_node/parent_node = null)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	var/datum/can_pass_info/pass_info = src.pass_info
	var/is_flying = navmap_jps_is_flying
	var/simulated_only = src.simulated_only
	var/turf/avoid = src.avoid
	var/list/found_turfs = navmap_jps_found
	var/list/open = navmap_jps_open

	while(TRUE)
		if(path)
			return null
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!current_turf)
			return null
		var/step_open
		NAVMAP_JPS_CAN_CARDINAL(lag_turf, current_turf, heading, step_open)
		if(!step_open)
			return null

		var/reached
		NAVMAP_JPS_REACHED(current_turf, reached)
		if(reached)
			found_turfs[current_turf] = TRUE
			var/datum/navmap_jps_node/final_node
			NAVMAP_JPS_MAKE_NODE(current_turf, parent_node, steps_taken, final_node)
			if(parent_node)
				navmap_jps_reconstruct(final_node)
			return final_node
		if(found_turfs[current_turf])
			return null
		found_turfs[current_turf] = TRUE

		if(max_distance && parent_node && parent_node.number_tiles + steps_taken > max_distance)
			return null

		var/forced
		NAVMAP_JPS_LATERAL_FORCED(current_turf, heading, forced)
		if(forced)
			var/datum/navmap_jps_node/new_node
			NAVMAP_JPS_MAKE_NODE(current_turf, parent_node, steps_taken, new_node)
			if(parent_node)
				NAVMAP_JPS_HEAP_INSERT(open, new_node)
			return new_node

/datum/pathfind/navmap/proc/navmap_jps_diagonal_scan(turf/original_turf, heading, datum/navmap_jps_node/parent_node)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	var/datum/can_pass_info/pass_info = src.pass_info
	var/is_flying = navmap_jps_is_flying
	var/simulated_only = src.simulated_only
	var/turf/avoid = src.avoid
	var/list/found_turfs = navmap_jps_found
	var/list/open = navmap_jps_open

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!current_turf)
			return
		var/step_open
		NAVMAP_JPS_CAN_DIAGONAL(lag_turf, current_turf, heading, step_open)
		if(!step_open)
			return

		var/reached
		NAVMAP_JPS_REACHED(current_turf, reached)
		if(reached)
			found_turfs[current_turf] = TRUE
			var/datum/navmap_jps_node/final_node
			NAVMAP_JPS_MAKE_NODE(current_turf, parent_node, steps_taken, final_node)
			navmap_jps_reconstruct(final_node)
			return
		if(found_turfs[current_turf])
			return
		found_turfs[current_turf] = TRUE

		if(max_distance && parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting
		NAVMAP_JPS_DIAGONAL_FORCED(lag_turf, current_turf, heading, interesting)
		var/datum/navmap_jps_node/possible_child_node
		if(!interesting)
			switch(heading)
				if(NORTHWEST)
					possible_child_node = navmap_jps_lateral_scan(current_turf, WEST) || navmap_jps_lateral_scan(current_turf, NORTH)
				if(NORTHEAST)
					possible_child_node = navmap_jps_lateral_scan(current_turf, EAST) || navmap_jps_lateral_scan(current_turf, NORTH)
				if(SOUTHWEST)
					possible_child_node = navmap_jps_lateral_scan(current_turf, SOUTH) || navmap_jps_lateral_scan(current_turf, WEST)
				if(SOUTHEAST)
					possible_child_node = navmap_jps_lateral_scan(current_turf, SOUTH) || navmap_jps_lateral_scan(current_turf, EAST)

		if(interesting || possible_child_node)
			var/datum/navmap_jps_node/new_node
			NAVMAP_JPS_MAKE_NODE(current_turf, parent_node, steps_taken, new_node)
			NAVMAP_JPS_HEAP_INSERT(open, new_node)
			if(possible_child_node)
				possible_child_node.previous_node = new_node
				possible_child_node.node_goal = new_node.node_goal
				possible_child_node.jumps = get_dist(possible_child_node.tile, new_node.tile)
				possible_child_node.number_tiles = new_node.number_tiles + possible_child_node.jumps
				possible_child_node.heuristic = get_dist_euclidean(possible_child_node.tile, possible_child_node.node_goal)
				possible_child_node.f_value = possible_child_node.number_tiles + possible_child_node.heuristic
				NAVMAP_JPS_HEAP_INSERT(open, possible_child_node)
				var/child_reached
				NAVMAP_JPS_REACHED(possible_child_node.tile, child_reached)
				if(child_reached)
					navmap_jps_reconstruct(possible_child_node)
			return

/datum/pathfind/navmap/proc/navmap_jps_search_step()
	var/list/open = navmap_jps_open
	while(open.len)
		var/datum/navmap_jps_node/current_node
		NAVMAP_JPS_HEAP_POP(open, current_node)
		if(isnull(current_node))
			break

		navmap_jps_lateral_scan(current_node.tile, NORTH, current_node)
		navmap_jps_lateral_scan(current_node.tile, SOUTH, current_node)
		navmap_jps_lateral_scan(current_node.tile, EAST, current_node)
		navmap_jps_lateral_scan(current_node.tile, WEST, current_node)
		navmap_jps_diagonal_scan(current_node.tile, NORTHEAST, current_node)
		navmap_jps_diagonal_scan(current_node.tile, NORTHWEST, current_node)
		navmap_jps_diagonal_scan(current_node.tile, SOUTHEAST, current_node)
		navmap_jps_diagonal_scan(current_node.tile, SOUTHWEST, current_node)
		if(path)
			return TRUE

		if(allow_tick_yield)
			CHECK_TICK

	path = list()
	complete = TRUE
	return TRUE

/datum/pathfind/navmap/finished()
	if(!length(path))
		EVLOG_TEXT(requester, EVLOG_CATEGORY_NAVMAP, "No navmap path (pass_flags=[pass_info.pass_flags])")
	hand_back(path || list())
	return ..()

/datum/pathfind/navmap/early_exit()
	if(job_id && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	job_id = null
	return ..()

/datum/pathfind/navmap/Destroy(force)
	if(job_id && !complete && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	job_id = null
	for(var/datum/navmap_jps_node/node as anything in navmap_jps_open)
		qdel(node)
	navmap_jps_open = null
	navmap_jps_found = null
	SSpathfinder.navmap_pathing -= src
	SSpathfinder.current_navmap_run -= src
	requester = null
	end = null
	return ..()

/proc/navmap_pathfinder_blocking(atom/movable/requester, turf/start_turf, turf/end_turf, datum/can_pass_info/pass_info, max_distance, minimum_distance, simulated_only, turf/avoid, diagonal_handling, skip_first, use_dm_implementation = FALSE, allow_tick_yield = TRUE)
	if(!use_dm_implementation && navmap_pathfinder_available())
		try
			return navmap_pathfinder(start_turf, end_turf, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
		catch
			return list()

	var/datum/pathfind/navmap/search = new()
	search.force_dm = TRUE
	search.allow_tick_yield = allow_tick_yield
	search.setup_with_pass_info(requester, end_turf, max_distance, minimum_distance, pass_info, simulated_only, avoid, skip_first, diagonal_handling)
	if(!search.start())
		qdel(search)
		return list()
	while(!search.complete)
		if(!search.search_step())
			search.early_exit()
			return list()
		if(allow_tick_yield)
			CHECK_TICK
	var/list/result = search.path ? search.path.Copy() : list()
	qdel(search)
	return result
