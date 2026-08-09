#define NAVMAP_ASTAR_NODE_BEFORE(A, B) (f_score[(A)] < f_score[(B)] || (f_score[(A)] == f_score[(B)] && g_score[(A)] > g_score[(B)]))

/// Native-compatible asynchronous navmap A* fallback.
/datum/pathfind/navmap
	var/atom/movable/requester
	var/turf/end
	var/minimum_distance
	var/skip_first
	var/diagonal_handling
	var/job_id
	var/complete = FALSE
	var/list/path
	var/force_dm = FALSE
	var/use_native = FALSE
	var/allow_tick_yield = TRUE
	var/list/navmap_astar_open
	var/list/navmap_astar_heap_index
	var/list/navmap_astar_g_score
	var/list/navmap_astar_f_score
	var/list/navmap_astar_parent
	var/list/navmap_astar_closed
	var/list/navmap_astar_edge_cache
	var/list/navmap_astar_simulated_cache
	var/navmap_astar_is_flying = FALSE

/datum/pathfind/navmap/proc/setup(atom/movable/requester, atom/goal, max_distance, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	var/datum/can_pass_info/info = new /datum/can_pass_info(requester, access)
	setup_with_pass_info(requester, goal, max_distance, minimum_distance, info, simulated_only, avoid, skip_first, diagonal_handling, on_finish)

/datum/pathfind/navmap/proc/setup_with_pass_info(atom/movable/requester, atom/goal, max_distance, minimum_distance, datum/can_pass_info/pass_info, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(goal)
	src.max_distance = max_distance
	src.minimum_distance = minimum_distance || 0
	src.pass_info = pass_info
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	src.on_finish = on_finish

/datum/pathfind/navmap/start()
	start = start || get_turf(requester)
	. = ..()
	if(!. || !end || start.z != end.z)
		return FALSE

	use_native = !force_dm && navmap_pathfinder_available()
	if(!use_native)
		navmap_astar_initialize()
		return TRUE

	var/list/result
	try
		result = navmap_pathfinder_start(start, end, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/search_step()
	if(QDELETED(requester) || QDELETED(end))
		return FALSE
	if(complete)
		return TRUE
	if(!use_native)
		return navmap_astar_search_step()

	var/list/result
	try
		result = navmap_pathfinder_resume(job_id, pass_info)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/proc/handle_result(list/result)
	if(!islist(result))
		return FALSE
	switch(result["status"])
		if(NAVMAP_PATH_IN_PROGRESS)
			job_id = result["job_id"]
			return !!job_id
		if(NAVMAP_PATH_COMPLETE, NAVMAP_PATH_NO_PATH)
			path = result["path"] || list()
			complete = TRUE
			return TRUE
		if(NAVMAP_PATH_ERROR)
			path = list()
			complete = TRUE
			return TRUE
	return FALSE

/datum/pathfind/navmap/proc/navmap_astar_initialize()
	navmap_astar_open = list()
	navmap_astar_heap_index = list()
	navmap_astar_g_score = list()
	navmap_astar_f_score = list()
	navmap_astar_parent = list()
	navmap_astar_closed = list()
	navmap_astar_edge_cache = list()
	navmap_astar_simulated_cache = list()
	navmap_astar_is_flying = NAV_IS_FLYING(pass_info)
	path = null
	complete = FALSE
	if(start == avoid || (max_distance && get_dist(start, end) > max_distance + minimum_distance))
		path = list()
		complete = TRUE
		return
	if(!navmap_astar_turf_open(start))
		path = list()
		complete = TRUE
		return
	navmap_astar_queue_update(start, null, 0)

/datum/pathfind/navmap/proc/navmap_astar_heuristic(turf/tile)
	var/dx = max(abs(tile.x - end.x) - minimum_distance, 0)
	var/dy = max(abs(tile.y - end.y) - minimum_distance, 0)
	return 14 * min(dx, dy) + 10 * abs(dx - dy)

/datum/pathfind/navmap/proc/navmap_astar_resolve_edges(turf/tile)
	if(isnull(tile))
		return 0
	var/cached = navmap_astar_edge_cache[tile]
	if(!isnull(cached))
		return cached
	if(isnull(tile.nav_pass))
		tile.nav_bake()
	var/nav_pass = tile.nav_pass
	var/open_edges = 0
	if(nav_pass & NAV_BAKED)
		for(var/dir in GLOB.cardinals)
			var/edge_open
			NAV_EDGE_OPEN_BAKED(tile, dir, navmap_astar_is_flying, pass_info, edge_open)
			if(edge_open)
				open_edges |= dir
	navmap_astar_edge_cache[tile] = open_edges
	navmap_astar_simulated_cache[tile] = !!(nav_pass & NAV_SIMULATED)
	return open_edges

/datum/pathfind/navmap/proc/navmap_astar_turf_open(turf/tile)
	if(isnull(tile) || tile == avoid || (max_distance && get_dist(start, tile) > max_distance))
		return FALSE
	navmap_astar_resolve_edges(tile)
	return !simulated_only || navmap_astar_simulated_cache[tile]

/datum/pathfind/navmap/proc/navmap_astar_route_open(turf/source, source_dir, destination_dir)
	if(!(navmap_astar_resolve_edges(source) & source_dir))
		return FALSE
	var/turf/middle = get_step(source, source_dir)
	if(!navmap_astar_turf_open(middle))
		return FALSE
	return !!(navmap_astar_resolve_edges(middle) & destination_dir)

/// Returns bit 1 for north/south-first and bit 2 for east/west-first routes.
/datum/pathfind/navmap/proc/navmap_astar_diagonal_routes(turf/source, turf/destination, dir, stop_after_first = FALSE)
	var/north_south_dir = dir & (NORTH | SOUTH)
	var/east_west_dir = dir & (EAST | WEST)
	var/source_edges = navmap_astar_resolve_edges(source)
	if(!(source_edges & north_south_dir) && !(source_edges & east_west_dir))
		return 0
	if(!navmap_astar_turf_open(destination))
		return 0
	var/routes = 0
	if((source_edges & north_south_dir) && navmap_astar_route_open(source, north_south_dir, east_west_dir))
		routes |= 1
		if(stop_after_first)
			return routes
	if((source_edges & east_west_dir) && navmap_astar_route_open(source, east_west_dir, north_south_dir))
		routes |= 2
	return routes

/datum/pathfind/navmap/proc/navmap_astar_heap_sift_up(index)
	var/list/open = navmap_astar_open
	var/list/heap_index = navmap_astar_heap_index
	var/list/f_score = navmap_astar_f_score
	var/list/g_score = navmap_astar_g_score
	while(index > 1)
		var/parent_index = index >> 1
		if(!NAVMAP_ASTAR_NODE_BEFORE(open[index], open[parent_index]))
			break
		var/turf/current = open[index]
		var/turf/parent = open[parent_index]
		open.Swap(index, parent_index)
		heap_index[current] = parent_index
		heap_index[parent] = index
		index = parent_index

/datum/pathfind/navmap/proc/navmap_astar_heap_sift_down(index)
	var/list/open = navmap_astar_open
	var/list/heap_index = navmap_astar_heap_index
	var/list/f_score = navmap_astar_f_score
	var/list/g_score = navmap_astar_g_score
	var/last_index = open.len
	while(TRUE)
		var/left = index * 2
		if(left > last_index)
			break
		var/best = left
		var/right = left + 1
		if(right <= last_index && NAVMAP_ASTAR_NODE_BEFORE(open[right], open[left]))
			best = right
		if(!NAVMAP_ASTAR_NODE_BEFORE(open[best], open[index]))
			break
		var/turf/current = open[index]
		var/turf/child = open[best]
		open.Swap(index, best)
		heap_index[current] = best
		heap_index[child] = index
		index = best

/datum/pathfind/navmap/proc/navmap_astar_queue_update(turf/tile, turf/parent, new_cost)
	if(navmap_astar_closed[tile])
		return
	var/old_cost = navmap_astar_g_score[tile]
	if(!isnull(old_cost) && new_cost >= old_cost)
		return
	navmap_astar_g_score[tile] = new_cost
	navmap_astar_f_score[tile] = new_cost + navmap_astar_heuristic(tile)
	navmap_astar_parent[tile] = parent
	var/index = navmap_astar_heap_index[tile]
	if(index)
		navmap_astar_heap_sift_up(index)
		return
	navmap_astar_open += tile
	index = navmap_astar_open.len
	navmap_astar_heap_index[tile] = index
	navmap_astar_heap_sift_up(index)

/datum/pathfind/navmap/proc/navmap_astar_heap_pop()
	if(!length(navmap_astar_open))
		return null
	var/list/open = navmap_astar_open
	var/list/heap_index = navmap_astar_heap_index
	var/turf/result = open[1]
	heap_index[result] = null
	open[1] = open[open.len]
	open.len--
	if(length(open))
		heap_index[open[1]] = 1
		navmap_astar_heap_sift_down(1)
	navmap_astar_closed[result] = TRUE
	return result

/datum/pathfind/navmap/proc/navmap_astar_reconstruct(turf/goal_tile)
	var/list/reversed = list(goal_tile)
	var/turf/current = goal_tile
	while(navmap_astar_parent[current])
		current = navmap_astar_parent[current]
		reversed += current
	return reverseList(reversed)

/datum/pathfind/navmap/proc/navmap_astar_build_path(turf/goal_tile)
	var/list/raw_path = navmap_astar_reconstruct(goal_tile)
	var/list/expanded_path = list(raw_path[1])
	for(var/i in 1 to (length(raw_path) - 1))
		var/turf/from = raw_path[i]
		var/turf/next = raw_path[i + 1]
		var/dir = get_dir(from, next)
		if(dir & (dir - 1))
			var/routes = navmap_astar_diagonal_routes(from, next, dir)
			if(!routes)
				return list()
			var/vertical = dir & (NORTH | SOUTH)
			if(diagonal_handling == DIAGONAL_REMOVE_ALL)
				var/insert_dir = (routes & 1) ? vertical : (dir & (EAST | WEST))
				expanded_path += get_step(from, insert_dir)
			else if(diagonal_handling == DIAGONAL_REMOVE_CLUNKY && !(routes & 1) && (routes & 2))
				expanded_path += get_step(from, dir & (EAST | WEST))
		expanded_path += next
	if(skip_first && length(expanded_path))
		expanded_path.Cut(1, 2)
	return expanded_path

/datum/pathfind/navmap/proc/navmap_astar_search_step()
	var/static/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST)
	while(length(navmap_astar_open))
		var/turf/current = navmap_astar_heap_pop()
		if(get_dist(current, end) <= minimum_distance)
			path = navmap_astar_build_path(current)
			complete = TRUE
			return TRUE
		var/source_edges = navmap_astar_resolve_edges(current)
		for(var/dir in directions)
			var/turf/next = get_step(current, dir)
			if(dir & (dir - 1))
				if(navmap_astar_diagonal_routes(current, next, dir, TRUE))
					navmap_astar_queue_update(next, current, navmap_astar_g_score[current] + 14)
			else if((source_edges & dir) && navmap_astar_turf_open(next))
				navmap_astar_queue_update(next, current, navmap_astar_g_score[current] + 10)
		if(allow_tick_yield)
			CHECK_TICK
	path = list()
	complete = TRUE
	return TRUE

/datum/pathfind/navmap/finished()
	if(!length(path))
		EVLOG_TEXT(requester, EVLOG_CATEGORY_NAVMAP, "No navmap path (pass_flags=[pass_info.pass_flags])")
	hand_back(path || list())
	return ..()

/datum/pathfind/navmap/early_exit()
	if(job_id && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	job_id = null
	return ..()

/datum/pathfind/navmap/Destroy(force)
	if(job_id && !complete && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	job_id = null
	navmap_astar_open = null
	navmap_astar_heap_index = null
	navmap_astar_g_score = null
	navmap_astar_f_score = null
	navmap_astar_parent = null
	navmap_astar_closed = null
	navmap_astar_edge_cache = null
	navmap_astar_simulated_cache = null
	SSpathfinder.navmap_pathing -= src
	SSpathfinder.current_navmap_run -= src
	requester = null
	end = null
	return ..()

#undef NAVMAP_ASTAR_NODE_BEFORE

/proc/navmap_pathfinder_blocking(atom/movable/requester, turf/start_turf, turf/end_turf, datum/can_pass_info/pass_info, max_distance, minimum_distance, simulated_only, turf/avoid, diagonal_handling, skip_first, use_dm_implementation = FALSE, allow_tick_yield = TRUE)
	if(!use_dm_implementation && navmap_pathfinder_available())
		try
			return navmap_pathfinder(start_turf, end_turf, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
		catch
			return list()

	var/datum/pathfind/navmap/search = new()
	search.force_dm = TRUE
	search.start = start_turf
	search.allow_tick_yield = allow_tick_yield
	search.setup_with_pass_info(requester, end_turf, max_distance, minimum_distance, pass_info, simulated_only, avoid, skip_first, diagonal_handling)
	if(!search.start())
		qdel(search)
		return list()
	while(!search.complete)
		if(!search.search_step())
			search.early_exit()
			return list()
		if(allow_tick_yield)
			CHECK_TICK
	var/list/result = search.path ? search.path.Copy() : list()
	qdel(search)
	return result
