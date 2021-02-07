#define PATH_DIST(A, B) (A.Distance(B))
#define PATH_ADJ(A, B) (A.reachableTurftest(B))

#define PATH_REVERSE(A) ((A & MASK_ODD)<<1)|((A & MASK_EVEN)>>1)

/datum/tiles
	var/turf/dest_tile
	var/turf/from
	var/jumps

/datum/tiles/New(_a, _b, _c)
	dest_tile = _a
	from = _b
	jumps = _c

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
/datum/jpsnode/New(s,p, _jumps, turf/goal)
	tile = s
	prevNode = p
	jumps = _jumps
	if(prevNode)
		nt = prevNode.nt + jumps
		goal = prevNode.goal
		dir_from = get_dir(tile, prevNode.tile)
	else
		testing("<<<<<<<<<>>>>>>>>>>>>>>>introduced a new node with no parent ")
		tile.color = COLOR_VERY_PALE_LIME_GREEN
		nt = 0
	h = PATH_DIST(tile, goal)

	f = nt + h//*(1+ PF_TIEBREAKER)

/datum/jpsnode/proc/setp(p, _jmp) // even jmp shouldnt be necessaryt, should be inferrable
	prevNode = p

	dir_from = get_dir(tile, prevNode.tile)
	jumps = _jmp
	goal = prevNode.goal
	nt = prevNode.nt + jumps
	h = PATH_DIST(tile, goal)
	f = nt + h//*(1+ PF_TIEBREAKER)


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
	var/maxnodedepth = 70
	var/maxnodes = 70
	var/adjacent = /turf/proc/reachableTurftest
	var/dist = /turf/proc/Distance
	var/turf/exclude = null
	var/simulated_only = TRUE
	var/done = FALSE

	var/nodes_queued_a
	var/nodes_queued_b
	var/nodes_queued_c

	var/list/evilnodes

/datum/pathfind/New(atom/movable/caller, atom/goal)
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	openc = new() //open list for node check
	visited = new() //open list for node check
	evilnodes = new() //open list for node check

//datum/pathfind/proc/generate_node(turf/the_tile, )
/datum/pathfind/proc/start_search()
	testing("**********start")
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
	var/datum/jpsnode/cur = new (start,null,0,end)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	visited[start] = -1
	evilnodes[start] = cur
	//then run the main loop
	var/total_tiles

	var/iii = 0
	while(!open.IsEmpty() && !path)
		if(done)
			testing("main exit: done [done] path [path]")
			break
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
		//var/closeenough
		//if(mintargetdist)
		//	closeenough = call(cur.tile,dist)(end) <= mintargetdist
		//cur.tile.color = COLOR_BLUE

		//found the target turf (or close enough), let's create the path to it
		//if(cur.tile == end || closeenough)
		//	testing("done? close enough: [closeenough]")
		//	unwind_path(cur)
		//	break

		//get adjacents turfs using the adjacent proc, checking for access with id
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = cur.tile
		lateral_scan_spec(current_turf, NORTH) // this is a turf not a node, fix
		lateral_scan_spec(current_turf, SOUTH) // this is a turf not a node, fix
		lateral_scan_spec(current_turf, EAST) // this is a turf not a node, fix
		lateral_scan_spec(current_turf, WEST) // this is a turf not a node, fix
		if(done || path)
			testing("mid main exit: done [done] path [path]")
			break
		diag_scan_spec(current_turf, NORTHWEST) // this is a turf not a node, fix
		diag_scan_spec(current_turf, SOUTHEAST) // this is a turf not a node, fix
		diag_scan_spec(current_turf, SOUTHWEST) // this is a turf not a node, fix
		diag_scan_spec(current_turf, NORTHEAST) // this is a turf not a node, fix
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("*********new path done with [total_tiles] tiles popped, [iii] rounds")
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
*
/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	//testing("unwind?")
	done = TRUE
	path = new()
	var/turf/iter_turf = unwind_node.tile
	var/turf/checkpoint_turf = visited[iter_turf]
	var/datum/jpsnode/iter_node = unwind_node.prevNode
	path.Add(iter_turf)
	var/i = 0
	while(iter_node)
		i++
		testing("unwinding path leg [i]")
		if(i > 200)
			CRASH("broke lol on unwind")
		var/turf/next_turf_goal = iter_node.tile
		//var/dir_goal = get_dir(iter_turf, unwind_node.prevNode.tile)
		var/dir_goal = get_dir(iter_turf, next_turf_goal)

		while(iter_turf != next_turf_goal)

			//iter_turf = get_step(iter_turf,dir_goal)
			iter_turf = get_step_towards(iter_turf,next_turf_goal)
			path.Add(iter_turf)
			iter_turf.color = COLOR_YELLOW
		if(iter_turf == end)
			return path
		else
			iter_node = iter_node.prevNode
