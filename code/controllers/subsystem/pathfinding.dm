// This file contains the pathfinding subsystem and all base procs related to pathfinding.

SUBSYSTEM_DEF(pathfinding)
	name = "Pathfinding"
	init_order = INIT_ORDER_PATH
	flags = SS_NO_FIRE
	var/list/queues = list()
	var/static/list/max_per_queue = list(
		PATHFINDING_QUEUE_DEFAULT = 10,
		PATHFINDING_QUEUE_MOBS = 10
	)
	var/static/list/queue_timeouts = list(
		PATHFINDING_QUEUE_DEFAULT = 10 SECONDS,
		PATHFINDING_QUEUE_MOBS = 10 SECONDS
	)
	var/static/space_type_cache
#ifdef PATHFINDING_DEBUG
	var/static/mutable_appearance/pathfinding_node = mutable_appearance('icons/debug/pathfinding.dmi', "node")
	var/static/node_color_starting = rgb(255, 150, 150)
	var/static/node_color_current = rgb(255, 255, 0)
	var/static/node_color_potential = rgb(100, 100, 255)
	var/static/node_color_explored = rgb(150, 150, 150)
	var/static/node_color_goal = rgb(100, 255, 100)
	var/static/node_alpha = 125
	var/static/mutable_appearance/arrow_to_node = mutable_appearance('icons/debug/pathfinding_path.dmi', "arrow_solid")
	var/static/mutable_appearance/continuous_to_node = mutable_appearance('icons/debug/pathfinding_path.dmi', "continuous_solid")
	var/static/mutable_appearance/arrow_terminated = mutable_appearance('icons/debug/pathfinding_path.dmi', "arrow_dotted")
	var/static/mutable_appearance/continuous_terminated = mutable_appearance('icons/debug/pathfinding_path.dmi', "continuous_dotted")

	var/static/loop_delay = 0.5
	var/static/visualize_jps_linescanning = FALSE
	var/static/visual_lifetime = 10 SECONDS
#endif

/datum/controller/subsystem/pathfinding/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	return ..()

#ifdef PATHFINDING_DEBUG
/obj/effect/overlay/pathfinding
	name = "pathfinding debug overlay"
#endif

#define CARDINAL_METRIC(A, B)		(abs(A.x - B.x) + abs(A.y - B.y))
#define DIAGONAL_METRIC(A, B)		get_dist(A, B)
#define EUCLIDEAN_METRIC(A, B)		(sqrt((A.x - B.x)**2 + (A.y - B.y)**2))
#define DIST(A, B)					(diagonal_allowed? DIAGONAL_METRIC(A, B) : CARDINAL_METRIC(A, B))

/**
  * Warns and logs when a pathfinding operation times out. Since we don't want to add more overhead, we can't terminate it early, but we can record it.
  */
/datum/controller/subsystem/pathfinding/proc/warn_overtime(message)
	message_admins("Pathfinding Timeout: [message]")
	CRASH(message)

#warn is it possible to inline this easily later because this is just unnecessary overhead
/**
  * A node used for the A* "family" of pathfinding algorithms.
  */
/datum/path_node
	/// The turf we represent
	var/turf/turf
	/// The previous path_node we're from
	var/datum/path_node/previous
	/// A* node weight
	var/weight
	/// Movement cost from the start of the pathfind to us
	var/cost
	/// Heuristic of cost needed to get to end.
	var/heuristic
	/// Our node depth
	var/depth
	/// Dir to expand in.
	var/expansion_dir

/datum/path_node/New(turf, previous, cost, heuristic, depth, expansion_dir)
	src.turf = turf
	src.previous = previous
	src.weight = cost + heuristic * PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT
	src.cost = cost
	src.heuristic = heuristic
	src.depth = depth
	src.expansion_dir = expansion_dir

/datum/path_node/proc/set_previous(new_previous, new_cost, new_heuristic, new_depth)
	previous = new_previous
	cost = new_cost
	heuristic = new_heuristic
	depth = new_depth
	f=  cost * new_heuristic * PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT

