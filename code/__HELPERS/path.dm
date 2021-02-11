#define CAN_STEP(cur_turf, next) (next && !next.density && cur_turf.Adjacent(next) && !(simulated_only && SSpathfinder.space_type_cache[next.type]) && !cur_turf.LinkBlockedWithAccess(next,caller, id))
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))

/// Enumerator for the starting turf's sources value, so we know when we've hit the beginning when unwinding at the end
#define PATH_START	-1

/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions.
 *
 * Quick notes about current implementation:
 * * JPS requires and allows for diagonal movement, whereas our A* only allows for cardinal movement
 * *
 * *
 * *
 */


//JPS nodes variables
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

/datum/jps_node/New(turf/our_tile, datum/jps_node/previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	previous_node = previous_node
	jumps = jumps_taken
	if(previous_node)
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
	else
		number_tiles = 0
		node_goal = incoming_goal

	heuristic = get_dist(tile, node_goal)
	f_value = number_tiles + heuristic

/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/caller
	/// The turf where we started at
	var/turf/start
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from
	var/datum/heap/path/open
	/// An assoc list that matches turfs (the key) to their nodes if said turf has one
	var/list/openc
	/**
	 * An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	 *
	 * Nodes are only created & added to the heap/openc once a turf is found "interesting", but due to recursion, we may not know it's interesting until we finish processing its children.
	 * Inserting to this list is cheaper than making a node datum + inserting into the heap, so everything goes in here immediately, and what we use to recreate the path at the end
	 */
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/path

	// general pathfinding vars/args
	/// An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
	var/obj/item/card/id/id
	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// I don't know what this does vs maxnodes, but they limit how far we can search before giving up on a path
	var/maxnodedepth = 150
	/// I don't know what this does vs maxnodedepth, but they limit how far we can search before giving up on a path
	var/maxnodes = 150
	/// The proc we use to see which turfs are available from this one. Must be 8-dir
	var/adjacent = /turf/proc/reachableTurftest
	/// The proc we use to tell the distance between two turfs. Currently ignored in favor of get_dist/get_dist
	///var/dist = /turf/proc/Distance
	/// Do we only worry about turfs with simulated atmos, most notably things that aren't space?
	var/simulated_only
	/// Did we succeed?
	var/success = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal, id, maxnodes, maxnodedepth, mintargetdist, simulated_only)
	src.caller = caller
	end = get_turf(goal)
	open = new()
	openc = new() //open list for node check
	sources = new() //open list for node check
	src.id = id
	src.maxnodes = maxnodes
	src.maxnodedepth = maxnodedepth
	src.mintargetdist = mintargetdist
	src.simulated_only = simulated_only

//datum/pathfind/proc/generate_node(turf/the_tile, )
/datum/pathfind/proc/start_search()
	caller.calculating_path = TRUE
	start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(maxnodes) //if start turf is farther than maxnodes from end turf, no need to do anything
		maxnodedepth = maxnodes

	//initialization
	var/datum/jps_node/cur = new (start,null,0,end)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	sources[start] = PATH_START
	//then run the main loop
	while(!open.IsEmpty() && !path)
		if(!caller)
			return
		cur = open.Pop() //get the lower f_value turf in the open list

		if((maxnodedepth)&&(cur.number_tiles > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = cur.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction)

		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,length(path)-i+1)
	openc = null //cleaning after us
	sources = null
	caller.calculating_path = FALSE
	return path

///
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	success = unwind_node.tile == end
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	var/list/b = list(iter_turf)
	var/turf/goal_turf = sources[iter_turf]
	while(goal_turf && goal_turf != PATH_START)
		b.Add(goal_turf)
		while(iter_turf != goal_turf)
			var/turf/next_turf = get_step_towards(iter_turf, goal_turf)
			iter_turf = next_turf
			path.Add(iter_turf)
		goal_turf = sources[iter_turf]

/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jps_node/unwind_node = openc[original_turf]
	while(!unwind_node)
		var/turf/older = sources[original_turf]
		if(!older)
			CRASH("JPS error: Lateral scan couldn't find a home node")
		unwind_node = openc[older]

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!current_turf)
			return

		if(!CAN_STEP(lag_turf, current_turf))
			return
		// you have to tak ethe steps directly into walls to see if they reveal a jump point
		var/closeenough
		if(mintargetdist)
			closeenough = (get_dist(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jps_node/final_node = new(current_turf,unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf])
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.number_tiles + steps_taken > maxnodedepth)
			return

		var/interesting = FALSE // set to TRUE if we're cool enough to get a node and added to the open list

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
			var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
			openc[current_turf] = newnode
			open.Insert(newnode)
			return

/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jps_node/unwind_node = openc[original_turf]
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(!unwind_node)
		var/turf/older = sources[original_turf]
		if(!older)
			CRASH("JPS error: Diagonal scan couldn't find a home node")
		unwind_node = openc[older]

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)

		steps_taken++
		if(!current_turf)
			return
		if(!CAN_STEP(lag_turf, current_turf))
			return

		var/closeenough
		if(mintargetdist)
			closeenough = (get_dist(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jps_node/final_node = new(current_turf,unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf])
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.number_tiles + steps_taken > maxnodedepth)
			return

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, WEST)
					lateral_scan_spec(current_turf, NORTH)
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, EAST)
					lateral_scan_spec(current_turf, NORTH)
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)
					lateral_scan_spec(current_turf, WEST)
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)
					lateral_scan_spec(current_turf, EAST)

#undef PATH_START
#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE
