/*
 * Standalone A* over the cached turf navmesh. Deliberately NOT integrated with SSpathfinder / JPS;
 * it never calls LinkBlockedWithAccess at query time, only /turf/proc/nav_edge_open (cached bits +
 * live conditional evaluation). Synchronous and single-z, matching JPS's single-z restriction.
 *
 * This is the "test mover" for validating the navmesh. It is not (yet) a drop-in replacement for
 * get_path_to.
 */

/*
 * Open-list node. One per visited turf; g/f updated in place when a cheaper route is found.
 *
 * No Destroy() override and callers do NOT qdel these: they hold no signals/timers/components, are
 * only ever referenced by the search's own `nodes` list and each other's `came_from` chain, and are
 * scoped to a single nav_find_path() call. Dropping the local var refs at proc exit is enough for the
 * GC to reclaim them; routing every node through full qdel teardown showed up as measurable overhead
 * (qdel is a proc call plus bookkeeping per object) on searches touching hundreds of nodes.
 */
/datum/nav_node
	var/turf/tile
	var/datum/nav_node/came_from
	/// Cost from start to here (cardinal step = 10, diagonal = 14, integer octile weighting).
	var/g_value
	/// g_value + heuristic.
	var/f_value
	/// TRUE once popped and expanded. The heap has no decrease-key, so an improved node is
	/// re-inserted as a second heap entry; this flag makes the (cheap) stale duplicate a no-op
	/// on pop instead of re-expanding an already-finalized turf's neighbours.
	var/closed = FALSE

/datum/nav_node/New(turf/tile, datum/nav_node/came_from, g_value, f_value)
	src.tile = tile
	src.came_from = came_from
	src.g_value = g_value
	src.f_value = f_value

/// Heap comparator: smaller f_value = higher priority (the heap is a max-heap, so invert).
/proc/nav_node_compare(datum/nav_node/a, datum/nav_node/b)
	return b.f_value - a.f_value

/**
 * Find a path from `start` to `goal` for a mover described by `pass_info`, reading only cached
 * navmesh data. Returns an ordered list of turfs (start-exclusive, goal-inclusive), or an empty list
 * if no path is found. Diagonals are allowed when a corner can actually be rounded.
 *
 * Arguments:
 * * start / goal - turfs. Must share a z-level.
 * * pass_info - /datum/can_pass_info describing the mover (build with `new(mover, access)`).
 * * max_distance - abort if the search exceeds this many tiles of Chebyshev distance from start.
 * * mintargetdist - accept any turf within this Chebyshev distance of goal as the destination.
 */
/proc/nav_find_path(turf/start, turf/goal, datum/can_pass_info/pass_info, max_distance = 30, mintargetdist = 0)
	if(!start || !goal || !pass_info)
		return list()
	if(start.z != goal.z || start == goal)
		return list()
	if(max_distance && get_dist(start, goal) > max_distance)
		return list()

	// Movement class is fixed for the whole search; resolve the bit selector once.
	var/is_flying = NAV_IS_FLYING(pass_info)

	var/datum/heap/open = new /datum/heap(GLOBAL_PROC_REF(nav_node_compare))
	// turf -> /datum/nav_node. Doubles as the visited set and the g-value store.
	var/list/nodes = list()

	var/datum/nav_node/start_node = new /datum/nav_node(start, null, 0, NAV_HEURISTIC(start, goal))
	open.insert(start_node)
	nodes[start] = start_node

	var/datum/nav_node/best = null

	while(!open.is_empty())
		var/datum/nav_node/current = open.pop()
		if(current.closed)
			continue // stale duplicate from an earlier improvement; this turf is already finalized
		current.closed = TRUE
		var/turf/current_tile = current.tile

		if(get_dist(current_tile, goal) <= mintargetdist)
			best = current
			break

		NAV_ENSURE_BAKED(current_tile) // bake once; the per-dir checks below read bits with no proc call

		for(var/dir in GLOB.alldirs)
			var/turf/neighbor = get_step(current_tile, dir)
			if(isnull(neighbor))
				continue
			if(max_distance && get_dist(start, neighbor) > max_distance)
				continue

			var/step_cost
			if(dir & (dir - 1)) // more than one bit set -> diagonal
				var/diag_ok
				NAV_DIAGONAL_OPEN(current_tile, dir, is_flying, pass_info, diag_ok)
				if(!diag_ok)
					continue
				step_cost = 14
			else
				if(!NAV_EDGE_OPEN_BAKED(current_tile, dir, is_flying, pass_info))
					continue
				step_cost = 10

			var/tentative_g = current.g_value + step_cost
			var/datum/nav_node/existing = nodes[neighbor]
			if(existing)
				if(existing.closed || tentative_g >= existing.g_value)
					continue // finalized, or not an improvement
				existing.g_value = tentative_g
				existing.f_value = tentative_g + NAV_HEURISTIC(neighbor, goal)
				existing.came_from = current
				open.insert(existing) // re-insert; stale copy is filtered by the g-check when popped
			else
				var/datum/nav_node/new_node = new /datum/nav_node(neighbor, current, tentative_g, tentative_g + NAV_HEURISTIC(neighbor, goal))
				nodes[neighbor] = new_node
				open.insert(new_node)

	var/list/path = list()
	if(best)
		var/datum/nav_node/trace = best
		while(trace && trace.tile != start)
			path.Insert(1, trace.tile)
			trace = trace.came_from

	// No qdel: nav_node holds no signals/timers, and both `nodes` and `open` are locals about to go
	// out of scope, so the GC reclaims everything once this proc returns. See /datum/nav_node header.
	return path

/**
 * Convenience wrapper mirroring get_path_to's shape for easy A/B benchmarking against JPS.
 * Builds the can_pass_info from the caller like the JPS path does.
 */
/proc/get_nav_path_to(atom/movable/caller_movable, atom/target, max_distance = 30, mintargetdist = 0, list/access = list())
	if(!caller_movable || !target)
		return list()
	var/datum/can_pass_info/pass_info = new /datum/can_pass_info(caller_movable, access)
	return nav_find_path(get_turf(caller_movable), get_turf(target), pass_info, max_distance, mintargetdist)
