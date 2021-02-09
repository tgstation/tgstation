#define PATH_DIST(A, B) (get_dist(A, B))
/// Enumerator for the starting turf's sources value, so we know when we've hit the beginning when unwinding at the end
#define PATH_START	-1

//JPS nodes variables
/datum/jpsnode
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jpsnode/prevNode
	/// The A* node weight (f = number_of_tiles + heuristic)
	var/f
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/h
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/nt
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/turf/node_goal

/datum/jpsnode/New(turf/our_tile, datum/jpsnode/previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	prevNode = previous_node
	jumps = jumps_taken
	if(prevNode)
		nt = prevNode.nt + jumps
		node_goal = prevNode.node_goal
	else
		nt = 0
		node_goal = incoming_goal

	h = PATH_DIST(tile, node_goal)
	f = nt + h//*(1+ PF_TIEBREAKER)

/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/caller
	/// The turf where we started at
	var/turf/start
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from
	var/datum/heap/open
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
	/// The proc we use to tell the distance between two turfs. Currently ignored in favor of PATH_DIST/get_dist
	///var/dist = /turf/proc/Distance
	/// Do we only worry about turfs with simulated atmos, most notably things that aren't space?
	var/simulated_only
	/// Did we succeed?
	var/success = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal, id, maxnodes, maxnodedepth, mintargetdist, simulated_only)
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
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
	var/datum/jpsnode/cur = new (start,null,0,end)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	sources[start] = PATH_START
	//then run the main loop
	var/total_tiles

	while(!open.IsEmpty() && !path)
		if(!caller)
			return
		cur = open.Pop() //get the lower f turf in the open list

		total_tiles++
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = cur.tile

		for(var/scan_direction in list(NORTH, EAST, SOUTH, WEST))
			lateral_scan_spec(current_turf, scan_direction) // this is a turf not a node, fix
			if(path)
				break

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST))
			lateral_scan_spec(current_turf, scan_direction)
			if(path)
				break

		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	testing("*********new path done with [total_tiles] tiles popped, [openc.len] nodes added to heap")
	openc = null
	//cleaning after us
	caller.calculating_path = FALSE
	return path

///
/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	success = unwind_node.tile == end
	path = new()
	var/turf/iter_turf = unwind_node.tile
	var/turf/iter_turf2 = get_turf(unwind_node.tile)
	path.Add(iter_turf)
	//var/legs
/*
	var/list/a = list(iter_turf)


	while(unwind_node.prevNode)
		legs++

		var/turf/goal_turf = unwind_node.prevNode.tile
		//testing(">lega [legs] | <b>([goal_turf.x], ([goal_turf.y])</b>")
		var/i
		a.Add(goal_turf)
		//goal_turf.color = COLOR_YELLOW
/*		while(iter_turf != goal_turf)
			i++
			testing(">>>stepa [legs] | [i]")
			iter_turf = get_step_towards(iter_turf, goal_turf)
			iter_turf.color = COLOR_BLUE_LIGHT
			path.Add(iter_turf)
		unwind_node = unwind_node.prevNode*/
		while(iter_turf != goal_turf)
			i++
			var/turf/next_turf = get_step_towards(iter_turf, goal_turf)
			//testing(">>>stepa [legs] | [i] - ([iter_turf.x], [iter_turf.y]) -> ([next_turf.x], [next_turf.y])")
			iter_turf = next_turf

			//iter_turf.color = COLOR_ORANGE
			//path.Add(iter_turf)
		unwind_node = unwind_node.prevNode
	//testing("+++++++++end of A")
*/
	//legs = 0

	var/list/b = list(iter_turf2)
	var/turf/goal_turf2 = sources[iter_turf2]
	while(goal_turf2 && goal_turf2 != PATH_START)
		b.Add(goal_turf2)
		//legs++

		while(iter_turf2 != goal_turf2)
			//i++
			//if(i > 150)
				//break
			var/turf/next_turf = get_step_towards(iter_turf2, goal_turf2)
			//testing(">>>stepa [legs] | [i] - ([iter_turf2.x], [iter_turf2.y]) -> ([next_turf.x], [next_turf.y])")
			iter_turf2 = next_turf
			path.Add(iter_turf2)
		goal_turf2 = sources[iter_turf2]

	//testing("LENGTHS OF 2 LISTS| A: [a.len] B: [b.len] (final goalturf2 = [goal_turf2])")

/datum/pathfind/proc/can_step(turf/a, turf/next) // prolly not optimal
	return call(a,adjacent)(caller, next, id, simulated_only)


/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
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

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jpsnode/final_node = new(current_turf,unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf])
			return
		else if(!can_step(lag_turf, current_turf))
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.nt + steps_taken > maxnodedepth)
			return

		var/interesting = FALSE // set to TRUE if we're cool enough to get a node and added to the open list

		switch(heading)
			if(NORTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					interesting = TRUE
				else if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					interesting = TRUE
			if(SOUTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					interesting = TRUE
				else if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					interesting = TRUE
			if(EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					interesting = TRUE
				else if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					interesting = TRUE
			if(WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					interesting = TRUE
				else if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					interesting = TRUE

		if(interesting)
			var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
			openc[current_turf] = newnode
			open.Insert(newnode)
			return

/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
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

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jpsnode/final_node = new(current_turf,unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf])
			return
		else if(!can_step(lag_turf, current_turf))
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.nt + steps_taken > maxnodedepth)
			return

		switch(heading)
			if(NORTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, NORTH)
			if(NORTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, NORTH)
			if(SOUTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, WEST)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)
			if(SOUTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, EAST)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)

#undef PATH_DIST
#undef PATH_START