*/

/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	for(var/turf/turf_clear in world)
		turf_clear.color = null
	testing("unwinding~~~~~~~~~~~~ (same? [unwind_node.tile == end])")
	path = new()
	var/turf/iter_turf = unwind_node.tile
	var/turf/iter_turf2 = get_turf(unwind_node.tile)
	path.Add(iter_turf)
	var/legs

	var/list/a = list(iter_turf)


	while(unwind_node.prevNode)
		legs++

		var/turf/goal_turf = unwind_node.prevNode.tile
		testing(">lega [legs] | <b>([goal_turf.x], ([goal_turf.y])</b>")
		var/i
		a.Add(goal_turf)
		goal_turf.color = COLOR_BLUE_GRAY
		while(iter_turf != goal_turf)
			i++
			var/turf/next_turf = get_step_towards(iter_turf, goal_turf)
			testing(">>>stepa [legs] | [i] - ([iter_turf.x], [iter_turf.y]) -> ([next_turf.x], [next_turf.y])")
			iter_turf = next_turf

			iter_turf.color = COLOR_BLUE_LIGHT
			//path.Add(iter_turf)
		unwind_node = unwind_node.prevNode
	testing("+++++++++end of A")

	legs = 0

	var/list/b = list(iter_turf2)
	var/turf/goal_turf2 = visited[iter_turf2]
	while(goal_turf2 && goal_turf2 != -1)
		b.Add(goal_turf2)
		legs++
		testing(">legb [legs] | <b>([goal_turf2.x], ([goal_turf2.y])</b>")
		var/i
		//goal_turf.color = COLOR_BLUE_GRAY
		while(iter_turf2 != goal_turf2)
			i++
			if(i > 100)
				break
			var/turf/next_turf = get_step_towards(iter_turf2, goal_turf2)
			testing(">>>stepa [legs] | [i] - ([iter_turf2.x], [iter_turf2.y]) -> ([next_turf.x], [next_turf.y])")
			iter_turf2 = next_turf
			path.Add(iter_turf2)
			//iter_turf.color = COLOR_BLUE_LIGHT
		goal_turf2 = visited[iter_turf2]
	testing("LENGTHS OF 2 LISTS| A: [a.len] B: [b.len] (final goaltuf2 = [goal_turf2])")

/datum/pathfind/proc/can_step(turf/a, turf/next)
	return call(a,adjacent)(caller, next, id, simulated_only)

/datum/pathfind/proc/queue_node(datum/tiles/t)
	testing("queue node current counts [nodes_queued_a] | [nodes_queued_b] | [nodes_queued_c]")
	nodes_queued_a++
	if(done || path)
		return
	if(!t)
		return
	var/turf/turf_for_node = t.dest_tile
	var/turf/moved_from = t.from
	var/jmps = t.jumps
	qdel(t)
	nodes_queued_b++

	if(!turf_for_node || !moved_from)
		return
	var/datum/jpsnode/our_node = openc[turf_for_node]
	var/datum/jpsnode/from_node = openc[moved_from]

	if(!moved_from)
		CRASH("missing from turf in queue?")

	if(our_node)
		testing("!!!!!!!!!!!!!!!!!!!!!!!!!!were trying to queue a node that already exists [turf_for_node.x] [turf_for_node.y]")
		turf_for_node.color = COLOR_BROWN
	else
	//is not already in open list, so add it
		testing("adding further node")
		nodes_queued_c++
		our_node = new(turf_for_node,moved_from)
		open.Insert(our_node)
		openc[turf_for_node] = our_node
		turf_for_node.color = COLOR_RED

