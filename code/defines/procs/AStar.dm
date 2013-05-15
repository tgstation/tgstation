priorityqueue
	var/pathnode/nodes[]	//list of pathnodes, sorted descending by f_score
	New()
		nodes = new()

priorityqueue/proc/insert(pathnode/n)
	if (!nodes.len)
		nodes.Add(n)
	else
		//linear search - slower than binary but guaranteed to work!
		var/pos = nodes.len
		while (pos > 0 && compare(n,nodes[pos]) > 0)
			pos--
		nodes.Insert(pos+1,n)

priorityqueue/proc/extract_last()
	var/pathnode/t = nodes[nodes.len]
	nodes.Cut(nodes.len)
	return t

priorityqueue/proc/compare(pathnode/a, pathnode/b)
	return (a.f_score - b.f_score)

pathnode
	var/turf/me				//turf
	var/pathnode/parent		//pathnode this turf was discovered from
	var/f_score				//total path-length of this turf
	var/g_score				//length of path to this turf

	New(m,p,f,g)
		me = m
		parent = p
		f_score = f
		g_score = g

/********************
/A* pathfinding algorithm
/This version updated May 2013 by Yvarov
/Returns a list of turfs along the discovered path, in order from start to finish.
/
/A* is more complex than can be easily explained here, but basically
/it checks tiles, assigning a score f = g + h where
/g = distance from start & h = minimum distance to end, and repeats with
/new tiles starting with the smallest f_score. It's capable of finding
/a path (assuming one exists), without getting stuck in wrong turns or
/unnecessarily checking unpromising tiles.
/
/The syntax for calling remains roughly the same as the version this replaces,
/minus two arguments (ones that were never given by any of
/the procs that called it anyway).

Possible procs to use for adjacency (there may be others):
/turf/proc/AdjacentTurfs
/turf/proc/AdjacentTurfsSpace
/turf/proc/CardinalTurfsWithAccess 	(best for most occasions, four-directional)

Possible procs to use for adjacency:
/turf/proc/Distance_cardinal		(requires four-directional adjacency proc)
/turf/proc/Distance					(requires eight-directional adjacency proc)

Arguments:
/turf/start_turf:	The turf to start the path from.
/turf/dest_turf:	The turf to finish the path on.
adjacent_proc:		The proc used to find adjacent tiles. When called, id is provided as an argument.
					For the best path to be found, it must only output tiles that could be reached in
					one move AND aren't occupied by something else, like a wall.
distance_proc:		Formula to use for calculating distance.
maxnodes:			Not used. Maximum number of nodes to examine; values for it were never provided.
					To avoid an (unlikely) infinite loop, a cutoff occurs at somewhat less than it took
					the old algorithm to path across the station.
max_length:			If the path is longer, return only this many elements of it (starting from the front).
					It can only be shortened after finding the whole path, so doesn't save any time,
					but as different values were provided throughout the code it's kept for compatibility.
id:					Supplied to the adjacency proc for doors/etc. Default is null.
/var/turf/exclude:	Turfs to avoid when finding a path. Default is null.

Nodes not kept at all from previous version (which were never supplied):
"Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example."
"Minnodedist: Minimum number of nodes to return in the path, could be used to give a path a minimum
length to avoid portals or something i guess?? Not that they're counted right now but w/e."
*********************/
proc/AStar(turf/start_turf, turf/dest_turf, adjacent_proc, distance_proc, maxnodes, max_length, id=null, var/turf/exclude=null)
	set background=1								//don't hog the CPU
	var/const/DEPTH_BIAS = 0.5						//preference of discovered paths. decrease with extreme caution and don't set >1!
	//var/evaluations = 0							//Total number of tiles examined, including discards and duplicates. Used for debugging
	var/lpct = 0									//Loop counter - turfs properly examined. Debugging and infinite loop prevention.
	var/pathnode/checked[] = new()					//list of pathnodes already examined
	var/priorityqueue/pq = new /priorityqueue()		//list of pathnodes not yet examined, sorted descending by f_score
	var/pathnode/current							//current pathnode being examined
	var/next_g										//calculated g_score of a potential turf
	var/next_f										//calculated f_score of a potential turf
	var/skip										//used for internal logic branching, don't touch.
	var/pathnode/temp								//temporary pathnode used for comparison, don't touch.

	//sanity check to avoid a huge waste of CPU time on impossible tasks
	for(var/obj/O in dest_turf)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags & ON_BORDER))
			var/list/path = new						//something is blocking the destination
			return path

	pq.insert(new /pathnode(start_turf, null, call(start_turf,distance_proc)(dest_turf),0))	//add the starting turf and manhattan distance to the queue!

	while (!pq.nodes.len || lpct < 1500)			//maximum for DEPTH_BIAS=0.5 is 958 loops to Research Division (originally 2743)
		lpct++
		current = pq.extract_last()
		checked.Add(current)

		if (!current)								//no more possibilities, or an unhandled error
			//world << "Impossible path"
			var/list/path = new						//returning 0 will get runtime errors
			return path								//FAILURE

		if (current.me == dest_turf)				//reached the destination
			var/list/path = new()
			path.Add(current.me)
			while (current.parent)					//recreate path by looping through parents
				current = current.parent
				path.Add(current.me)
			//world << "Path found! ([path.len] steps, [lpct] loops, [evaluations] evaluations)"

			for(var/i = 1; i <= path.len/2; i++)	//reverse path
				path.Swap(i,path.len-i+1)

			if (path.len > max_length)				//Truncate list at max_length (if necessary)
				path.Cut(max_length,0)
			return path								//SUCCESS

		next_g = current.g_score + DEPTH_BIAS
		var/adjacent = call(current.me,adjacent_proc)(id)
		for (var/next_turf in adjacent)
			//evaluations++
			if (next_turf == exclude)
				continue
			skip = 0
			next_f = next_g + call(next_turf,distance_proc)(dest_turf)
			var/i = 0
			while ( i < checked.len && !skip)
				i++
				temp = checked[i]
				if (temp.me == next_turf)			//if this turf has already been checked
					skip = 1
					if (temp.f_score > next_f)		//BUT the current path to it is better
						checked[i] = new /pathnode(next_turf, current, next_f, next_g)
													//then update it
			if (!skip)								//if it hasn't been checked
				i = 0
				while (i < pq.nodes.len && !skip)
					i++
					temp = pq.nodes[i]
					if (temp.me == next_turf)		//if this turf was already on the openlist
						if (temp.f_score > next_f)	//BUT the current path to it is better
							pq.nodes.Cut(i,i+1)		//then remove it
							skip = 2
						else
							skip = 1				//otherwise leave it and don't add this version
			if (!(skip % 2))
				pq.insert(new /pathnode(next_turf, current, next_f, next_g))


	//world << "Didn't find a path within [evaluations] evaluations and [lpct] loops."
	var/list/path = new								//prevents runtime errors
	return path										//FAILURE
	//This return should only be reached if the path is too long, and the while loop gives up.
