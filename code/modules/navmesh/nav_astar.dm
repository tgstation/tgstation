/*
 * Standalone A* over the cached turf navmesh. Deliberately NOT integrated with SSpathfinder / JPS;
 * it never calls LinkBlockedWithAccess at query time, only /turf/proc/nav_edge_open (cached bits +
 * live conditional evaluation). Synchronous and single-z, matching JPS's single-z restriction.
 *
 * This is the "test mover" for validating the navmesh. It is not (yet) a drop-in replacement for
 * get_path_to.
 */

/// Open-list node. One per visited turf; g/f updated in place when a cheaper route is found.
/datum/nav_node
	var/turf/tile
	var/datum/nav_node/came_from
	/// Cost from start to here (cardinal step = 10, diagonal = 14, integer octile weighting).
	var/g_value
	/// g_value + heuristic.
	var/f_value

/datum/nav_node/New(turf/tile, datum/nav_node/came_from, g_value, f_value)
	src.tile = tile
	src.came_from = came_from
	src.g_value = g_value
	src.f_value = f_value

/datum/nav_node/Destroy(force)
	tile = null
	came_from = null
	return ..()

/// Heap comparator: smaller f_value = higher priority (the heap is a max-heap, so invert).
/proc/nav_node_compare(datum/nav_node/a, datum/nav_node/b)
	return b.f_value - a.f_value

/// Integer octile heuristic scaled to match step costs (cardinal 10, diagonal 14).
/proc/nav_heuristic(turf/a, turf/b)
	var/dx = abs(a.x - b.x)
	var/dy = abs(a.y - b.y)
	return 10 * (dx + dy) - 6 * min(dx, dy)

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

	var/datum/heap/open = new(GLOBAL_PROC_REF(nav_node_compare))
	// turf -> /datum/nav_node. Doubles as the visited set and the g-value store.
	var/list/nodes = list()

	var/datum/nav_node/start_node = new(start, null, 0, nav_heuristic(start, goal))
	open.insert(start_node)
	nodes[start] = start_node

	var/datum/nav_node/best = null

	while(!open.is_empty())
		var/datum/nav_node/current = open.pop()

		if(get_dist(current.tile, goal) <= mintargetdist)
			best = current
			break

		for(var/dir in GLOB.alldirs)
			var/turf/neighbor = get_step(current.tile, dir)
			if(isnull(neighbor))
				continue
			if(max_distance && get_dist(start, neighbor) > max_distance)
				continue

			var/step_cost
			if(dir & (dir - 1)) // more than one bit set -> diagonal
				if(!nav_diagonal_open(current.tile, dir, pass_info))
					continue
				step_cost = 14
			else
				if(!current.tile.nav_edge_open(dir, pass_info))
					continue
				step_cost = 10

			var/tentative_g = current.g_value + step_cost
			var/datum/nav_node/existing = nodes[neighbor]
			if(existing)
				if(tentative_g >= existing.g_value)
					continue
				existing.g_value = tentative_g
				existing.f_value = tentative_g + nav_heuristic(neighbor, goal)
				existing.came_from = current
				open.insert(existing) // re-insert; stale copy is filtered by the g-check when popped
			else
				var/datum/nav_node/new_node = new(neighbor, current, tentative_g, tentative_g + nav_heuristic(neighbor, goal))
				nodes[neighbor] = new_node
				open.insert(new_node)

	var/list/path = list()
	if(best)
		var/datum/nav_node/trace = best
		while(trace && trace.tile != start)
			path.Insert(1, trace.tile)
			trace = trace.came_from

	QDEL_LIST_ASSOC_VAL(nodes)
	qdel(open)
	return path

/**
 * A diagonal step from `origin` in composite dir `dir` is allowed iff at least one of the two
 * L-shaped routes around the corner is fully open (both cardinal hops traversable). Mirrors the
 * corner rule in LinkBlockedWithAccess (code/__HELPERS/paths/path.dm) and mob diagonal movement, so
 * generated paths are actually walkable.
 */
/proc/nav_diagonal_open(turf/origin, dir, datum/can_pass_info/pass_info)
	var/turf/dest = get_step(origin, dir)
	if(isnull(dest))
		return FALSE
	var/dir_ns = dir & (NORTH | SOUTH)
	var/dir_ew = dir & (EAST | WEST)
	// Route A: cardinal NS first, then EW. Route B: EW first, then NS.
	for(var/first_dir in list(dir_ns, dir_ew))
		var/second_dir = (first_dir == dir_ns) ? dir_ew : dir_ns
		var/turf/midstep = get_step(origin, first_dir)
		if(isnull(midstep))
			continue
		if(origin.nav_edge_open(first_dir, pass_info) && midstep.nav_edge_open(second_dir, pass_info))
			return TRUE
	return FALSE

/**
 * Convenience wrapper mirroring get_path_to's shape for easy A/B benchmarking against JPS.
 * Builds the can_pass_info from the caller like the JPS path does.
 */
/proc/get_nav_path_to(atom/movable/caller_movable, atom/target, max_distance = 30, mintargetdist = 0, list/access = list())
	if(!caller_movable || !target)
		return list()
	var/datum/can_pass_info/pass_info = new(caller_movable, access)
	return nav_find_path(get_turf(caller_movable), get_turf(target), pass_info, max_distance, mintargetdist)
