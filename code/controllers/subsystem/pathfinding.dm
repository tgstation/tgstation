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

#define MANHATTAN(A, B)		(abs(A.x - B.x) + abs(A.y - B.y))
#define BYOND(A, B)		get_dist(A, B)
#define EUCLIDEAN(A, B)		(sqrt((A.x - B.x)**2 + (A.y - B.y)**2))

// Let's sing the listmos song!

/// Total size of node "list", which is indexed by turf.
#define NODE_LIST_LENGTH 7
/// Since we're using turfs, this is just the previous turf.
#define NODE_PREVIOUS 1
/// AStar node weight, lower is better, the list will be sorted by this
#define NODE_WEIGHT 2
/// Node cost from root
#define NODE_COST 3
/// Node heuristic cost to target
#define NODE_HEURISTIC 4
/// Node depth from root
#define NODE_DEPTH 5
/// Direction to expand in
#define NODE_DIR 6
/// Node's actual turf because I forgot to do associative list and I'm not sure assoc would even perform better
#define NODE_TURF 7

// forgive me, for this (and everything below it) is a sin.
#define SETUP_NODE(list, previous, cost, heuristic, depth, dir) \
	__INJECTING_NODE = NODE(previous, cost, heuristic, depth, dir) \
	INJECT_NODE(list, __INJECTING_NODE)

/// Sets up variables needed for binary insert to avoid variable def overhead
#define INJECTION_SETUP \
	var/__INJECTION_LISTLEN; \
	var/__INJECTION_LEFT; \
	var/__INJECTION_RIGHT; \
	var/__INJECTION_MID; \
	var/list/__INJECTING_NODE;

/// Binary inserts a node into the node list. Snowflake implementation to avoid overhead, as this will never handle datums. Lowest weighted nodes go towards the end of the list as list.len-- is faster when popping.
#define INJECT_NODE(list, nodelist) \
	__INJECTION_LISTLEN = length(list); \
	if(!__INJECTION_LISTLEN) { \
		list[++__INJECTION_LISTLEN] = nodelist; \
	}; \
	else { \
		__INJECTION_LEFT = 1; \
		__INJECTION_RIGHT = __INJECTION_LISTLEN; \
		__INJECTION_MID = (__INJECTION_LEFT + __INJECTION_RIGHT) >> 1;\
		while(__INJECTION_LEFT < __INJECTION_RIGHT) {\
			if(nodelist[NODE_WEIGHT] >= list[__INJECTION_MID][NODE_WEIGHT]) { \
				__INJECTION_LEFT = __INJECTION_MID + 1; \
			}; \
			else{ \
				__INJECTION_RIGHT = __INJECTION_MID; \
			}; \
			__INJECTION_MID = (__INJECTION_LEFT + __INJECTION_RIGHT) >> 1;\
		}; \
		list.Insert((nodelist[NODE_WEIGHT] > list[__INJECTION_MID][NODE_WEIGHT])? __INJECTION_MID : INJECTION_MID + 1, nodelist) \
	};

/// Sets up a node list with these values
#define NODE(previous, cost, heuristic, depth, dir, turf) list(previous, cost + heuristic * PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT, cost, heuristic, depth, dir, turf)

/// Sets current_distance.
#define CALCULATE_DISTANCE(A, B) \
	switch(heuristic_type) { \
		if(PATHFINDING_HEURISTIC_MANHATTAN) { \
			current_distance = MANHATTAN(A, B); \
		}; \
		if(PATHFINDING_HEURISTIC_BYOND) { \
			current_distance = BYOND(A, B); \
		}; \
		if(PATHFINDING_HEURISTIC_EUCLIDEAN) { \
			current_distance = EUCLIDEAN(A, B); \
		}; \
	};


/**
  * Warns and logs when a pathfinding operation times out. Since we don't want to add more overhead, we can't terminate it early, but we can record it.
  */
/datum/controller/subsystem/pathfinding/proc/warn_overtime(message)
	message_admins("Pathfinding Timeout: [message]")
	CRASH(message)

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
  * * heuristic_type - heuristic type of distance/cost calculations see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. INFINITY for infinite.
  * * max_path_distance - maximum length of returned path using given heuristic can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinding/proc/JPS_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_distance = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinding.space_type_cache, queue = PATHFINDER_QUEUE_DEFAULT, obj/item/card/id/ID)
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
	. = run_JPS_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, turf_blacklist_typecache)
	deltimer(timerid)
	queues[queue] -= timerid

