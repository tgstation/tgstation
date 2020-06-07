// This file contains the pathfinding subsystem and all base procs related to pathfinding.

SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
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

/datum/controller/subsystem/pathfinder/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	return ..()

/**
  * Warns and logs when a pathfinding operation times out. Since we don't want to add more overhead, we can't terminate it early, but we can record it.
  */
/datum/controller/subsystem/pathfinder/proc/warn_overtime(message)
	message_admins("Pathfinding Timeout: [message]")
	CRASH(message)

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
#define SETUP_NODE(list, previous, cost, heuristic, depth, dir, turf) \
	__INJECTING_NODE = NODE(previous, cost, heuristic, depth, dir, turf); \
	node_by_turf[turf] = __INJECTING_NODE; \
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
		list[++list.len] = nodelist; \
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
		list.Insert((nodelist[NODE_WEIGHT] > list[__INJECTION_MID][NODE_WEIGHT])? __INJECTION_MID : __INJECTION_MID + 1, nodelist) \
	};

/// Sets up a node list with these values
#define NODE(previous, cost, heuristic, depth, dir, turf) list(previous, cost + heuristic * PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT, cost, heuristic, depth, dir, turf)

/// Sets current_distance.
#define CALCULATE_DISTANCE(A, B) \
	switch(heuristic_type) { \
		if(PATHFINDING_HEURISTIC_MANHATTAN) { \
			current_distance = MANHATTAN(A, B); \
		} \
		if(PATHFINDING_HEURISTIC_BYOND) { \
			current_distance = BYOND(A, B); \
		} \
		if(PATHFINDING_HEURISTIC_EUCLIDEAN) { \
			current_distance = EUCLIDEAN(A, B); \
		} \
	};

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
  * * can_cross_proc - proc to call on turfs to find if we can pass from it to another turf. /turf/proc/procname, called with arguments(caller, turf/trying_to_reach, obj/item/card/id/ID, dir_to_them, dir_from_them)
  * * heuristic_type - heuristic type of distance/cost calculations see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. INFINITY for infinite.
  * * max_path_distance - maximum length of returned path using given heuristic can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinder/proc/JPS_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_distance = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinder.space_type_cache, queue = PATHFINDING_QUEUE_DEFAULT, obj/item/card/id/ID)
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
	#warn USING BASE ASTAR FOR DEBUGGING
	. = run_AStar_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, turf_blacklist_typecache)
	deltimer(timerid)
	queues[queue] -= timerid