/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
	var/i
	while(!unwind_node)
		i++
		testing("no unwind node on lat [i]")
		var/turf/older = visited[original_turf]
		unwind_node = openc[older]

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	original_turf.color = COLOR_PURPLE

	while(TRUE)
		if(done || path) // lazy way to force out when done, do better
			testing("card exit: done [done] path [path]")
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(steps_taken % 10 == 1)
			testing("taking lat step [steps_taken] in dir [heading]")

		if(!current_turf)
			return
		if(current_turf != original_turf)
			current_turf.color = COLOR_PINK

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? lat close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node, steps_taken)
			visited[current_turf] = original_turf
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return
		else if(visited[current_turf])
			current_turf.color = COLOR_BLACK
			return
		else if(!can_step(lag_turf, current_turf))
			current_turf.color = COLOR_ORANGE
			return
		else
			//visited[current_turf] = original_turf
			visited[current_turf] = original_turf
			/*if(!can_step(lag_turf, current_turf))
				testing("lat went into a turf that it couldn't step into??")
				current_turf.color = COLOR_WHITE
				return
			*/

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			return
		/*if(!(unwind_node.bf & heading))
			//testing("skip dir: [f] br: [cur.bf]")
			break
		*/


/*
		switch(heading)
			if(NORTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
			if(SOUTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
			if(EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
			if(WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					return new /datum/tiles(current_turf, original_turf, steps_taken)
*/
		switch(heading)
			if(NORTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
			if(SOUTH)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
			if(EAST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
			if(WEST)
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return

	testing("took [steps_taken] steps in dir [heading]")


/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jpsnode/unwind_node = openc[original_turf]
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf
	var/i
	while(!unwind_node)
		i++
		testing("no unwind node on diag [i]")
		var/turf/older = visited[original_turf]
		unwind_node = openc[older]

	original_turf.color = COLOR_VIBRANT_LIME
	while(TRUE)
		if(done || path) // lazy way to force out when done, do better
			testing("diag exit: done [done] path [path]")
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(steps_taken % 10 == 1)
			testing("taking diag step [steps_taken] in dir [heading]")

		if(!current_turf)
			return
		if(current_turf != original_turf)
			current_turf.color = COLOR_GRAY

		var/closeenough
		if(mintargetdist)
			closeenough = (PATH_DIST(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			testing("done? diag close enough: [closeenough]")
			var/datum/jpsnode/final_node = new(current_turf,unwind_node, steps_taken)
			visited[current_turf] = original_turf
			//open.Insert(current_turf)
			//openc[possible_interest] = neighbor_node
			unwind_path(final_node)
			return
		else if(visited[current_turf])
			current_turf.color = COLOR_BLACK
			return
		else if(!can_step(lag_turf, current_turf))
			current_turf.color = COLOR_ORANGE
			return
		else
			visited[current_turf] = original_turf

		if(steps_taken > 30)
			testing("too many steps, breaking to next")
			return


		switch(heading)
			if(NORTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, WEST)// this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, NORTH)// this is a turf not a node, fix
					//cardinal scan north
			if(NORTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, EAST)// this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, NORTH)) && can_step(current_turf, get_step(current_turf, NORTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, NORTH)// this is a turf not a node, fix
					//cardinal scan north
			if(SOUTHWEST)
				if(!can_step(current_turf, get_step(current_turf, WEST)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, WEST)// this is a turf not a node, fix
					//cardinal scan west
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHWEST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)// this is a turf not a node, fix
					//cardinal scan south
			if(SOUTHEAST)
				if(!can_step(current_turf, get_step(current_turf, EAST)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, EAST)// this is a turf not a node, fix
					//cardinal scan east
				if(!can_step(current_turf, get_step(current_turf, SOUTH)) && can_step(current_turf, get_step(current_turf, SOUTHEAST)))
					var/datum/jpsnode/newnode = new(current_turf, unwind_node, steps_taken)
					openc[current_turf] = newnode
					open.Insert(newnode)
					return
				else
					lateral_scan_spec(current_turf, SOUTH)// this is a turf not a node, fix

	testing("took [steps_taken] steps in dir [heading]")