/datum/controller/subsystem/pathfinding/proc/run_JPS_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
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
  * * heuristic_type - heuristic type of distance/cost calculations see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. INFINITY for infinite.
  * * max_path_distance - maximum length of returned path using given heuristic can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinding/proc/AStar_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_distance = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinding.space_type_cache, queue = PATHFINDER_QUEUE_DEFAULT, obj/item/card/id/ID)
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
	. = run_AStar_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, turf_blacklist_typecache)
	deltimer(timerid)
	queues[queue] -= timerid

/datum/controller/subsystem/pathfinding/proc/run_AStar_pathfind(caller, turf/start, turf/end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
	PRIVATE_PROC(TRUE)
	// We're going to assume everything is valid type-wise as we're only ran by a wrapper.
	// If anything ISN'T valid, we're going to crash and burn, because why are you not using the wrapper and/or passing in invalid arguments?
	// simple checks first
	if(start.z != end.z)
		return PATHFIND_FAIL_MULTIZ
	// fun fact, variable declarations are costly, so let's just do it all here.
	// we want to optimize for cpu so expect some messy code, these vars may or may not be used depending on where, they'll only be set and used if they're being used more than once to avoid more calculations.
	var/current_distance		// current distance in whatever context it's used.
	// if we have max path distance, make sure we're not too far
	if(max_path_distance || min_target_distance)
		switch(heuristic_type)
			if(PATHFINDING_HEURISTIC_MANHATTAN)
				current_distance = MANHATTAN(start, end)
				if(current_distance > max_path_distance)
					return PATHFIND_FAIL_TOO_FAR
				if(current_distance < min_target_distance)
					return PATHFIND_FAIL_TOO_CLOSE
			if(PATHFINDING_HEURISTIC_BYOND)
				current_distance = BYOND(start, end)
				if(current_distance > max_path_distance)
					return PATHFIND_FAIL_TOO_FAR
				if(current_distance < min_target_distance)
					return PATHFIND_FAIL_TOO_CLOSE
			if(PATHFINDING_HEURISTIC_EUCLIDEAN)
				current_distance = EUCLIDEAN(start, end)
				if(current_distance > max_path_distance)
					return PATHFIND_FAIL_TOO_FAR
				if(current_distance < min_target_distance)
					return PATHFIND_FAIL_TOO_CLOSE
	// basic stuff is done.
	// this used to use a datum/Heap but let's Not(tm) because proccall overhead is a Thing(tm) in byond and that's Bad(tm) for us.
	// instead we're going to play the list game
	INJECTION_SETUP // See defines
	var/list/open = list()		// astar open node list, see defines - turf = node list.
	var/list/path = list()		// assembled turf path
	var/list/current = list()		//current node list
	var/turf/current_turf		// because unironically : operators are slower (not to mention the fact they're banned) than .'s for some reason?
	SETUP_NODE(open, null, 0, current_distance, 0, NORTH|SOUTH|EAST|WEST, start)		// initially we want to explore all cardinals.
	while(length(open))		// while we still have open nodes
		current = open[open.len--]		// pop a node
		current_turf = current[NODE_TURF] // get its turf
		// see how far we are
		CALCULATE_DISTANCE(current_turf, end)
		// if we're at the end or close enough, we're done
		if((current_turf == end) || (current_distance <= min_target_distance))
			// assemble our path
			path += current_turf
			// go up the chain
			while(current[NODE_PREVIOUS])
				current = current[NODE_PREVIOUS]
				path += current[NODE_TURF]
			break		// we're done!
		// if we get to this point, the !fun! begins.
		if(current[NODE_DEPTH] > max_node_depth)		// too deep, skip
			continue

	reverseRange(path)
	return path

/proc/AStar(caller, _end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = TRUE)
		//get adjacents turfs using the adjacent proc, checking for access with id
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

#undef MANHATTAN
#undef BYOND
#undef EUCLIDEAN

#undef NODE_LIST_LENGTH
#undef NODE_PREVIOUS
#undef NODE_WEIGHT
#undef NODE_COST
#undef NODE_HEURISTIC
#undef NODE_DEPTH
#undef NODE_DIR
#undef SETUP_NODE
#undef INJECTION_SETUP
#undef INJECT_NODE
#undef NODE
#undef CALCULATE_DISTANCE

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
