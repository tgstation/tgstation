/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, moving atom, distance proc, max nodes, maximum node depth, minimum distance to target, adjacent proc, atom id, turfs to exclude, check only simulated)

Optional extras to add on (in order):
Distance proc : the distance used in every A* calculation (length of path and heuristic)
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Adjacent proc : returns the turfs to consider around the actually processed node
Simulated only : whether to consider unsimulated turfs or not (used by some Adjacent proc)

Also added 'exclude' turf to avoid travelling over; defaults to null

Actual Adjacent procs :

	/turf/proc/reachableAdjacentTurfs : returns reachable turfs in cardinal directions (uses simulated_only)

	/turf/proc/reachableAdjacentAtmosTurfs : returns turfs in cardinal directions reachable via atmos

*/
#define PF_TIEBREAKER 0.005
//tiebreker weight.To help to choose between equal paths
//////////////////////
//datum/pathnode object
//////////////////////
#define MASK_ODD 85
#define MASK_EVEN 170


//A* nodes variables
/datum/pathnode
	var/turf/source //turf associated with the PathNode
	var/datum/pathnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g		//A* movement cost variable
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed
	var/bf		//bitflag for dir to expand.Some sufficiently advanced motherfuckery

/datum/pathnode/New(s,p,pg,ph,pnt,_bf)
	source = s
	prevNode = p
	g = pg
	h = ph
	f = g + h*(1+ PF_TIEBREAKER)
	nt = pnt
	bf = _bf

/datum/pathnode/proc/setp(p,pg,ph,pnt)
	prevNode = p
	g = pg
	h = ph
	f = g + h*(1+ PF_TIEBREAKER)
	nt = pnt

/datum/pathnode/proc/calc_f()
	f = g + h

//JPS nodes variables
/datum/jpsnode
	var/turf/source //turf associated with the PathNode
	var/datum/jpsnode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g = 1	// all steps cost 1, i dunno if we really need this var, nt works fine
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed
	var/bf		//bitflag for dir to expand.Some sufficiently advanced motherfuckery
	var/jumps // how many steps it took from the last node

/datum/jpsnode/New(s,p,ph,pnt,_bf, _jmp)
	source = s
	prevNode = p
	h = ph
	f = g + h*(1+ PF_TIEBREAKER)
	nt = pnt
	bf = _bf
	jumps = _jmp

/datum/jpsnode/proc/setp(p,ph,pnt, _jmp)
	prevNode = p
	h = ph
	f = g + h*(1+ PF_TIEBREAKER)
	nt = pnt
	jumps = _jmp

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/jpsnode/a, datum/jpsnode/b)
	return a.f - b.f

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/jpsnode/a, datum/jpsnode/b)
	return b.f - a.f

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = TRUE)
	var/l = SSpathfinder.mobs.getfree(caller)
	while(!l)
		stoplag(3)
		l = SSpathfinder.mobs.getfree(caller)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)

	SSpathfinder.mobs.found(l)
	if(!path)
		path = list()
	return path

/proc/cir_get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = TRUE)
	var/l = SSpathfinder.circuits.getfree(caller)
	while(!l)
		stoplag(3)
		l = SSpathfinder.circuits.getfree(caller)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	SSpathfinder.circuits.found(l)
	if(!path)
		path = list()
	return path

