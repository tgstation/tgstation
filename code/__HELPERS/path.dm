#define PATH_DIST(A, B) (A.Distance_cardinal(B))
#define PATH_ADJ(A, B) (A.reachableTurftest(B))

#define PATH_REVERSE(A) ((A & MASK_ODD)<<1)|((A & MASK_EVEN)>>1)

/datum/tiles
	var/turf/dest_tile
	var/turf/from

/datum/tiles/New(_a, _b)
	dest_tile = _a
	from = _b

//JPS nodes variables
/datum/jpsnode
	var/turf/tile //turf associated with the PathNode
	var/datum/jpsnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g = 1	// all steps cost 1, i dunno if we really need this var, nt works fine
	var/h		//A* heuristic variable (distance)
	var/nt		//count the number of Nodes traversed
	var/jumps // how many steps it took from the last node
	var/retired
	var/turf/goal
	var/dir_from

//s,p,ph,pnt,*bf*,jmp
/datum/jpsnode/New(s,p, turf/goal)
	tile = s
	prevNode = p

	if(prevNode)
		jumps = PATH_DIST(prevNode.tile, tile)
		nt = prevNode.nt + jumps
		goal = prevNode.goal
		dir_from = get_dir(tile, prevNode.tile)
	else
		nt = 0
	h = PATH_DIST(tile, goal)

	f = nt + h*(1+ PF_TIEBREAKER)

/datum/jpsnode/proc/setp(p, _jmp) // even jmp shouldnt be necessaryt, should be inferrable
	prevNode = p

	dir_from = get_dir(tile, prevNode.tile)
	jumps = _jmp
	goal = prevNode.goal
	nt = prevNode.nt + jumps
	h = PATH_DIST(tile, goal)
	f = nt + h*(1+ PF_TIEBREAKER)


/datum/pathfind
	///
	var/atom/movable/caller

	var/turf/start
	///
	var/turf/end

	var/datum/heap/open //the open list

	var/list/openc //open list for node check

	var/list/path

	var/list/visited

	var/id

	var/mintargetdist = 0
	var/maxnodedepth = 50
	var/maxnodes = 50
	var/adjacent = /turf/proc/reachableTurftest
	var/dist = /turf/proc/Distance_cardinal
	var/turf/exclude = null
	var/simulated_only = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal)
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	openc = new() //open list for node check
	visited = new() //open list for node check

