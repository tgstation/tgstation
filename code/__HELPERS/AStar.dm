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

	/turf/proc/reachableAdjacentTurfs : returns reachable turfs in all 8 directions (uses simulated_only)

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
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = TRUE, old=FALSE)
	var/l = SSpathfinder.mobs.getfree(caller)
	while(!l)
		stoplag(3)
		l = SSpathfinder.mobs.getfree(caller)

	var/list/path
	if(old == 1)
		path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	else if(old == -1) // head2head
		testing("<span class='danger'>-----------------------------------------------</span>")
		var/time_old = world.time
		var/list/old_path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
		var/old_done = world.time

		var/time_new = world.time
		var/datum/pathfind/pathfind_datum = new(caller, end, id, maxnodes, maxnodedepth, mintargetdist, simulated_only)
		path = pathfind_datum.start_search()
		var/new_done = world.time
		testing("Old| Path len: [old_path.len] | Time taken: [old_done - time_old]")
		testing("New| Path len: [path.len] | Time taken: [new_done - time_new]")

		qdel(pathfind_datum)

		testing("<span class='danger'>-----------------------------------------------</span>")
	else
		var/datum/pathfind/pathfind_datum = new(caller, end, id, maxnodes, maxnodedepth, mintargetdist, simulated_only)
		path = pathfind_datum.start_search()
		//path = path.Copy()
		testing("finished start_search(), length of path: [path ? path.len : "no path generated"]")
		qdel(pathfind_datum)

	SSpathfinder.mobs.found(l)
	if(!path)
		path = list()
	//return path

/// RYLL TODO: learn how to actually profile
/mob/living/proc/benchmark_path()

	var/list/path
	var/mob/living/caller = src
	var/obj/item/card/id/captains_spare/id = new(src)
	var/dist = /turf/proc/Distance_cardinal
	var/adjacent = /turf/proc/reachableTurftest
	var/maxnodes = 0
	var/maxnodedepth = 120
	var/exclude
	var/mintargetdist = 0
	var/simulated_only = TRUE

	var/start_time = world.time

	var/turf/first_start = get_turf(src)
	var/list/locations = list()
	for(var/i in 1 to 501)
		locations += get_turf(pick(GLOB.blobstart))

	var/old_time = world.time
	var/old_nodes = 0
	for(var/i in 1 to 500)
		var/turf/end = locations[i]
		old_nodes += AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
		forceMove(end)
		if(i % 100 == 0)
			testing("Old: [i]/500 rounds, time elapsed: [world.time - old_time] | Nodes created: [old_nodes]")
	testing("Old Time: [world.time - old_time]")

	forceMove(first_start)
	var/new_time = world.time
	var/new_nodes = 0
	for(var/i in 1 to 500)
		var/turf/end = locations[i]
		var/datum/pathfind/pathfind_datum = new(caller, end, id, maxnodes, maxnodedepth, mintargetdist, simulated_only)
		new_nodes += pathfind_datum.start_search()
		qdel(pathfind_datum)
		forceMove(end)
		if(i % 100 == 0)
			testing("New: [i]/500 rounds, time elapsed: [world.time - new_time] | Nodes created: [new_nodes]")

	testing("New Time: [world.time - new_time]")
	testing("Done!")


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
	var/datum/pathnode/cur = new /datum/pathnode(start,null,0,call(start,dist)(end),0,15,1)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	var/total_tiles = 0
	//then run the main loop
	while(!open.IsEmpty() && !path)
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		var/closeenough
		total_tiles++
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist


		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		if((!maxnodedepth)||(cur.nt <= maxnodedepth))//if too many steps, don't process that path
			for(var/i = 0 to 3)
				var/f= 1<<i //get cardinal directions.1,2,4,8
				if(cur.bf & f)
					var/T = get_step(cur.source,f)
					if(T != exclude)
						var/datum/pathnode/CN = openc[T]  //current checking turf
						var/r=((f & MASK_ODD)<<1)|((f & MASK_EVEN)>>1) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
						var/newg = cur.g + call(cur.source,dist)(T)
						if(CN)
						//is already in open list, check if it's a better way from the current turf
							CN.bf &= 15^r //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
							if((newg < CN.g) )
								if(call(cur.source,adjacent)(caller, T, id, simulated_only))
									CN.setp(cur,newg,CN.h,cur.nt+1)
									open.ReSort(CN)//reorder the changed element in the list
						else
						//is not already in open list, so add it
							if(call(cur.source,adjacent)(caller, T, id, simulated_only))
								CN = new(T,cur,newg,call(T,dist)(end),cur.nt+1,15^r)
								open.Insert(CN)
								openc[T] = CN
		cur.bf = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	//return path
	return total_tiles

/**
 * Returns adjacent turfs to this turf that are reachable, in all 8 directions (rather than just cardinal)
 *
 * Arguments:
 * * caller: The atom, if one exists, being used for mobility checks to see what tiles it can reach
 * * ID: An ID card that decides if we can gain access to doors that would otherwise block a turf
 * * simulated_only: Do we only worry about turfs with simulated atmos, most notably things that aren't space?
*/
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T
	var/static/space_type_cache = typecacheof(/turf/open/space)

	for(var/iter_dir in GLOB.alldirs)
		T = get_step(src,iter_dir)
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