/datum/controller/subsystem/pathfinder/proc/run_JPS_pathfind(caller, start, end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
	PRIVATE_PROC(TRUE)

/**
  * Because a loop is laggy, we're going to use a define.
  * You can't have comments in the middle of a multi line define so we'll explain how this works here.
  * This is called in every direction you WANT to POTENTIALLY check.
  * First, it checks if the node needs to go that dir via bitflags
  * If it does, we continue, grabbing the turf we're trying to expand to.
  * We check if it's a valid/existing turf (incase we hit edge of map)
  * If it is, we try to access node_by_turf to find an existing node to set into `expand` variable which holds the "node" list of the turf we're "expanding" to.
  * We also calculate the distance from current turf ot the expanding turf, set the potential new cost of the expand turf based on that, and find the reverse direction to them.
  *
  * If expand isn't null, that means it's already a node.
  * We seal off the expanded turf's node towards us, as they don't need to check us anymore since we checked towards them already.
  * If the path is better from us to them than their previous node, AND we can reach them, we set their previous node to us and recalculate their cost, weight, and depth accordingly.
  *
  * If expand is null, that means there is no node.
  * In which case, we check if we can reach the node, and if we can, we add the turf with a new node to our open list.
  */
#define RUN_ASTAR(dir) \
	if(current[NODE_DIR] & dir) { \
		expand_turf = get_step(current[NODE_TURF], dir); \
		if(expand_turf && !turf_blacklist_typecache[expand_turf.type]) { \
			expand = node_by_turf[expand_turf]; \
			CALCULATE_DISTANCE(current_turf, expand_turf); \
			new_cost = current[NODE_COST] + current_distance; \
			reverse_dir_of_expand = REVERSE_DIR(dir); \
			if(expand) { \
				expand[NODE_DIR] = expand[NODE_DIR] & ((NORTH|SOUTH|EAST|WEST) ^ reverse_dir_of_expand); \
				if(new_cost < expand[NODE_COST]) { \
					if(call(current_turf, can_cross_proc)(caller, expand_turf, ID, dir, reverse_dir_of_expand)) { \
						expand[NODE_PREVIOUS] = current; \
						expand[NODE_COST] = new_cost; \
						expand[NODE_WEIGHT] = new_cost + expand[NODE_HEURISTIC] * PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT; \
						expand[NODE_DEPTH] = current[NODE_DEPTH] + 1; \
						open -= expand; \
						INJECT_NODE(open, expand); \
					}; \
				}; \
			}; \
			else { \
				if(call(current_turf, can_cross_proc)(caller, expand_turf, ID, dir, reverse_dir_of_expand)) { \
					CALCULATE_DISTANCE(expand_turf, end); \
					SETUP_NODE(open, expand_turf, new_cost, current_distance, current[NODE_DEPTH] + 1, (NORTH|SOUTH|EAST|WEST)^reverse_dir_of_expand, expand_turf); \
				}; \
			}; \
		}; \
	};

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
  * * can_cross_proc - proc to call on turfs to find if we can pass from it to another turf. /turf/proc/procname, called with arguments(caller, turf/trying_to_reach, obj/item/card/id/ID, dir_to_them, dir_from_them)
  * * heuristic_type - heuristic type of distance/cost calculations see [code/__DEFINES/pathfinding.dm]
  * * max_node_depth - maximum depth of nodes to search. INFINITY for infinite.
  * * max_path_distance - maximum length of returned path using given heuristic can be. 0 for infinite.
  * * min_target_distance - minimum distance to target to terminate pathfinding. Used to get close to a target rather than to it.
  * * turf_blacklist_typecache - blacklist typecache of turfs we can't cross no matter what. defaults to space tiles.
  * * queue - queue to put this in/use with this.
  * * ID - obj/item/card/id to provide access. why this uses an id card and not an access list, .. don't ask.
  */
/datum/controller/subsystem/pathfinder/proc/AStar_pathfind(caller, turf/start, turf/end, can_cross_proc = /turf/proc/pathfinding_can_cross, heuristic_type = PATHFINDING_HEURISTIC_BYOND, max_node_depth = 30, max_path_distance = 0, min_target_distance = 0, turf_blacklist_typecache = SSpathfinder.space_type_cache, queue = PATHFINDING_QUEUE_DEFAULT, obj/item/card/id/ID)
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

/datum/controller/subsystem/pathfinder/proc/run_AStar_pathfind(caller, turf/start, turf/end, can_cross_proc, heuristic_type, max_node_depth, max_path_distance, min_target_distance, list/turf_blacklist_typecache, obj/item/card/id/ID)
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
	var/list/open = list()		// astar open node list, see defines
	var/list/node_by_turf = list()		//turf = node assoc list for reverse lookup.
	var/list/path				// assembled turf path
	var/list/current = list()		//current node list
	var/turf/current_turf		// because unironically : operators are slower (not to mention the fact they're banned) than .'s for some reason?
	var/turf/expand_turf		// turf we're trying to expand to
	var/list/expand = list()	// node list of turf we're trying to expand to, if it exists.
	var/new_cost				// new cost of a new turf being expanded to.
	var/reverse_dir_of_expand	// reverse direction of where we're expanding to.
	SETUP_NODE(open, null, 0, current_distance, 0, NORTH|SOUTH|EAST|WEST, start)		// initially we want to explore all cardinals.
	while(length(open))		// while we still have open nodes
		current = open[open.len--]		// pop a node
		current_turf = current[NODE_TURF] // get its turf
		// see how far we are
		CALCULATE_DISTANCE(current_turf, end)
		// if we're at the end or close enough, we're done
		if((current_turf == end) || (current_distance <= min_target_distance))
			// assemble our path
			path = list(current_turf)
			// go up the chain
			while(current[NODE_PREVIOUS])
				current = current[NODE_PREVIOUS]
				path += current[NODE_TURF]
			// get the path in the right direction
			reverseRange(path)
			break		// we're done!
		// if we get to this point, the !fun! begins.
		if(current[NODE_DEPTH] > max_node_depth)		// too deep, skip
			continue
		// Run each direction
		RUN_ASTAR(NORTH)
		RUN_ASTAR(SOUTH)
		RUN_ASTAR(EAST)
		RUN_ASTAR(WEST)
		// Clear directions, we're done with this node.
		current[NODE_DIR] = NONE
		CHECK_TICK

	return path || PATHFIND_FAIL_NO_PATH

#undef RUN_ASTAR

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
/turf/proc/pathfinding_can_cross(caller, turf/other, obj/item/card/id/ID, dir_to_other, reverse_dir)
	if(dir_to_other & (dir_to_other - 1))		// diagonal check
		// let's handle it like how diagonal movement does realistically.
		var/northsouth = dir_to_other & (NORTH|SOUTH)
		var/eastwest = dir_to_other & (EAST|WEST)
		var/turf/one = get_step(src, northsouth)
		var/turf/two = get_step(src, eastwest)
		return (one && pathfinding_can_cross(caller, one, ID, northsouth, REVERSE_DIR(northsouth)) && one.pathfinding_can_cross(caller, other, ID, eastwest, REVERSE_DIR(eastwest))) || (two && pathfinding_can_cross(caller, two, ID, eastwest, REVERSE_DIR(eastwest)) && two.pathfinding_can_cross(caller, other, ID, northsouth, REVERSE_DIR(northsouth)))
	// check density first. good litmus test.
	if(other.density)
		return FALSE
	// we should probably do all on edge objects but honestly can't be arsed right now
	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, dir_to_other))
			return FALSE
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, dir_to_other))
			return FALSE
	for(var/obj/O in other)
		if(!O.CanAStarPass(ID, reverse_dir, caller))
			return FALSE
	return TRUE

#ifdef PATHFINDING_DEBUG
/obj/effect/overlay/pathfinding
	name = "pathfinding debug overlay"
#endif
