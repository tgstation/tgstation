#define PATH_DIST(A, B) (A.Distance_cardinal(B))
#define PATH_ADJ(A, B) (A.reachableTurftest(B))

#define PATH_REVERSE(A) ((A & MASK_ODD)<<1)|((A & MASK_EVEN)>>1)

//JPS nodes variables
/datum/jpsnode
	var/turf/source //turf associated with the PathNode
	var/datum/jpsnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g = 1	// all steps cost 1, i dunno if we really need this var, nt works fine
	var/h		//A* heuristic variable (distance)
	var/nt		//count the number of Nodes traversed
	var/bf		//bitflag for dir to expand.Some sufficiently advanced motherfuckery
	var/jumps // how many steps it took from the last node

/datum/jpsnode/New(s,p,ph,pnt,_bf, _jmp)
	source = s
	prevNode = p
	h = ph

	nt = pnt
	bf = _bf
	jumps = _jmp
	f = nt + h*(1+ PF_TIEBREAKER)

/datum/jpsnode/proc/setp(p,ph,pnt, _jmp)
	prevNode = p
	h = ph

	nt = pnt
	jumps = _jmp
	f = nt + h*(1+ PF_TIEBREAKER)



/datum/pathfind
	///
	var/atom/movable/caller

	var/turf/start
	///
	var/turf/end

	var/datum/heap/open //the open list

	var/list/openc //open list for node check



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

/datum/pathfind/proc/start_search()
	caller.calculating_path = TRUE
	var/list/path //the returned path, if any
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
	var/datum/jpsnode/cur = new (start,null,PATH_DIST(start, end),0,15,0)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	var/total_tiles

	while(!open.IsEmpty() && !path)
		//testing("pop")
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		total_tiles++
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist
		cur.source.color = COLOR_BLUE

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			testing("done? close enough: [closeenough]")
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
				cur.source.color = COLOR_YELLOW
			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		if((maxnodedepth)&&(cur.nt > maxnodedepth))//if too many steps, don't process that path
			continue

		for(var/i = 0 to 3)
			var/f= 1<<i //get cardinal directions.1,2,4,8
			if(!(cur.bf & f))
				//testing("skip dir: [f] br: [cur.bf]")
				continue
			var/turf/next_turf = get_step(cur.source,f)
			if(next_turf == exclude) //typecheck?
				continue
			var/datum/jpsnode/CN = openc[next_turf]  //current checking turf
			var/r=PATH_REVERSE(f) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
			var/newt = cur.nt + 1//PATH_DIST(cur.source, next_turf)

			//testing("let's see if CN exists [CN]")
			if(CN)
			//is already in open list, check if it's a better way from the current turf
				CN.bf &= 15^r //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
				if((newt < CN.nt) && call(cur.source,adjacent)(caller, next_turf, id, simulated_only))
					CN.setp(cur,cur.h,cur.nt+1)
					open.ReSort(CN)//reorder the changed element in the list
			else
			//is not already in open list, so add it
				if(call(cur.source,adjacent)(caller, next_turf, id, simulated_only))
					CN = new(next_turf,cur,PATH_DIST(next_turf, end),cur.nt+1,15^r)
					open.Insert(CN)
					openc[next_turf] = CN
		cur.bf = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("Old path done with [total_tiles] tiles popped")
	caller.calculating_path = FALSE
	return path

/datum/pathfind/proc/unwind_path(datum/jpsnode/unwind_node)
	//testing("unwind?")
	var/list/path = new()
	path.Add(unwind_node.source)
	while(unwind_node.prevNode)
		unwind_node = unwind_node.prevNode
		path.Add(unwind_node.source)
		unwind_node.source.color = COLOR_YELLOW

/datum/pathfind/proc/lateral_scan(datum/jpsnode/unwind_node)
	var/steps_taken = 0
	for(var/i = 0 to 3)
		steps_taken = 0
		var/f= 1<<i //get cardinal directions.1,2,4,8
		if(!(unwind_node.bf & f))
			//testing("skip dir: [f] br: [cur.bf]")
			continue
		var/turf/current_turf = unwind_node.source
		var/turf/next_turf = get_step(current_turf,f)
		if(next_turf == exclude) //typecheck?
			continue

		steps_taken++
		var/datum/jpsnode/next_node = openc[next_turf]  //current checking turf
		var/r=PATH_REVERSE(f) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
		var/newt = unwind_node.nt + 1//PATH_DIST(cur.source, next_turf)

		var/next_interesting = FALSE

		for(var/i2 = 0 to 3)
			var/f2= 1<<i2 //get cardinal directions.1,2,4,8
			if(r == f2 || f == f2)  // not going in the continuing direction, check the left and right turns
				continue
			//if(f != f2)
			var/turf/possible_block = get_step(current_turf, f2)
			var/turf/possible_interest = get_step(next_turf, f2)
			if(!call(current_turf,adjacent)(caller, possible_block, id, simulated_only) && call(next_turf,adjacent)(caller, possible_interest, id, simulated_only))
				var/datum/jpsnode/neighbor_node = openc[possible_interest]
				//testing("let's see if CN exists [CN]")
				if(neighbor_node)
				//is already in open list, check if it's a better way from the current turf

					if((newt < neighbor_node.nt))
						neighbor_node.setp(unwind_node,unwind_node.h,newt)
						open.ReSort(neighbor_node)//reorder the changed element in the list
						next_interesting = TRUE
				else
				//is not already in open list, so add it
					neighbor_node = new(possible_interest,unwind_node,PATH_DIST(possible_interest, end),newt,15^r)
					open.Insert(neighbor_node)
					openc[possible_interest] = neighbor_node
					next_interesting = TRUE

		if(next_interesting)
			var/turf/continuing_turf = get_step(next_turf, f)
			var/datum/jpsnode/continuing_node = openc[continuing_turf]
			//testing("let's see if CN exists [CN]")
			if(continuing_node)
			//is already in open list, check if it's a better way from the current turf

				if((newt < continuing_node.nt))
					continuing_node.setp(unwind_node,unwind_node.h,newt)
					open.ReSort(continuing_node)//reorder the changed element in the list
			else
			//is not already in open list, so add it
				continuing_node = new(continuing_turf,unwind_node,PATH_DIST(continuing_turf, end),newt,15^r)
				open.Insert(continuing_node)
				openc[possible_interest] = continuing_node
				next_interesting = TRUE
