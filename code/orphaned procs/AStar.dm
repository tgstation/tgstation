/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, adjacent turf proc, distance proc)
For the adjacent turf proc i wrote:
/turf/proc/AdjacentTurfs
And for the distance one i wrote:
/turf/proc/Distance
So an example use might be:

src.path_list = AStar(src.loc, target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance)

Then to start on the path, all you need to do it:
Step_to(src, src.path_list[1])
src.path_list -= src.path_list[1] or equivilent to remove that node from the list.

Optional extras to add on (in order):
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Minnodedist: Minimum number of nodes to return in the path, could be used to give a path a minimum
length to avoid portals or something i guess?? Not that they're counted right now but w/e.
*/

// Modified to provide ID argument - supplied to 'adjacent' proc, defaults to null
// Used for checking if route exists through a door which can be opened

// Also added 'exclude' turf to avoid travelling over; defaults to null

//Currently, there's four main ways to call AStar
//
// 1) adjacent = "/turf/proc/AdjacentTurfsWithAccess" and distance = "/turf/proc/Distance"
//	Seeks a path moving in all directions (including diagonal) and checking for the correct id to get through doors
//
// 2) adjacent = "/turf/proc/CardinalTurfsWithAccess" and distance = "/turf/proc/Distance_cardinal"
//  Seeks a path moving only in cardinal directions and checking if for the correct id to get through doors
//  Used by most bots, including Beepsky
//
// 3) adjacent = "/turf/proc/AdjacentTurfs" and distance = "/turf/proc/Distance"
//  Same as 1), but don't check for ID. Can get only get through open doors
//
// 4) adjacent = "/turf/proc/AdjacentTurfsSpace" and distance = "/turf/proc/Distance"
//  Same as 1), but check all turf, including unsimulated

//////////////////////
//PriorityQueue object
//////////////////////

//an ordered list, using the cmp proc to weight the list elements
/PriorityQueue
	var/list/L //the actual queue
	var/cmp //the weight function used to order the queue

/PriorityQueue/New(compare)
	L = new()
	cmp = compare

/PriorityQueue/proc/IsEmpty()
	return !L.len

//add an element in the list,
//immediatly ordering it to its position using Insertion sort
/PriorityQueue/proc/Enqueue(atom/A)
	var/i
	L.Add(A)
	i = L.len -1
	while(i > 0 &&  call(cmp)(L[i],A) >= 0) //place the element at it's right position using the compare proc
		L.Swap(i,i+1) 						//last inserted element being first in case of ties (optimization)
		i--

//removes and returns the first element in the queue
/PriorityQueue/proc/Dequeue()
	if(!L.len)
		return 0
	. = L[1]
	Remove(.)
	return .

//removes an element
/PriorityQueue/proc/Remove(atom/A)
	return L.Remove(A)

//returns a copy of the elements list
/PriorityQueue/proc/List()
	var/list/ret = L.Copy()
	return ret

//return the position of an element or 0 if not found
/PriorityQueue/proc/Seek(atom/A)
	return L.Find(A)

//return the element at the i_th position
/PriorityQueue/proc/Get(i)
	if(i > L.len || i < 1)
		return 0
	return L[i]

//replace the passed element at it's right position using the cmp proc
/PriorityQueue/proc/ReSort(atom/A)
	var/i = Seek(A)
	if(i == 0)
		return
	while(i < L.len && call(cmp)(L[i],L[i+1]) > 0)
		L.Swap(i,i+1)
		i++
	while(i > 1 && call(cmp)(L[i],L[i-1]) <= 0) //last inserted element being first in case of ties (optimization)
		L.Swap(i,i-1)
		i--

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
/proc/PathWeightCompare(PathNode/a, PathNode/b)
	return a.f - b.f

