/proc/cmp_pathnodes(pathnode/A, pathnode/B)
	return (A.f_score - B.f_score)

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
maxnodes:			Maximum _depth_ of nodes to examine; currently used only by disease.
					Not equal to the number of nodes to examine (lpct, internal) or the maximum path
					length returned (max_length below).
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
	set background=1								//allows proc to sleep should it take more than a single frame to complete
	
	var/const/DEPTH_BIAS = 0.5						//preference of discovered paths. decrease with extreme caution and don't set >1!
	//var/evaluations = 0							//Total number of tiles examined, including discards and duplicates. Used for debugging
	var/lpct = 0									//Loop counter - turfs properly examined. Debugging and infinite loop prevention.
	var/list/checked = list()						//list of pathnodes already examined
	var/list/priorityqueue = list()					//list of pathnodes not yet examined, sorted descending by f_score
	var/pathnode/current							//current pathnode being examined
	var/next_g										//calculated g_score of a potential turf
	var/next_f										//calculated f_score of a potential turf
	var/skip										//used for internal logic branching, don't touch.
	var/pathnode/temp								//temporary pathnode used for comparison, don't touch.
	
	var/list/path = list()							//return value

	//check to see if we can run a faster proc
	if(maxnodes == 1 || max_length == 1)
		return pathfind_adjacent(start_turf, dest_turf, adjacent_proc, id)
	var/dist = get_dist(start_turf, dest_turf)
	if(dist == 1)
		return pathfind_adjacent(start_turf, dest_turf, adjacent_proc, id)
	else if(dist == 2)
		return pathfind_directmove(start_turf, dest_turf, adjacent_proc, max_length, id, exclude)

	//sanity check to avoid a huge waste of CPU time on impossible tasks
	for(var/obj/O in dest_turf)
		if(O.density && (!istype(O, /obj/machinery/door) || !(O.flags & ON_BORDER)))	//something is blocking the destination
			return path
	
	priorityqueue += new /pathnode(start_turf, null, call(start_turf,distance_proc)(dest_turf), 0)//add the starting turf and manhattan distance to the queue!

	for(lpct=0, lpct<1800, lpct++)				//maximum for DEPTH_BIAS=0.5 is 958 loops to Research Division (originally 2743)
		if(!priorityqueue.len) break

		current = pop(priorityqueue)
		checked.Add(current)

		next_g = current.g_score + DEPTH_BIAS
		//if(maxnodes && next_g > (maxnodes*DEPTH_BIAS)) continue

		if(!current)								//no more possibilities, or an unhandled error
			//world << "Impossible path"
			return path								//FAILURE

		if(current.me == dest_turf)				//reached the destination
			while(current)						//recreate path by looping through parents
				path.Insert(1, current.me)
				current = current.parent
			//world << "Path found! ([path.len] steps, [lpct] loops, [evaluations] evaluations)"

			path.len = min(path.len, max_length-1)
			return path								//SUCCESS

		var/adjacent = call(current.me,adjacent_proc)(id)
		for(var/next_turf in adjacent)
			//evaluations++
			if(next_turf == exclude)
				continue
			skip = 0
			next_f = next_g + call(next_turf,distance_proc)(dest_turf)
			var/i = 0
			while(i < checked.len && !skip)
				i++
				temp = checked[i]
				if(temp.me == next_turf)			//if this turf has already been checked
					skip = 1
					if(temp.f_score > next_f)		//BUT the current path to it is better
						checked[i] = new /pathnode(next_turf, current, next_f, next_g)
													//then update it
			if(!skip)								//if it hasn't been checked
				i = 0
				while(i < priorityqueue.len && !skip)
					i++
					temp = priorityqueue[i]
					if(temp.me == next_turf)		//if this turf was already on the openlist
						if(temp.f_score > next_f)	//BUT the current path to it is better
							priorityqueue.Cut(i,i+1)		//then remove it
							skip = 2
						else
							skip = 1				//otherwise leave it and don't add this version
			if(!(skip % 2))
				sorted_insert(priorityqueue, new /pathnode(next_turf, current, next_f, next_g), /proc/cmp_pathnodes)

	//world << "Didn't find a path within [evaluations] evaluations and [lpct] loops."
	return path										//FAILURE
	//This return should only be reached if the path is too long, and the while loop gives up.

//Use this proc to check if a turf 1 tile away is reachable
//There are a few things that appear to use AStar just to check if something is within reach
//Untested
proc/pathfind_adjacent(turf/start_turf, turf/dest_turf, adjacent_proc, id)
	var/adjacent = call(start_turf,adjacent_proc)(id)
	if(dest_turf in adjacent)
		return list(dest_turf)
	return list()

//Pathfind directly towards the target, with obstacle avoidance best described as "dodging"
//This is a relatively crude algorithm, but it should work well for very short distances (1-2), or across areas with minimal obstacles
//It has a high bias in certain directions, and has a high chance to fail if there is a concurrent series of obstacles
//Untested
proc/pathfind_directmove(turf/start_turf, turf/dest_turf, adjacent_proc, max_length, id=null, var/turf/exclude=null)
	var/list/path = list()
	var/turf/current_turf = start_turf
	var/turf/priority_candidate

	for(var/current_iteration = 0, current_iteration < max_length, current_iteration++)
		if(current_turf == dest_turf)
			return path

		//populate candidates list from current location
		var/target_dir = get_dir(current_turf, dest_turf)
		var/list/adjacent = call(current_turf,adjacent_proc)(id)
		var/list/candidates = list()

		//check straight forward and diagonally forward only
		for(var/try_dir in alldirs)
			if(try_dir&target_dir)
				//grab the turf, and check that it's reachable
				var/turf/try_turf = get_step(current_turf, try_dir)

				//A further optimisation could be made here by ripping out the guts to adjacent_proc and only running it's checks on check_turf
				if(try_turf in adjacent)
					candidates += try_turf
					if(try_dir == target_dir)
						priority_candidate = try_turf

		if(exclude && priority_candidate == exclude)
			priority_candidate = null

		//the priority candidate turf moves us directly towards the destination
		if(priority_candidate)
			current_turf = priority_candidate
			priority_candidate = null
		else
			//this should have at most 2 turfs in it
			while(candidates.len)
				current_turf = candidates[1]
				if(current_turf == exclude)
					exclude = null
					candidates.Remove(exclude)
				else
					break

		if(current_turf)
			path += current_turf
		else
			break

	//we failed, so return an empty list
	return list()
