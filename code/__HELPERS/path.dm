#define PATH_DIST(A, B) (A.Distance(B))
#define PATH_ADJ(A, B) (A.reachableTurftest(B))

#define PATH_REVERSE(A) ((A & MASK_ODD)<<1)|((A & MASK_EVEN)>>1)

/datum/tiles
	var/turf/dest_tile
	var/turf/from
	var/jumps

//JPS nodes variables
/datum/jpsnode
	var/turf/tile //turf associated with the PathNode
	var/datum/jpsnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/h		//A* heuristic variable (distance)
	var/nt		//count the number of Nodes traversed
	var/jumps // how many steps it took from the last node
	var/turf/goal

//s,p,ph,pnt,*bf*,jmp
/datum/jpsnode/New(s,p, _jumps, turf/_goal)
	tile = s
	prevNode = p
	jumps = _jumps
	if(prevNode)
		nt = prevNode.nt + jumps
		goal = prevNode.goal
		dir_from = get_dir(tile, prevNode.tile)
	else
		nt = 0
		goal = _goal

	h = PATH_DIST(tile, goal)
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
	/// An associative list that matches turfs (the key) to their nodes if said turf has one
	var/list/openc
	/// An associative list that
	var/list/visited

	/// The list we compile at the end if successful to pass back
	var/list/path

	var/id

	var/mintargetdist = 0
	var/maxnodedepth = 150
	var/maxnodes = 150
	var/adjacent = /turf/proc/reachableTurftest
	var/dist = /turf/proc/Distance
	var/turf/exclude = null

	var/simulated_only

	var/done = FALSE

	var/success = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal, id, maxnodes, maxnodedepth, mintargetdist, simulated_only, diag=1)
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	openc = new() //open list for node check
	visited = new() //open list for node check
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
	visited[start] = -1
	//then run the main loop
	var/total_tiles

	while(!open.IsEmpty() && !path)
		if(done)
			break // a break here just moves on to the next node, returning will cancel the search entirely
		if(!caller)
			return
		cur = open.Pop() //get the lower f turf in the open list

		total_tiles++
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = cur.tile
		var/dx = current_turf.x - end.x
		var/dy = current_turf.y - end.y
		var/list/order

		for(var/scan_direction in list(NORTH, EAST, SOUTH, WEST))
			lateral_scan_spec(current_turf, scan_direction) // this is a turf not a node, fix
			if(done || path)
				break

		if(done || path)
			break

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST))
			lateral_scan_spec(current_turf, scan_direction)
			if(done || path)
				break

		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("*********new path done with [total_tiles] tiles popped, [iii] rounds (also the distance between a tile and null is [get_dist(start, null)] and the turf of a turf is [get_turf(start)]")
	caller.calculating_path = FALSE
	return path


/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	success = unwind_node.tile == end
	path = new()
	var/turf/iter_turf = unwind_node.tile
	var/turf/iter_turf2 = get_turf(unwind_node.tile)
	path.Add(iter_turf)
	var/legs
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
	legs = 0

	var/list/b = list(iter_turf2)
	var/turf/goal_turf2 = visited[iter_turf2]
	while(goal_turf2 && goal_turf2 != -1)
		b.Add(goal_turf2)
		legs++

		while(iter_turf2 != goal_turf2)
			//i++
			//if(i > 150)
				//break
			var/turf/next_turf = get_step_towards(iter_turf2, goal_turf2)
			//testing(">>>stepa [legs] | [i] - ([iter_turf2.x], [iter_turf2.y]) -> ([next_turf.x], [next_turf.y])")
			iter_turf2 = next_turf
			path.Add(iter_turf2)
			iter_turf.color = COLOR_BLUE_LIGHT
		goal_turf2 = visited[iter_turf2]

	for(var/turf/turff in b)
		turff.color = COLOR_BLUE_GRAY
	//testing("LENGTHS OF 2 LISTS| A: [a.len] B: [b.len] (final goalturf2 = [goal_turf2])")

/datum/pathfind/proc/can_step(turf/a, turf/next) // prolly not optimal
	return call(a,adjacent)(caller, next, id, simulated_only)


/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
	while(!unwind_node)
		var/turf/older = visited[original_turf]
		if(!older)
			CRASH("JPS error: Diagonal scan couldn't find a home node")
		unwind_node = openc[older]

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(done || path) // lazy way to force out when done, do better
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
			visited[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(visited[current_turf])
			return
		else if(!can_step(lag_turf, current_turf))
			return
		else
			visited[current_turf] = original_turf

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
		var/turf/older = visited[original_turf]
		if(!older)
			CRASH("JPS error: Diagonal scan couldn't find a home node")
		unwind_node = openc[older]

	while(TRUE)
		if(done || path) // lazy way to force out when done, do better
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
			visited[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(visited[current_turf])
			return
		else if(!can_step(lag_turf, current_turf))
			return
		else
			visited[current_turf] = original_turf

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
