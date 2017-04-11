/proc/trace_pathfind(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/list/pnodelist = list()
	//sanitation
	var/start = get_turf(caller)
	var/turf/the_end = get_turf(end)
	if(!start)
		return 0

	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes

	var/Heap/open = new /Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/PathNode/cur //current processed turf

	//initialization
	var/PathNode/start_node = new /PathNode(start,null,0,call(start,dist)(end),0)
	start_node.g = 0
	start_node.f = 0
	open.Insert(start_node)

	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)

			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
			break

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		var/list/neighbors = call(cur.source,adjacent)(caller,id, simulated_only)

		var/ar = neighbors.len

		for(var/i in 1 to ar)
			var/turf/temp_turf = neighbors[i]
			var/ng
			var/PathNode/neighbor = pnodelist[temp_turf]
			if(!neighbor)
				ng = cur.g + (((temp_turf.x - cur.x) == 0 || (temp_turf.y - cur.y) == 0) ? 1 : sqrt(2))
				var/PathNode/newnode = new /PathNode(temp_turf,cur,ng,call(temp_turf,dist)(end),cur.nt+1,temp_turf.x,temp_turf.y)
				pnodelist[temp_turf] = newnode
				neighbor = newnode
			else
				if(closed.Find(neighbor))
					continue

			var/temp_x = neighbor.x
			var/temp_y = neighbor.y

			if(!open.L.Find(neighbor) || ng < neighbor.g)
				neighbor.g = ng * ar/9
				neighbor.h = neighbor.h || (abs(temp_x - the_end.x) + abs(temp_y - the_end.y))
				neighbor.f = neighbor.g + neighbor.h

				if(!open.L.Find(neighbor))
					open.Insert(neighbor)
				else
					open.ReSort(neighbor)
		CHECK_TICK


	//cleaning after us
	pnodelist = null

	//reverse the path to get it from start to finish
	if(path)
		for(var/i in 1 to path.len/2)
			path.Swap(i,path.len-i+1)

	return path