/**
  * Runs a pathfind with jump point search, a variant of A* with much, much higher performance.
  * You want to use this whenever possible.
  * The only reason you would have to NOT use this, is if you want to have different turfs have different costs to travel over.
  * This is also not going to at times return as good/uniform of a path as normal A*
  * In general though, it won't matter much, so use this if you can, as this is an order of magnitude faster than A* proper.
  *
  * Returns either a list of turfs forming a path to the target or a list of turfs constituted of the nodes of the path found.
  * If queue is full, returns PATHFIND_FAIL_QUEUE_FULL.
  * **WARNING**: Unlike base AStar, this does not return a continuous list of turfs! You must handle this yourself, as this proc is already slow enough without adding the overhead of automatically converting this list into a continuous stream of turfs.
  *
  * @params
  * * caller - What called this. Can be null, datum, atom, whatever.
  * * start - turf to start on. If not set, defaults to caller's turf if it's an atom. If neither are set, the proc crashes.
  * * end - turf to path to.
  * * can_cross_proc - proc to call on turfs to find if we can pass from it to another turf. /turf/proc/procname, called with arguments(caller, turf/trying_to_reach)
  * * heuristic type. see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. 0 for infinite.
  * * max_path_nodes - maximum nodes the returned path can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinding/proc/JPS_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_nodes = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinding.space_type_cache, queue = PATHFINDER_QUEUE_DEFAULT, obj/item/card/id/ID)
	if(!end)
		. = PATHFIND_FAIL_NO_END_TURF
		CRASH("No ending turf")
	if(!start)
		start = get_turf(caller)
		if(!start)
			. = PATHFIND_FAIL_NO_START_TURF
			CRASH("No starting turf")
	LAZYINITLIST(queues[queue])
	if(length(queues[queue]) > max_per_queue[queue])
		return PATHFIND_FAIL_QUEUE_FULL
	var/timeout = queue_timeouts[queue] || 10 SECONDS
	var/timerid = addtimer(CALLBACK(src, .proc/warn_overtime, "JPS pathfind timed out over [timeout]: [caller], [COORD(start)], [COORD(end)], ..."), timeout, TIMER_STOPPABLE)
	queues[queue] += timerid
	. = run_JPS_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_nodes, min_target_distance, turf_blacklist_typecache)
	deltimer(timerid)
	queues[queue] -= timerid

/datum/controller/subsystem/pathfinding/proc/run_JPS_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_nodes, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
	PRIVATE_PROC(TRUE)

/**
  * Runs a pathfind with normal A*
  * For 99.99% of applications, you probably want JPS, seen above.
  * The reason A* is kept is because it's more likely to return a more optimized path.
  * Plus, in the far unknown future because I am so, so sure someone will give a care about this, you can implement turf movement costs.
  * However, for the most part, yeah haha nah, use JPS, not worth the CPU cost.
  *
  * @params
  * * caller - What called this. Can be null, datum, atom, whatever.
  * * start - turf to start on. If not set, defaults to caller's turf if it's an atom. If neither are set, the proc crashes.
  * * end - turf to path to.
  * * can_cross_proc - proc to call on turfs to find if we can pass from it to another turf. /turf/proc/procname, called with arguments(caller, turf/trying_to_reach)
  * * heuristic type. see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. 0 for infinite.
  * * max_path_nodes - maximum nodes the returned path can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinding/proc/AStar_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_nodes = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinding.space_type_cache, queue = PATHFINDER_QUEUE_DEFAULT, obj/item/card/id/ID)
	if(!end)
		. = PATHFIND_FAIL_NO_END_TURF
		CRASH("No ending turf")
	if(!start)
		start = get_turf(caller)
		if(!start)
			. = PATHFIND_FAIL_NO_START_TURF
			CRASH("No starting turf")
	LAZYINITLIST(queues[queue])
	if(length(queues[queue]) > max_per_queue[queue])
		return PATHFIND_FAIL_QUEUE_FULL
	var/timeout = queue_timeouts[queue] || 10 SECONDS
	var/timerid = addtimer(CALLBACK(src, .proc/warn_overtime, "AStar pathfind timed out over [timeout]: [caller], [COORD(start)], [COORD(end)], ..."), timeout, TIMER_STOPPABLE)
	queues[queue] += timerid
	. = run_AStar_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_nodes, min_target_distance, turf_blacklist_typecache)
	deltimer(timerid)
	queues[queue] -= timerid

/datum/controller/subsystem/pathfinding/proc/run_AStar_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_nodes, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
	PRIVATE_PROC(TRUE)

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/path_node/a, datum/path_node/b)
	return a.weight - b.weight

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/path_node/a, datum/path_node/b)
	return b.weight - a.weight

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
		if(DIST(start, end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes
	var/datum/Heap/open = new /datum/Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/openc = new() //open list for node check
	var/list/path = null //the returned path, if any
	//initialization
	var/datum/path_node/cur = new /datum/path_node(start,null,0,DIST(start, end),0,15,1)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	while(!open.IsEmpty() && !path)
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = DIST(cur.turf, end) <= mintargetdist

		//found the target turf (or close enough), let's create the path to it
		if(cur.turf == end || closeenough)
			path = new()
			path.Add(cur.turf)
			while(cur.previous)
				cur = cur.previous
				path.Add(cur.turf)
			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		if((!maxnodedepth)||(cur.nt <= maxnodedepth))//if too many steps, don't process that path
			for(var/i = 0 to 3)
				var/f= 1<<i //get cardinal directions.1,2,4,8
				if(cur.expansion_dir & f)
					var/T = get_step(cur.turf,f)
					if(T != exclude)
						var/datum/path_node/CN = openc[T]  //current checking turf
						var/r= REVERSE_DIR(f)
						var/newg = cur.g + DIST(cur.turf, T)

						if(CN)
						//is already in open list, check if it's a better way from the current turf
							CN.expansion_dir &= 15^r //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
							if((newg < CN.cost) )
								if(call(cur.turf,adjacent)(caller, T, id, simulated_only))
									CN.set_previous(cur, newg, CN.heuristic, cur.depth+1)
									open.ReSort(CN)//reorder the changed element in the list
						else
						//is not already in open list, so add it
							if(call(cur.turf,adjacent)(caller, T, id, simulated_only))
								CN = new(T, cur, newg, DIST(T, end), cur.depth+1, 15^r)
								open.Insert(CN)
								openc[T] = CN
		cur.expansion_dir = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	openc = null
	//cleaning after us
	return path

/turf/proc/reachableTurftest(caller, turf/T, ID, simulated_only)
	if(T && !T.density && !(simulated_only && SSpathfinder.space_type_cache[T.type]) && !LinkBlockedWithAccess(T,caller, ID))
		return TRUE

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

#undef CARDINAL_METRIC
#undef DIAGONAL_METRIC
#undef EUCLIDEAN_METRIC
#undef DIST

// TURF PROCS - Should these be inlined later? Would be a loss of customization.. but uh, proccall overhead hurts!
/**
  * Returns whether or not a pathfinding operation with a specified caller can cross to another turf.
  */
/turf/proc/pathfinding_can_cross(caller, turf/other, obj/item/card/id/ID, dir_to_other = get_dir(src, other))
	if(dir_to_other & (dir_to_other - 1))		// diagonal check
		#warn cardinal movement checks like how real diagonal movement works
		return thing
	// check density first. good litmus test.
	if(other.density)
		return FALSE
	var/reverse_dir = REVERSE_DIR(dir_to_other)
	// we should probably do all on edge objects but honestly can't be arsed right now
	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, dir_to_other))
			return FALSE
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, dir_to_other))
			return FALSE
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, reverse_dir, caller))
			return FALSE
	return TRUE