/proc/AStar(caller, _end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = TRUE)
	//sanitation
	var/turf/end = get_turf(_end)
	var/turf/start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if( start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes
	var/datum/heap/open = new /datum/heap(/proc/HeapPathWeightCompare) //the open list
	var/list/openc = new() //open list for node check
	var/list/path = null //the returned path, if any
	//initialization
	// RYLL NOTE: vvv HAD G=0, THAT WAS PROBABLY IMPORTANT
	var/datum/jpsnode/cur = new /datum/jpsnode(start,null,call(start,dist)(end),0,15,1)//current processed turf
	cur.g = 0 // RYLL EDIT PER ABOVE
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	while(!open.IsEmpty() && !path)
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		cur.source.color = COLOR_BLUE

		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist


		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough) // RYLL NOTE: the code for recreating the path will need to reflect the jumps
			testing("wheeee!! total dist [cur.nt]")
			path = new()

			var/turf/iter_turf = cur.source
			var/turf/next_goal_turf = cur.prevNode ? cur.prevNode.source : start
			path.Add(iter_turf)
			var/dir_heading

			while(cur.prevNode)
				iter_turf = cur.source
				next_goal_turf = cur.prevNode ? cur.prevNode.source : start
				dir_heading = get_dir(iter_turf, next_goal_turf)
				for(var/i in 1 to cur.jumps) // RYLL NOTE: this is my WIP attempt to handle the multiple jumps between pathnodes
					if(iter_turf == next_goal_turf)
						testing("We're already at our next dest turf!!!! [i]/[cur.jumps] jumps")
						break
					iter_turf.color = COLOR_YELLOW
					path.Add(iter_turf)
					var/turf/add_turf = iter_turf
					iter_turf = get_step(iter_turf, dir_heading)
					testing("1 ([iter_turf.x], [iter_turf.y]) to ([add_turf.x], [add_turf.y])")
				cur = cur.prevNode

			var/turf/final = cur.source
			dir_heading = get_dir(final, start)
			for(var/i in 1 to cur.jumps)
				if(final == start)
					testing("We're already at our original dest turf!!!! [i]/[cur.jumps] jumps")
					break
				final.color = COLOR_VIVID_YELLOW
				path.Add(final)
				var/turf/add_turf = final
				final = get_step(final, dir_heading)
				testing("2 ([final.x], [final.y]) to ([add_turf.x], [add_turf.y])")
			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		if(maxnodedepth && (cur.nt > maxnodedepth)) //if too many steps, don't process that path
			cur.bf = 0
			CHECK_TICK // explicitly copied in
			continue

		for(var/i = 0 to 3) // this is where we handle expanding vertically/horizontally to see which directions we can expand in. no preference for directions that go closer to the goal atm
			var/f= 1<<i //get cardinal directions.1,2,4,8
			if(!(cur.bf & f)) // we don't care about the direction we came from
				continue

			var/interesting = FALSE // have we found a tile that has a forced neighbor, I.E. will we be adding whatever tile we're inspecting to the open list?
			var/steps_taken = 0 // how many steps down the line horizontally/vertically we've gone from the tile we popped off the open list
			var/turf/sturf = cur.source // tracking what tile we have one step behind next_turf
			var/breakout = FALSE // used for

			while(TRUE) // keep checking in the given direction until we get an interesting hit or some other stop condition
				var/next_turf = get_step(sturf,f)
				var/turf/next_tu = next_turf
				steps_taken++
				if(steps_taken > maxnodedepth)
					testing("Cut out at [steps_taken] steps")
					break
				//testing("From ([next_tu.x], [next_tu.y]) step [steps_taken] in dir [f]")

				if(next_turf == end || call(next_turf,dist)(end) <= mintargetdist) // this is a specific and somewhat redundant check to see if we hit our goal, this should be optimized out
					var/turf/nex_tu = next_turf
					nex_tu.color = COLOR_GREEN
					testing("got to end in [steps_taken] steps")
					var/r=((f & MASK_ODD)<<1)|((f & MASK_EVEN)>>1)
					var/datum/jpsnode/CN = openc[next_turf]
					CN = new(next_turf,cur,call(next_turf,dist)(end),cur.nt+steps_taken,15^r, _jmp = steps_taken)
					open.Insert(CN)
					openc[next_turf] = CN
					breakout = TRUE
					break

				if(!next_turf || next_turf == exclude || !call(sturf,adjacent)(caller, next_turf, id, simulated_only)) // RYLL: should this be a typecheck?
					//breakout = TRUE
					break
				else if(call(next_turf,dist)(end) > call(sturf,dist)(end))
					testing("increasing dist, interesting")
					interesting = TRUE
				else
					for(var/i2 = 0 to 3) // we're checking some tile some number of steps down the line from the tile we popped off the open stack, see if there are any forced neighbor tiles we might find interesting adjacent to it
						var/f2= 1<<i2 //get cardinal directions.1,2,4,8
						var/r=((f & MASK_ODD)<<1)|((f & MASK_EVEN)>>1)
						if((f2 == r)) // ignore the direction we came from when looking for adjacent obstacles
							continue
						var/adjacent_next_turf = get_step(next_turf, f2) // this is the tile adjacent to the tile (next_turf) adjacent to the tile we're checking neighbors for (sturf). This lets us see if there's a diagonal forced neighbor, since 2 cards = diagonal


						if(!adjacent_next_turf || adjacent_next_turf == exclude || !call(next_turf,adjacent)(caller, adjacent_next_turf, id, simulated_only))
							interesting = TRUE
							break

				if(!interesting) // empty space with nothing next to it, keep moving
					var/turf/nex_tu = next_turf
					nex_tu.color = COLOR_MAROON
					sturf = next_turf
					continue // take one more step in whatever direction we're heading and repeat
				else
					var/turf/nex_tu = sturf
					nex_tu.color = COLOR_LIGHT_GRAYISH_RED

				// we have decided that sturf is an interesting tile, so let's handle adding it to the open list/modifying it if it's already in the open list
				var/datum/jpsnode/CN = openc[next_turf]  //see if this turf is in the open list
				var/r=((f & MASK_ODD)<<1)|((f & MASK_EVEN)>>1) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
				//var/newt = cur.nt + (call(cur.source,dist)(next_turf) * steps_taken)
				var/newt = cur.nt + steps_taken

				var/turf/nex_tu = next_turf
				nex_tu.color = COLOR_RED
				if(CN)
				//is already in open list, check if it's a better way from the current turf
					CN.bf &= 15^r //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
					if((newt < CN.nt) )
						CN.setp(cur,CN.h,cur.nt+steps_taken, _jmp = steps_taken)
						open.ReSort(CN)//reorder the changed element in the list
				else
				//is not already in open list, so add it
					CN = new(next_turf,cur,call(next_turf,dist)(end),cur.nt+steps_taken,15^r, _jmp = steps_taken)
					open.Insert(CN)
					openc[next_turf] = CN
				break

			if(breakout)
				break
		cur.bf = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	testing("done")
	return path

//Returns adjacent turfs in cardinal directions that are reachable
//simulated_only controls whether only simulated turfs are considered or not

/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T
	var/static/space_type_cache = typecacheof(/turf/open/space)

	for(var/k in 1 to GLOB.cardinals.len)
		T = get_step(src,GLOB.cardinals[k])
		if(!T || (simulated_only && space_type_cache[T.type]))
			continue
		if(!T.density && !LinkBlockedWithAccess(T,caller, ID))
			L.Add(T)
	return L

/turf/proc/reachableTurftest(caller, turf/T, ID, simulated_only)
	if(T && !T.density && !(simulated_only && SSpathfinder.space_type_cache[T.type]) && !LinkBlockedWithAccess(T,caller, ID))
		return TRUE

//Returns adjacent turfs in cardinal directions that are reachable via atmos
/turf/proc/reachableAdjacentAtmosTurfs()
	return atmos_adjacent_turfs

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = ((adir & MASK_ODD)<<1)|((adir & MASK_EVEN)>>1)
	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return TRUE

	return FALSE
