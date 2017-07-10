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
	var/datum/PathNode/parent	//link to the parent PathNode
	var/weight					//f A* Node weight (f = g + h)
	var/cost					//g A* movement cost variable
	var/heuristic				//h A* heuristic variable = h
	var/depth					//ht count the number of Nodes traversed
	var/PathNode/next			//next node in the linked list stack.

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
///proc/PathWeightCompare(datum/PathNode/a, datum/PathNode/b)
//	return a.weight - b.weight

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return b.weight - a.weight

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, list/exclude=null, simulated_only = 1)
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	if(!path)
		path = list()
	return path

/*/proc/AStar(...)
	var/static/const/num = 3
	var/static/cur = rand(0, num-1)
	if (prob(33))
		cur = ((cur + 1) % num)


	switch(cur)
		if(0)
			return AStar_new(arglist(args))
		if(1)
			return AStar_old(arglist(args))
		if(2)
			return AStar_goof(arglist(args))
		else
			throw EXCEPTION("invalid chain state")
*/
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
	var/list/path //the returned path, if any
	var/list/closed = exclude

	//initialization
	open.Insert(new /datum/PathNode(start, astar_id, null, 0, call(start ,dist)(end), 0))


	//then run the main loop
	while(length(open.L) && !path)
		path = AStar_whileloop(open, turfs, maxnodes, dist, end, mintargetdist, maxnodedepth, closed, adjacent, id, astar_id, simulated_only, caller)

		CHECK_TICK

	AStar_cleanup(turfs, astar_id)



	//reverse the path to get it from start to finish
	if (path)
		AStar_reverse(path)

	return path

/proc/AStar_reverse(list/path)
	for(var/i in 1 to  path.len/2)
		path.Swap(i,path.len-i+1)


/proc/AStar_cleanup(list/turfs, astar_id)
	//cleaning up after us
	for(var/thing in turfs)
		var/turf/T = thing
		var/datum/PathNode/head = T.pathnodes
		if (head.astar_id == astar_id)
			T.pathnodes = head.next
			continue
		var/datum/PathNode/P = head
		while (P)
			var/datum/PathNode/next = P.next
			if (next && next.astar_id == astar_id)
				P.next = next.next
				break
			P = next




/proc/AStar_whileloop(Heap/open, list/turfs, maxnodes, dist, turf/end, mintargetdist, maxnodedepth, list/exclude, adjacent, id, astar_id, simulated_only, caller)
	//get the lower f node on the open list
	var/datum/PathNode/cur = open.Pop() //current processed turf
	exclude += cur.source //and tell we've processed it

	//if we only want to get near the target, check if we're close enough
	var/closeenough
	if(mintargetdist)
		closeenough = call(cur.source, dist)(end) <= mintargetdist

	//if too many steps, abandon that path
	if(maxnodedepth && (cur.depth > maxnodedepth))
		return

	//found the target turf (or close enough), let's create the path to it
	if(cur.source == end || closeenough)
		var/list/path = list(cur.source)

		while(cur.parent)
			cur = cur.parent
			path.Add(cur.source)

		return path

	//get adjacent turfs using the adjacent proc, checking for access with id
	var/list/L = call(cur.source, adjacent)(caller, id, simulated_only)
	AStar_filter_turfs(L, cur, open, turfs, astar_id, dist, end, exclude)

/proc/AStar_filter_turfs(list/L, datum/PathNode/cur, Heap/open, list/turfs, astar_id, dist, end, list/exclude)
	for(var/turf/T in L-exclude)

		var/datum/PathNode/P = AStar_find_pathnode(T, astar_id)
		if(!P)
			AStar_make_new_pathnode(cur, dist, T, turfs, astar_id, end, open)

		else //is already in open list, check if it's a better way from the current turf
			AStar_check_existing_pathnode(cur, P, dist, L, T, open)

/proc/AStar_check_existing_pathnode(datum/PathNode/cur, datum/PathNode/P, dist, list/L, turf/T, Heap/open)
	var/newcost = cur.cost + call(cur.source, dist)(T)
	if(newcost < P.cost)
		AStar_recalc_existing_pathnode(cur, newcost, P, L, open)