//datum/pathfind/proc/generate_node(turf/the_tile, )
/datum/pathfind/proc/start_search()
	caller.calculating_path = TRUE

	start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(PATH_DIST(start, end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	//initialization
	var/datum/jpsnode/cur = new (start,null,end)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	visited[start] = -1
	//then run the main loop
	var/total_tiles

	var/iii = 0
	while(!open.IsEmpty() && !path)
		if(!caller)
			return
		testing("pop [iii]")
		cur = open.Pop() //get the lower f turf in the open list
		iii++
		if(iii > 90)
			testing("[iii] hit 90")
			return
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		total_tiles++
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.tile,dist)(end) <= mintargetdist
		cur.tile.color = COLOR_BLUE

		//found the target turf (or close enough), let's create the path to it
		if(cur.tile == end || closeenough)
			testing("done? close enough: [closeenough]")
			unwind_path(cur)
			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = cur.tile
		queue_node(lateral_scan_spec(current_turf, NORTH)) // this is a turf not a node, fix
		queue_node(lateral_scan_spec(current_turf, SOUTH)) // this is a turf not a node, fix
		queue_node(lateral_scan_spec(current_turf, EAST)) // this is a turf not a node, fix
		queue_node(lateral_scan_spec(current_turf, WEST)) // this is a turf not a node, fix

		queue_node(diag_scan_spec(current_turf, NORTHWEST)) // this is a turf not a node, fix
		queue_node(diag_scan_spec(current_turf, NORTHEAST)) // this is a turf not a node, fix
		queue_node(diag_scan_spec(current_turf, SOUTHWEST)) // this is a turf not a node, fix
		queue_node(diag_scan_spec(current_turf, SOUTHWEST)) // this is a turf not a node, fix
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("new path done with [total_tiles] tiles popped")
	caller.calculating_path = FALSE
	return path

/*/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	//testing("unwind?")
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)
	while(unwind_node.prevNode)
		var/dir_goal = get_dir(iter_turf, unwind_node.prevNode.tile)
		for(var/i = 1 to unwind_node.jumps)
			if(iter_turf == unwind_node.prevNode.tile)
				break
			iter_turf = get_step(iter_turf,dir_goal)
			path.Add(iter_turf)
			iter_turf.color = COLOR_YELLOW
		unwind_node = unwind_node.prevNode
	return path
*/
/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	//testing("unwind?")
	path = new()
	var/turf/iter_turf = unwind_node.tile
	var/turf/checkpoint_turf = visited[iter_turf]
	path.Add(iter_turf)
	var/i = 0
	while(TRUE)
		i++
		testing("unwinding path leg [i]")
		if(i > 200)
			CRASH("broke lol on unwind")
		var/turf/next_turf_goal = visited[checkpoint_turf]
		//var/dir_goal = get_dir(iter_turf, unwind_node.prevNode.tile)
		var/dir_goal = get_dir(iter_turf, next_turf_goal)

		while(iter_turf != next_turf_goal)

			//iter_turf = get_step(iter_turf,dir_goal)
			iter_turf = get_step_towards(iter_turf,next_turf_goal)
			path.Add(iter_turf)
			iter_turf.color = COLOR_YELLOW
		if(visited[iter_turf] == -1)
			return path
		else
			checkpoint_turf = visited[iter_turf]

/datum/pathfind/proc/can_step(turf/a, turf/next)
	return !call(a,adjacent)(caller, next, id, simulated_only)

/datum/pathfind/proc/queue_node(datum/tiles/t)
	if(!t)
		return
	var/turf/turf_for_node = t.dest_tile
	var/turf/moved_from = t.from
	qdel(t)
	if(!turf_for_node || !moved_from)
		return
	var/datum/jpsnode/our_node = openc[turf_for_node]
	var/datum/jpsnode/from_node = openc[moved_from]

	if(!from_node)
		CRASH("missing from node in queue?")

	var/steps_taken = PATH_DIST(moved_from, turf_for_node)

	if(our_node)
		//is already in open list, check if it's a better way from the current turf
		if((our_node.nt + steps_taken) < from_node.nt)
			our_node.setp(from_node, steps_taken)
			open.ReSort(our_node)//reorder the changed element in the list
	else
	//is not already in open list, so add it
		testing("adding further node")
		our_node = new(turf_for_node,from_node)
		open.Insert(our_node)
		openc[turf_for_node] = our_node
		turf_for_node.color = COLOR_RED

/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
	var/turf/current_turf = original_turf

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		current_turf = get_step(current_turf, heading)
		if(!current_turf)
			return
		current_turf.color = COLOR_GRAY

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? lat close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node)
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return
		else if(!visited[current_turf])
			visited[current_turf] = original_turf
		else
			return

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			return
		/*if(!(unwind_node.bf & heading))
			//testing("skip dir: [f] br: [cur.bf]")
			break
		*/

		steps_taken++
		if(steps_taken % 5 == 0)
			testing("taking diag step [steps_taken] in dir [heading]")

		switch(heading)
			if(NORTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
			if(SOUTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
			if(EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
			if(WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf)

	testing("took [steps_taken] steps in dir [heading]")


/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
	var/turf/current_turf = original_turf

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		current_turf = get_step(current_turf, heading)
		if(!current_turf)
			return
		current_turf.color = COLOR_GRAY

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? lat close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node)
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return
		else if(!visited[current_turf])
			visited[current_turf] = original_turf
		else
			return

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			return

		/*if(!(unwind_node.bf & heading))
			//testing("skip dir: [f] br: [cur.bf]")
			break
		*/

		steps_taken++
		if(steps_taken % 5 == 0)
			testing("taking diag step [steps_taken] in dir [heading]")


		switch(heading)
			if(NORTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, WEST)) // this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, NORTH)) // this is a turf not a node, fix
					//cardinal scan north
			if(NORTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, EAST)) // this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, NORTH)) // this is a turf not a node, fix
					//cardinal scan north
			if(SOUTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, WEST)) // this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, SOUTH)) // this is a turf not a node, fix
					//cardinal scan south
			if(SOUTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, EAST)) // this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf)
				else
					queue_node(lateral_scan_spec(current_turf, SOUTH)) // this is a turf not a node, fix
					//cardinal scan south

	testing("took [steps_taken] steps in dir [heading]")
