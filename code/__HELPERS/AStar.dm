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
/PathNode
	var/turf/source //turf associated with the PathNode
	var/PathNode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g		//A* movement cost variable
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed

/PathNode/New(s,p,pg,ph,pnt)
	source = s
	prevNode = p
	g = pg
	h = ph
	f = g + h
	nt = pnt

/PathNode/proc/calc_f()
	f = g + h

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(PathNode/a, PathNode/b)
	return a.f - b.f

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(PathNode/a, PathNode/b)
	return b.f - a.f

//wrapper that returns the AStar datum or null if it is unable to be started
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	return AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)

/datum/proc/recieveAStarResult(path)
	return

/proc/AStar(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/datum/AStar/alg = new
	if(!alg.Setup(caller, get_turf(caller), end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent, id, exclude, simulated_only))
		qdel(alg)
		return FALSE
	if(!alg.Start())
		qdel(alg)
		return FALSE
	return alg	//Return AStar datum

/datum/AStar
	var/caller
	var/list/pnodelist = list()
	var/turf/start
	var/Heap/open
	var/list/closed = list()
	var/list/path = null
	var/PathNode/cur
	var/ready = FALSE
	var/processing = FALSE
	var/finished = FALSE
	var/end
	var/dist
	var/maxnodes
	var/maxnodedepth
	var/mintargetdist
	var/adjacent
	var/id
	var/exclude
	var/simulated_only

//Set the algorithm up
/datum/AStar/proc/Setup(_caller, turf/starting, _end, _dist, _maxnodes, _maxnodedepth = 30, _mintargetdist, _adjacent = /turf/proc/reachableAdjacentTurfs, _id=null, turf/_exclude=null, _simulated_only = TRUE)
	if(!caller)
		return FALSE
	_caller = caller
	start = starting
	end = _end
	dist = _dist
	maxnodes = _maxnodes
	maxnodedepth = _maxnodedepth
	mintargetdist = _mintargetdist
	adjacent = _adjacent
	id = _id
	exclude = _exclude
	simulated_only = _simulated_only

	if(!istype(start))
		return FALSE
	if(maxnodes)
		//If start turf is farther than maxnodes don't bother.
		if(call(start, dist)(end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes	//No need to consider path longer than maxnodes
	open = new /Heap(/proc/HeapPathWeightCompare)
	open.Insert(new /PathNode(start,null,0,call(start,dist)(end),0))
	ready = TRUE
	return TRUE

/datum/AStar/proc/sendPath()
	INVOKE_ASYNC(caller, .proc/recieveAStarResult, path)

//Initiate!
/datum/AStar/proc/Start()
	if(!ready)
		return FALSE
	START_PROCESSING(SSpathing, src)
	processing = TRUE
	return TRUE

//Primary loop
/datum/AStar/process()
	if(open.IsEmpty() && path)	//We're done
		return Finish()

	//Get the lower F node on the open list
	cur = open.Pop()	//Get the lower F turf in the open list
	closed.Add(cur.source)	//And tell we've processed it

	//If we don't need to be exactly on the target, check if we're close enough
	var/closeenough
	if(mintargetdist)
		closeenough = call(cur.source,dist)(end) <= mintargetdist

	//If too many steps, abandon path
	if(maxnodedepth && (cur.nt > maxnodedepth))
		return

	//Found target turf/close enough, create path
	if(cur.source == end || closeenough)
		path = new()
		path.Add(cur.source)
		while(cur.prevNode)
			cur = cur.prevNode
			path.Add(cur.source)
			CHECK_TICK
		return Finish()

	//Get adjacent turfs using adjacent proc, checking for access with id
	var/list/L = call(cur.source,adjacent)(caller,id,simulated_only)
	for(var/turf/T in L)
		if(T == exclude || (T in closed))
			continue
		var/newg = cur.g + call(cur.source,dist)(T)
		var/PathNode/P = pnodelist[T]
		if(!P)
			//Isn't already in open list, add!
			var/PathNode/newnode = new /PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1)
			open.Insert(newnode)
			pnodelist[T] = newnode
		else
			//Already in open list, check if it's a better way from the current turf.
			if(newg < P.g)
				P.prevNode = cur
				P.g = (newg * L.len / 9)
				P.calc_f()
				P.nt = cur.nt + 1
				open.ReSort(P)	//Reorder the changed element in the list

/datum/AStar/proc/Finish()
	finished = TRUE
	ready = FALSE
	processing = FALSE
	pnodelist = null	//Clean up
	if(path)			//Reverse path for start to finish.
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i, path.len-i+1)
	sendPath()
	return PROCESS_KILL

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
			return TRUE
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return TRUE

	return FALSE