/proc/AStar_recalc_existing_pathnode(datum/PathNode/cur, newcost, datum/PathNode/P, list/L, Heap/open)
	P.parent = cur
	P.cost = (newcost * length(L) / 9)
	P.weight = P.cost + P.heuristic
	P.depth = cur.depth + 1
	open.ReSort(P)//reorder the changed element in the list

/proc/AStar_make_new_pathnode(datum/PathNode/cur, dist, turf/T, turfs, astar_id, end, Heap/open)
	var/newcost = cur.cost + call(cur.source, dist)(T)
	var/datum/PathNode/newnode = new /datum/PathNode(T, astar_id, cur, newcost, call(T, dist)(end), cur.depth+1)
	open.Insert(newnode)
	newnode.next = T.pathnodes
	T.pathnodes = newnode
	turfs += T

/proc/AStar_find_pathnode(turf/T, astar_id)
	//99% of the time, the first node will be ours, so we can skip a for overhead by lazy accessing.
	var/datum/PathNode/P = AStar_find_pathnode_quick_try(T)

	if (!P || P.astar_id != astar_id)
		return AStar_find_pathnode_full_try(P, astar_id)

	return P

/proc/AStar_find_pathnode_full_try(datum/PathNode/P, astar_id)
	var/datum/PathNode/PN
	for(PN = P; PN && PN.astar_id != astar_id; PN = PN.next); //byond magic
	return PN

/proc/AStar_find_pathnode_quick_try(turf/T)
	return T.pathnodes


/turf/var/list/pathnodes


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
	source.PNode = src
	nt = pnt

/PathNode/proc/calc_f()
	f = g + h

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
///proc/PathWeightCompare2(PathNode/a, PathNode/b)
//	return a.f - b.f

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare2(PathNode/a, PathNode/b)
	return b.f - a.f

//the actual algorithm
/proc/AStar_goof(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	//sanitation
	var/start = get_turf(caller)
	if(!start)
		return 0

	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	var/Heap/open = new /Heap(/proc/HeapPathWeightCompare2) //the open list
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/PathNode/cur //current processed turf

	//initialization
	open.Insert(new /PathNode(start,null,0,call(start,dist)(end),0))

	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)

			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)

			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(caller,id, simulated_only)
		for(var/turf/T in L)
			if(T == exclude || (T in closed))
				continue

			var/newg = cur.g + call(cur.source,dist)(T)
			if(!T.PNode) //is not already in open list, so add it
				open.Insert(new /PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1))
			else //is already in open list, check if it's a better way from the current turf
				if(newg < T.PNode.g)
					T.PNode.prevNode = cur
					T.PNode.g = (newg * L.len / 9)
					T.PNode.calc_f()
					T.PNode.nt = cur.nt + 1
					open.ReSort(T.PNode)//reorder the changed element in the list


	//cleaning after us
	for(var/PathNode/PN in open.L)
		PN.source.PNode = null
	for(var/turf/T in closed)
		T.PNode = null

	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	return path

/turf/var/PathNode/PNode

//the actual algorithm
/proc/AStar_old(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/list/pnodelist = list()
	//sanitation
	var/start = get_turf(caller)
	if(!start)
		return 0

	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	var/Heap/open = new /Heap(/proc/HeapPathWeightCompare2) //the open list
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/PathNode/cur //current processed turf

	//initialization
	open.Insert(new /PathNode(start,null,0,call(start,dist)(end),0))

	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)

			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)

			break

		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(caller,id, simulated_only)
		for(var/turf/T in L)
			if(T == exclude || (T in closed))
				continue

			var/newg = cur.g + call(cur.source,dist)(T)

			var/PathNode/P = pnodelist[T]
			if(!P)
			 //is not already in open list, so add it
				var/PathNode/newnode = new /PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1)
				open.Insert(newnode)
				pnodelist[T] = newnode
			else //is already in open list, check if it's a better way from the current turf
				if(newg < P.g)
					P.prevNode = cur
					P.g = (newg * L.len / 9)
					P.calc_f()
					P.nt = cur.nt + 1
					open.ReSort(P)//reorder the changed element in the list


	//cleaning after us
	pnodelist = null

	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	return path

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
