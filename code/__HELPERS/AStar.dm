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

//////////////////////
//PathNode object
//////////////////////

//A* nodes variables
/datum/PathNode
	var/turf/source 			//turf associated with the PathNode
	var/astar_id				//Id of the astar operation we belong to
	var/closed = FALSE			//has this node been already eliminated?
	var/datum/PathNode/parent	//link to the parent PathNode
	var/weight					//f A* Node weight (f = g + h)
	var/cost					//g A* movement cost variable
	var/heuristic				//h A* heuristic variable = h
	var/depth					//ht count the number of Nodes traversed

/datum/PathNode/New(s, id, p, pg, ph, pnt)
	source = s
	astar_id = id
	parent = p
	cost = pg
	heuristic = ph
	weight = pg + ph
	depth = pnt


//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return a.weight - b.weight

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return b.weight - a.weight

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, list/exclude=null, simulated_only = 1)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	if(!path)
		path = list()
	return path

//the actual algorithm
/proc/AStar(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, list/exclude=null, simulated_only = 1)
	var/static/next_astar_id = 1
	var/astar_id = next_astar_id++

	//turfs we've looked at.
	var/list/turfs = list()
	//sanitation
	var/start = get_turf(caller)
	if(!start)
		return 0
	if (!islist(exclude))
		if (exclude)
			exclude = list(exclude)
		else
			exclude = list()

	//make it assoicated
	for (var/T in exclude)
		exclude[T] = 1

	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	var/Heap/open = new /Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/path = null //the returned path, if any
	var/datum/PathNode/cur //current processed turf

	//initialization
	open.Insert(new /datum/PathNode(start, astar_id, null, 0, call(start ,dist)(end), 0))

	//then run the main loop
	while(length(open.L) && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		cur.closed = TRUE //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source, dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.depth > maxnodedepth))
			continue

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)

			while(cur.parent)
				cur = cur.parent
				path.Add(cur.source)

			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(caller, id, simulated_only)
		for(var/turf/T in L)
			if(exclude[T])
				continue



			//99% of the time, the first node will be ours, so we can skip a for overhead by lazy accessing.
			var/datum/PathNode/P = LAZYACCESSFAST(T.pathnodes, 1)

			if (!P || P.astar_id != astar_id)
				P = null
				for (var/thing in T.pathnodes)
					var/datum/PathNode/PN = thing
					if (PN.astar_id == astar_id)
						P = PN
						break
			if(!P)
				//is not already in open list, so add it
				var/newcost = cur.cost + call(cur.source,dist)(T)
				var/datum/PathNode/newnode = new /datum/PathNode(T, astar_id, cur, newcost, call(T, dist)(end), cur.depth+1)
				open.Insert(newnode)
				LAZYADD(T.pathnodes, newnode)
				turfs += T

			else //is already in open list, check if it's a better way from the current turf
				if (P.closed)
					continue
				var/newcost = cur.cost + call(cur.source,dist)(T)
				if(newcost < P.cost)
					P.parent = cur
					P.cost = (newcost * length(L) / 9)
					P.weight = P.cost + P.heuristic
					P.depth = cur.depth + 1
					open.ReSort(P)//reorder the changed element in the list
		CHECK_TICK


	//cleaning up after us
	for(var/thing in turfs)
		var/turf/T = thing

		var/datum/PathNode/P = LAZYACCESSFAST(T.pathnodes, 1)

		if (!P || P.astar_id != astar_id)
			for (var/thing2 in T.pathnodes)
				var/datum/PathNode/PN = thing2
				if (PN.astar_id == astar_id)
					P = PN
					break

		T.pathnodes -= P
		UNSETEMPTY(T.pathnodes)



	//reverse the path to get it from start to finish
	if(path)
		for(var/i in 1 to  path.len/2)
			path.Swap(i,path.len-i+1)

	return path

/turf/var/list/pathnodes

//Returns adjacent turfs in cardinal directions that are reachable
//simulated_only controls whether only simulated turfs are considered or not
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T

	for(var/dir in GLOB.cardinal)
		T = get_step(src,dir)
		if(simulated_only && !istype(T))
			continue
		if(!T.density && !LinkBlockedWithAccess(T,caller, ID))
			L.Add(T)
	return L

//Returns adjacent turfs in cardinal directions that are reachable via atmos
/turf/proc/reachableAdjacentAtmosTurfs()
	return atmos_adjacent_turfs

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = get_dir(T, src)

	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return 1
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return 1

	return 0
