/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions. Mind that diagonals
 * cost the same as cardinal moves currently, so paths may look a bit strange, but should still be optimal.
 */

/// A helper macro for JPS, for telling when a node has forced neighbors that need expanding
/// Only usable in the context of the jps datum because of the datum vars it relies on
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA), simulated_only, pass_info, avoid) && CAN_STEP(cur_turf, get_step(cur_turf, dirB), simulated_only, pass_info, avoid)))

/// The JPS Node datum represents a turf that we find interesting enough to add to the open list and possibly search for new tiles from
/datum/jps_node
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jps_node/previous_node
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/heuristic
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/number_tiles
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/turf/node_goal

/datum/jps_node/New(turf/our_tile, datum/jps_node/incoming_previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goal) // if we have the goal argument, this must be the first/starting node
		node_goal = incoming_goal
	else if(incoming_previous_node) // if we have the parent, this is from a direct lateral/diagonal scan, we can fill it all out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist_euclidean(tile, node_goal)
		f_value = number_tiles + heuristic
	// otherwise, no parent node means this is from a subscan lateral scan, so we just need the tile for now until we call [datum/jps/proc/update_parent] on it

/datum/jps_node/Destroy(force)
	previous_node = null
	return ..()

/datum/jps_node/proc/update_parent(datum/jps_node/new_parent)
	previous_node = new_parent
	node_goal = previous_node.node_goal
	jumps = get_dist(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = get_dist_euclidean(tile, node_goal)
	f_value = number_tiles + heuristic

/proc/HeapPathWeightCompare(datum/jps_node/a, datum/jps_node/b)
	return b.f_value - a.f_value

/datum/pathfind/jps
	/// The movable we are pathing
	var/atom/movable/requester
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	/// The list we compile at the end if successful to pass back
	var/list/path
	///An assoc list that serves as the closed list. Key is the turf, points to true if we've seen it before
	var/list/found_turfs

	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// If we should delete the first step in the path or not. Used often because it is just the starting tile
	var/skip_first = FALSE
	///Defines how we handle diagonal moves. See __DEFINES/path.dm
	var/diagonal_handling = DIAGONAL_REMOVE_CLUNKY

/datum/pathfind/jps/proc/setup(atom/movable/requester, list/access, max_distance, simulated_only, avoid, list/datum/callback/on_finish, atom/goal, mintargetdist, skip_first, diagonal_handling)
	src.requester = requester
	src.pass_info = new(requester, access)
	src.max_distance = max_distance
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.on_finish = on_finish
	src.mintargetdist = mintargetdist
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	found_turfs = list()

/datum/pathfind/jps/Destroy(force)
	. = ..()
	requester = null
	end = null
	open = null

/datum/pathfind/jps/start()
	start = start || get_turf(requester)
	. = ..()
	if(!.)
		return .

	if(!get_turf(end))
		stack_trace("Invalid JPS destination")
		return FALSE
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(max_distance && (max_distance < get_dist(start, end))) //if start turf is farther than max_distance from end turf, no need to do anything
		return FALSE

	var/datum/jps_node/current_processed_node = new (start, -1, 0, end)
	open.insert(current_processed_node)
	found_turfs[start] = TRUE // i'm sure this is fine
	return TRUE

/datum/pathfind/jps/search_step()
	. = ..()
	if(!.)
		return .
	if(QDELETED(requester))
		return FALSE

	while(!open.is_empty() && !path)
		var/datum/jps_node/current_processed_node = open.pop() //get the lower f_value turf in the open list
		if(max_distance && (current_processed_node.number_tiles > max_distance))//if too many steps, don't process that path
			continue

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction, current_processed_node)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction, current_processed_node)

		// Stable, we'll just be back later
		if(TICK_CHECK)
			return TRUE
	return TRUE

/datum/pathfind/jps/finished()
	//we're done! turn our reversed path (end to start) into a path (start to end)
	found_turfs = null
	QDEL_NULL(open)

	var/list/path = src.path || list()
	path = reverseList(path)
	switch(diagonal_handling)
		if(DIAGONAL_REMOVE_CLUNKY)
			path = remove_clunky_diagonals(path, pass_info, simulated_only, avoid)
		if(DIAGONAL_REMOVE_ALL)
			path = remove_diagonals(path, pass_info, simulated_only, avoid)
	if(skip_first && length(path) > 0)
		path.Cut(1,2)
	hand_back(path)
	return ..()

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/search]
/datum/pathfind/jps/proc/unwind_path(datum/jps_node/unwind_node)
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)
		for(var/i in 1 to unwind_node.jumps)
			iter_turf = get_step(iter_turf,dir_goal)
			path.Add(iter_turf)
		unwind_node = unwind_node.previous_node

/**
 * For performing lateral scans from a given starting turf.
 *
 * These scans are called from both the main search loop, as well as subscans for diagonal scans, and they treat finding interesting turfs slightly differently.
 * If we're doing a normal lateral scan, we already have a parent node supplied, so we just create the new node and immediately insert it into the heap, ezpz.
 * If we're part of a subscan, we still need for the diagonal scan to generate a parent node, so we return a node datum with just the turf and let the diag scan
 * proc handle transferring the values and inserting them into the heap.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be cardinal
 * * parent_node: Only given for normal lateral scans, if we don't have one, we're a diagonal subscan.
*/
/datum/pathfind/jps/proc/lateral_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	var/datum/can_pass_info/pass_info = src.pass_info

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf, simulated_only, pass_info, avoid))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist) && !diagonally_blocked(current_turf, end)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			found_turfs[current_turf] = TRUE
			if(parent_node) // if this is a direct lateral scan we can wrap up, if it's a subscan from a diag, we need to let the diag make their node first, then finish
				unwind_path(final_node)
			return final_node
		else if(found_turfs[current_turf]) // already visited, essentially in the closed list
			return
		else
			found_turfs[current_turf] = TRUE

		if(parent_node && parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?

		switch(heading)
			if(NORTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST))
					interesting = TRUE
			if(SOUTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST))
					interesting = TRUE
			if(EAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
			if(WEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE

		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			if(parent_node) // if we're a diagonal subscan, we'll handle adding ourselves to the heap in the diag
				open.insert(newnode)
			return newnode

/**
 * For performing diagonal scans from a given starting turf.
 *
 * Unlike lateral scans, these only are called from the main search loop, so we don't need to worry about returning anything,
 * though we do need to handle the return values of our lateral subscans of course.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be diagonal
 * * parent_node: We should always have a parent node for diagonals
*/
/datum/pathfind/jps/proc/diag_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	var/datum/can_pass_info/pass_info = src.pass_info

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf, simulated_only, pass_info, avoid))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist) && !diagonally_blocked(current_turf, end)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			found_turfs[current_turf] = TRUE
			unwind_path(final_node)
			return
		else if(found_turfs[current_turf]) // already visited, essentially in the closed list
			return
		else
			found_turfs[current_turf] = TRUE

		if(parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		var/datum/jps_node/possible_child_node // otherwise, did one of our lateral subscans turn up something?

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, WEST) || lateral_scan_spec(current_turf, NORTH))
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, EAST) || lateral_scan_spec(current_turf, NORTH))
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, WEST))
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, EAST))

		if(interesting || possible_child_node)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			open.insert(newnode)
			if(possible_child_node)
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				if(possible_child_node.tile == end || (mintargetdist && (get_dist(possible_child_node.tile, end) <= mintargetdist)))
					unwind_path(possible_child_node)
			return