//search if there's a PathNode that points to turf T in the Priority Queue
/proc/SeekTurf(var/PriorityQueue/Queue, turf/T)
	var/i = 1
	var/PathNode/PN
	while(i < Queue.L.len + 1)
		PN = Queue.L[i]
		if(PN.source == T)
			return i
		i++
	return 0

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(start, end, atom, dist, maxnodes, maxnodedepth = 30, mintargetdist, minnodedist, id=null, turf/exclude=null)
	var/list/path = AStar(start, end, atom, dist, maxnodes, maxnodedepth, mintargetdist, minnodedist,id, exclude)
	if(!path)
		path = list()
	return path

//the actual algorithm
/proc/AStar(start, end, atom, dist, maxnodes, maxnodedepth = 30, mintargetdist, minnodedist, id=null, turf/exclude=null)
	var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare) //the open list, ordered using the PathWeightCompare proc, from lower f to higher
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/PathNode/cur //current processed turf

	//sanitation
	start = get_turf(start)
	if(!start)
		return 0

	//initialization
	open.Enqueue(new /PathNode(start,null,0,call(start,dist)(end),0))

	//then run the main loop
	while(!open.IsEmpty() && !path)
	{
		//get the lower f node on the open list
		cur = open.Dequeue() //get the lower f turf in the open list
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

		//IMPLEMENTATION TO FINISH
		//do we really need this minnodedist ???
		/*if(minnodedist && maxnodedepth)
			if(call(cur.source,minnodedist)(end) + cur.nt >= maxnodedepth)
				continue
		*/

		//get adjacents turfs using the adjacent proc, checking for access with id
		//var/list/L = call(cur.source,adjacent)(id,closed)
		var/list/L = cur.source.reachableAdjacentTurfs(atom, id)
		for(var/turf/T in L)
			if(T == exclude)
				continue

			var/newg = cur.g + call(cur.source,dist)(T)
			if(!T.PNode) //is not already in open list, so add it
				open.Enqueue(new /PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1))
			else //is already in open list, check if it's a better way from the current turf
				if(newg < T.PNode.g)
					T.PNode.prevNode = cur
					T.PNode.g = newg
					T.PNode.calc_f()
					open.ReSort(T.PNode)//reorder the changed element in the list

	}

	//cleaning after us
	for(var/PathNode/PN in open.L)
		PN.source.PNode = null
	for(var/turf/T in closed)
		T.PNode = null

	//if the path is longer than maxnodes, then don't return it
	if(path && maxnodes && path.len > (maxnodes + 1))
		return 0

	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	return path

/turf/proc/reachableAdjacentTurfs(atom, ID)
	var/list/L = new()
	var/turf/simulated/T
	if(ID)
		for(var/dir in cardinal)
			T = get_step(src,dir)
			if(!istype(T) || T.density)
				continue
			if(!LinkBlockedWithAccess(T, ID))
				L.Add(T)
	else
		for(var/dir in cardinal)
			if(dir & atmos_adjacent_turfs)
				T = get_step(src,dir)
				if(!istype(T))
					continue
				if(!LinkBlocked(atom, T))
					L.Add(T)
	return L

/turf/proc/LinkBlocked(atom, turf/T)
	if(istype(atom, /atom/movable))
		for(var/obj/O in T)
			if(!O.CanPass(atom, T, 1))
				return 1
		return 0
	return 0

/turf/proc/LinkBlockedWithAccess(turf/T, obj/item/weapon/card/id/ID)
	var/adir = get_dir(src, T)
	var/rdir = get_dir(T, src)
	if(DirBlockedWithAccess(src, adir, ID))
		return 1
	if(DirBlockedWithAccess(T, rdir, ID))
		return 1
	for(var/obj/O in T)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags & ON_BORDER))
			return 1
	return 0

/proc/DirBlockedWithAccess(turf/T, dir, ID)
	for(var/obj/structure/window/D in T)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)
			return 1
		if(D.dir == dir)
			return 1
	for(var/obj/machinery/door/D in T)
		if(!D.CanAStarPass(ID, dir))
			return 1
	return 0