#define NAVMAP_ASTAR_NODE_BEFORE(A, B) (f_score[(A)] < f_score[(B)] || (f_score[(A)] == f_score[(B)] && g_score[(A)] > g_score[(B)]))

/// Native-compatible asynchronous navmap A* fallback.
/datum/pathfind/navmap
	/// The mover requesting the path.
	var/atom/movable/requester
	/// The target turf for the path.
	var/turf/end
	/// The minimum distance from the target.
	var/minimum_distance
	/// Whether to omit the first path tile.
	var/skip_first
	/// How diagonal steps should be handled.
	var/diagonal_handling
	/// Whether paths may cross z-levels.
	var/allow_multiz = FALSE
	/// The maximum total path cost.
	var/max_path_cost = 0
	/// Actions associated with each path tile. (used for navlinks)
	var/list/action_path
	/// The active native pathfinding job.
	var/job_id
	/// Whether pathfinding has finished.
	var/complete = FALSE
	/// The resulting turf path.
	var/list/path
	/// Whether to force the DM implementation.
	var/force_dm = FALSE
	/// Whether the native implementation is active.
	var/use_native = FALSE
	/// Whether search steps may yield to the tick.
	var/allow_tick_yield = TRUE
	/// Open nodes in the DM A* heap.
	var/list/navmap_astar_open
	/// Heap positions for open nodes.
	var/list/navmap_astar_heap_index
	/// Current movement costs for nodes.
	var/list/navmap_astar_g_score
	/// Estimated total costs for nodes.
	var/list/navmap_astar_f_score
	/// Parent node for each visited turf.
	var/list/navmap_astar_parent
	/// Action associated with each visited turf.
	var/list/navmap_astar_action
	/// Nodes already processed by A*.
	var/list/navmap_astar_closed
	/// Cached cardinal edge results.
	var/list/navmap_astar_edge_cache
	/// Cached simulated-turf results.
	var/list/navmap_astar_simulated_cache
	/// Whether the mover uses flying navigation.
	var/navmap_astar_is_flying = FALSE

/// Configures a navmap search from a requester and access list.
/datum/pathfind/navmap/proc/setup(atom/movable/requester, atom/goal, max_distance, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish, allow_multiz = FALSE, max_path_cost = 0)
	// Build pass information for this requester.
	var/datum/can_pass_info/info = new /datum/can_pass_info(requester, access)
	setup_with_pass_info(requester, goal, max_distance, minimum_distance, info, simulated_only, avoid, skip_first, diagonal_handling, on_finish, allow_multiz, max_path_cost)

/// Configures a navmap search with prepared pass information.
/datum/pathfind/navmap/proc/setup_with_pass_info(atom/movable/requester, atom/goal, max_distance, minimum_distance, datum/can_pass_info/pass_info, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish, allow_multiz = FALSE, max_path_cost = 0)
	src.requester = requester
	src.end = get_turf(goal)
	src.max_distance = max_distance
	src.minimum_distance = minimum_distance || 0
	src.pass_info = pass_info
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	src.allow_multiz = allow_multiz
	src.max_path_cost = max_path_cost
	src.on_finish = on_finish

/// Starts native or DM navmap pathfinding.
/datum/pathfind/navmap/start()
	start = start || get_turf(requester)
	. = ..()
	if(!. || !end || (!allow_multiz && start.z != end.z))
		return FALSE

	if(allow_multiz && !force_dm)
		SSnavmap.sync_native_state()
	use_native = !force_dm && navmap_pathfinder_available()
	if(!use_native)
		navmap_astar_initialize()
		return TRUE

	// Result returned by the native search.
	var/list/result
	try
		result = navmap_pathfinder_start(start, end, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first, allow_multiz, max_path_cost)
	catch
		return FALSE
	return handle_result(result)

/// Advances the active pathfinding search.
/datum/pathfind/navmap/search_step()
	if(QDELETED(requester) || QDELETED(end))
		return FALSE
	if(complete)
		return TRUE
	if(!use_native)
		return navmap_astar_search_step()

	// Result returned by the native search.
	var/list/result
	try
		result = navmap_pathfinder_resume(job_id, pass_info)
	catch
		return FALSE
	return handle_result(result)

/// Applies a native pathfinding result to this search.
/datum/pathfind/navmap/proc/handle_result(list/result)
	if(!islist(result))
		return FALSE
	switch(result["status"])
		if(NAVMAP_PATH_IN_PROGRESS)
			job_id = result["job_id"]
			return !!job_id
		if(NAVMAP_PATH_COMPLETE, NAVMAP_PATH_NO_PATH)
			path = result["path"] || list()
			action_path = result["actions"] || list()
			complete = TRUE
			return TRUE
		if(NAVMAP_PATH_STALE_TOPOLOGY)
			path = list()
			complete = TRUE
			return TRUE
		if(NAVMAP_PATH_ERROR)
			path = list()
			complete = TRUE
			return TRUE
	return FALSE

/// Initializes the DM A* search state.
/datum/pathfind/navmap/proc/navmap_astar_initialize()
	navmap_astar_open = list()
	navmap_astar_heap_index = list()
	navmap_astar_g_score = list()
	navmap_astar_f_score = list()
	navmap_astar_parent = list()
	navmap_astar_action = list()
	navmap_astar_closed = list()
	navmap_astar_edge_cache = list()
	navmap_astar_simulated_cache = list()
	navmap_astar_is_flying = NAV_IS_FLYING(pass_info)
	path = null
	complete = FALSE
	if(start == avoid || (max_distance && max(abs(start.x - end.x), abs(start.y - end.y)) > max_distance + minimum_distance))
		path = list()
		complete = TRUE
		return
	if(!navmap_astar_turf_open(start))
		path = list()
		complete = TRUE
		return
	navmap_astar_queue_update(start, null, 0)

/// Estimates the remaining cost to the target.
/datum/pathfind/navmap/proc/navmap_astar_heuristic(turf/tile)
	if(allow_multiz)
		return 0
	// Horizontal distance remaining to the goal.
	var/dx = max(abs(tile.x - end.x) - minimum_distance, 0)
	// Vertical distance remaining to the goal.
	var/dy = max(abs(tile.y - end.y) - minimum_distance, 0)
	return 14 * min(dx, dy) + 10 * abs(dx - dy)

/// Resolves and caches horizontal edges from a turf.
/datum/pathfind/navmap/proc/navmap_astar_resolve_edges(turf/tile)
	if(isnull(tile))
		return 0
	// Reuse previously resolved edges when available.
	var/cached = navmap_astar_edge_cache[tile]
	if(!isnull(cached))
		return cached
	if(isnull(tile.nav_pass))
		tile.nav_bake()
	// Packed navigation data for this turf.
	var/nav_pass = tile.nav_pass
	// Cardinal edges that are open to this mover.
	var/open_edges = 0
	if(nav_pass & NAV_BAKED)
		// Test each cardinal edge against the mover.
		for(var/dir in GLOB.cardinals)
			// Whether the current edge is traversable.
			var/edge_open
			NAV_EDGE_OPEN_BAKED(tile, dir, navmap_astar_is_flying, pass_info, edge_open)
			if(edge_open)
				open_edges |= dir
	navmap_astar_edge_cache[tile] = open_edges
	navmap_astar_simulated_cache[tile] = !!(nav_pass & NAV_SIMULATED)
	return open_edges

/// Checks whether a turf can be searched.
/datum/pathfind/navmap/proc/navmap_astar_turf_open(turf/tile)
	if(isnull(tile) || tile == avoid || (max_distance && max(abs(start.x - tile.x), abs(start.y - tile.y)) > max_distance))
		return FALSE
	navmap_astar_resolve_edges(tile)
	return !simulated_only || navmap_astar_simulated_cache[tile]

/// Checks whether a vertical edge can be traversed.
/datum/pathfind/navmap/proc/navmap_astar_vertical_open(turf/source, turf/destination, direction)
	if(!allow_multiz || !navmap_astar_is_flying || !source || !destination || !navmap_astar_turf_open(destination))
		return FALSE
	if(!(navmap_astar_resolve_vertical_edges(source) & direction))
		return FALSE
	return TRUE

/// Resolves and caches vertical edges from a turf.
/datum/pathfind/navmap/proc/navmap_astar_resolve_vertical_edges(turf/tile)
	if(isnull(tile))
		return 0
	// Separate cache key for vertical edges.
	var/cache_key = "vertical_[tile]"
	// Reuse previously resolved vertical edges.
	var/cached = navmap_astar_edge_cache[cache_key]
	if(!isnull(cached))
		return cached
	if(isnull(tile.nav_pass))
		tile.nav_bake()
	// Vertical edges that are available from this turf.
	var/edges = 0
	if(tile.nav_pass & NAV_BAKED)
		// Check both possible z-level directions.
		for(var/dir in list(UP, DOWN))
			if(tile.nav_pass & NAV_FLIGHT(dir))
				edges |= dir
	navmap_astar_edge_cache[cache_key] = edges
	return edges

/// Checks whether a two-cardinal route is open.
/datum/pathfind/navmap/proc/navmap_astar_route_open(turf/source, source_dir, destination_dir)
	if(!(navmap_astar_resolve_edges(source) & source_dir))
		return FALSE
	// Turf reached by the first cardinal step.
	var/turf/middle = get_step(source, source_dir)
	if(!navmap_astar_turf_open(middle))
		return FALSE
	return !!(navmap_astar_resolve_edges(middle) & destination_dir)

/// Returns bit 1 for north/south-first and bit 2 for east/west-first routes.
/datum/pathfind/navmap/proc/navmap_astar_diagonal_routes(turf/source, turf/destination, dir, stop_after_first = FALSE)
	// Cardinal components of the diagonal direction.
	var/north_south_dir = dir & (NORTH | SOUTH)
	// East/west component of the diagonal direction.
	var/east_west_dir = dir & (EAST | WEST)
	// Open edges from the source turf.
	var/source_edges = navmap_astar_resolve_edges(source)
	if(!(source_edges & north_south_dir) && !(source_edges & east_west_dir))
		return 0
	if(!navmap_astar_turf_open(destination))
		return 0
	// Bitmask of valid cardinal routes.
	var/routes = 0
	if((source_edges & north_south_dir) && navmap_astar_route_open(source, north_south_dir, east_west_dir))
		routes |= 1
		if(stop_after_first)
			return routes
	if((source_edges & east_west_dir) && navmap_astar_route_open(source, east_west_dir, north_south_dir))
		routes |= 2
	return routes

/// Moves a node upward in the A* heap.
/datum/pathfind/navmap/proc/navmap_astar_heap_sift_up(index)
	// Local references to heap and score state.
	var/list/open = navmap_astar_open
	// Heap positions for the referenced nodes.
	var/list/heap_index = navmap_astar_heap_index
	// Estimated costs for the referenced nodes.
	var/list/f_score = navmap_astar_f_score
	// Travel costs for the referenced nodes.
	var/list/g_score = navmap_astar_g_score
	while(index > 1)
		// Parent position in the binary heap.
		var/parent_index = index >> 1
		if(!NAVMAP_ASTAR_NODE_BEFORE(open[index], open[parent_index]))
			break
		// Nodes being exchanged in the heap.
		var/turf/current = open[index]
		// Parent node being exchanged in the heap.
		var/turf/parent = open[parent_index]
		open.Swap(index, parent_index)
		heap_index[current] = parent_index
		heap_index[parent] = index
		index = parent_index

/// Moves a node downward in the A* heap.
/datum/pathfind/navmap/proc/navmap_astar_heap_sift_down(index)
	// Local references to heap and score state.
	var/list/open = navmap_astar_open
	// Heap positions for the referenced nodes.
	var/list/heap_index = navmap_astar_heap_index
	// Estimated costs for the referenced nodes.
	var/list/f_score = navmap_astar_f_score
	// Travel costs for the referenced nodes.
	var/list/g_score = navmap_astar_g_score
	// Last occupied heap position.
	var/last_index = open.len
	while(TRUE)
		// Child positions in the binary heap.
		var/left = index * 2
		if(left > last_index)
			break
		// Best child to compare with the current node.
		var/best = left
		// Right child position, if present.
		var/right = left + 1
		if(right <= last_index && NAVMAP_ASTAR_NODE_BEFORE(open[right], open[left]))
			best = right
		if(!NAVMAP_ASTAR_NODE_BEFORE(open[best], open[index]))
			break
		// Nodes being exchanged in the heap.
		var/turf/current = open[index]
		// Child node being exchanged in the heap.
		var/turf/child = open[best]
		open.Swap(index, best)
		heap_index[current] = best
		heap_index[child] = index
		index = best

/// Adds or reprioritizes a node in the A* heap.
/datum/pathfind/navmap/proc/navmap_astar_queue_update(turf/tile, turf/parent, new_cost)
	if(navmap_astar_closed[tile])
		return
	// Existing cost for this tile, if it has been queued.
	var/old_cost = navmap_astar_g_score[tile]
	if(!isnull(old_cost) && new_cost >= old_cost)
		return
	navmap_astar_g_score[tile] = new_cost
	navmap_astar_f_score[tile] = new_cost + navmap_astar_heuristic(tile)
	navmap_astar_parent[tile] = parent
	// Current heap position for this tile.
	var/index = navmap_astar_heap_index[tile]
	if(index)
		navmap_astar_heap_sift_up(index)
		return
	navmap_astar_open += tile
	index = navmap_astar_open.len
	navmap_astar_heap_index[tile] = index
	navmap_astar_heap_sift_up(index)

/// Removes the best node from the A* heap.
/datum/pathfind/navmap/proc/navmap_astar_heap_pop()
	if(!length(navmap_astar_open))
		return null
	// Local references to heap state.
	var/list/open = navmap_astar_open
	// Heap positions for open nodes.
	var/list/heap_index = navmap_astar_heap_index
	// Lowest-cost node in the heap.
	var/turf/result = open[1]
	heap_index[result] = null
	open[1] = open[open.len]
	open.len--
	if(length(open))
		heap_index[open[1]] = 1
		navmap_astar_heap_sift_down(1)
	navmap_astar_closed[result] = TRUE
	return result

/// Rebuilds a path by following parent nodes.
/datum/pathfind/navmap/proc/navmap_astar_reconstruct(turf/goal_tile)
	// Path collected from goal back to start.
	var/list/reversed = list(goal_tile)
	// Current parent while walking back through the search.
	var/turf/current = goal_tile
	while(navmap_astar_parent[current])
		current = navmap_astar_parent[current]
		reversed += current
	return reverseList(reversed)

/// Expands diagonal steps and records path actions.
/datum/pathfind/navmap/proc/navmap_astar_build_path(turf/goal_tile)
	// Parent-chain path before diagonal expansion.
	var/list/raw_path = navmap_astar_reconstruct(goal_tile)
	// Final path, including any inserted cardinal steps.
	var/list/expanded_path = list(raw_path[1])
	// Actions matching the expanded path entries.
	var/list/expanded_actions = list(0)
	// Expand each pair of adjacent path turfs.
	for(var/i in 1 to (length(raw_path) - 1))
		// Adjacent turfs in the raw path.
		var/turf/from = raw_path[i]
		// Next turf in the raw path.
		var/turf/next = raw_path[i + 1]
		// Direction between the adjacent turfs.
		var/dir = get_dir(from, next)
		if(dir & (dir - 1))
			// Valid cardinal routes around this diagonal.
			var/routes = navmap_astar_diagonal_routes(from, next, dir)
			if(!routes)
				return list()
			// North/south component used for route insertion.
			var/vertical = dir & (NORTH | SOUTH)
			if(diagonal_handling == DIAGONAL_REMOVE_ALL)
				// Direction of the inserted cardinal step.
				var/insert_dir = (routes & 1) ? vertical : (dir & (EAST | WEST))
				expanded_path += get_step(from, insert_dir)
				expanded_actions += 0
			else if(diagonal_handling == DIAGONAL_REMOVE_CLUNKY && !(routes & 1) && (routes & 2))
				expanded_path += get_step(from, dir & (EAST | WEST))
				expanded_actions += 0
		expanded_path += next
		expanded_actions += (navmap_astar_action[next] || 0)
	if(skip_first && length(expanded_path))
		expanded_path.Cut(1, 2)
		expanded_actions.Cut(1, 2)
	action_path = expanded_actions
	return expanded_path

/// Performs one DM A* search step.
/datum/pathfind/navmap/proc/navmap_astar_search_step()
	// Directions considered from each expanded node.
	var/static/list/directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST)
	while(length(navmap_astar_open))
		// Node with the lowest estimated total cost.
		var/turf/current = navmap_astar_heap_pop()
		if((!allow_multiz || current.z == end.z) && max(abs(current.x - end.x), abs(current.y - end.y)) <= minimum_distance)
			path = navmap_astar_build_path(current)
			complete = TRUE
			return TRUE
		// Open cardinal edges from the current turf.
		var/source_edges = navmap_astar_resolve_edges(current)
		// Explore horizontal neighbors.
		for(var/dir in directions)
			// Neighbor in the current direction.
			var/turf/next = get_step(current, dir)
			if(dir & (dir - 1))
				if(navmap_astar_diagonal_routes(current, next, dir, TRUE))
					navmap_astar_action[next] = 0
					navmap_astar_queue_update(next, current, navmap_astar_g_score[current] + 14)
			else if((source_edges & dir) && navmap_astar_turf_open(next))
				navmap_astar_action[next] = 0
				navmap_astar_queue_update(next, current, navmap_astar_g_score[current] + 10)
		if(allow_multiz && navmap_astar_is_flying)
			// Explore vertical neighbors for flying movers.
			for(var/vertical_dir in list(UP, DOWN))
				// Neighbor on the adjacent z-level.
				var/turf/vertical_next = get_step_multiz(current, vertical_dir)
				if(navmap_astar_vertical_open(current, vertical_next, vertical_dir))
					navmap_astar_action[vertical_next] = vertical_dir
					navmap_astar_queue_update(vertical_next, current, navmap_astar_g_score[current] + 10)
		if(allow_multiz)
			// Explore registered cross-z navigation links.
			for(var/link_id in SSnavmap.nav_links)
				// Link being evaluated.
				var/datum/nav_link/link = SSnavmap.nav_links[link_id]
				if(link.source != current || !link.can_plan(pass_info))
					continue
				// Destination turf for this link.
				var/turf/link_destination = link.destination
				if(!navmap_astar_turf_open(link_destination))
					continue
				if(max_path_cost && navmap_astar_g_score[current] + link.cost > max_path_cost)
					continue
				navmap_astar_action[link_destination] = -link.id
				navmap_astar_queue_update(link_destination, current, navmap_astar_g_score[current] + link.cost)
		if(allow_tick_yield)
			CHECK_TICK
	path = list()
	complete = TRUE
	return TRUE

/// Delivers the completed path to the requester.
/datum/pathfind/navmap/finished()
	if(!length(path))
		EVLOG_TEXT(requester, EVLOG_CATEGORY_NAVMAP, "No navmap path (pass_flags=[pass_info.pass_flags])")
	if(allow_multiz)
		// Invoke callbacks with both path and action data.
		for(var/datum/callback/finished as anything in on_finish)
			finished.Invoke(path || list(), action_path || list())
		on_finish = null
	else
		hand_back(path || list())
	return ..()

/// Cancels an active native search before exiting.
/datum/pathfind/navmap/early_exit()
	if(job_id && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	job_id = null
	return ..()

/// Releases navmap search state.
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
	navmap_astar_action = null
	navmap_astar_closed = null
	navmap_astar_edge_cache = null
	navmap_astar_simulated_cache = null
	SSpathfinder.navmap_pathing -= src
	SSpathfinder.current_navmap_run -= src
	requester = null
	end = null
	return ..()

#undef NAVMAP_ASTAR_NODE_BEFORE

/// Runs a navmap search synchronously.
/proc/navmap_pathfinder_blocking(atom/movable/requester, turf/start_turf, turf/end_turf, datum/can_pass_info/pass_info, max_distance, minimum_distance, simulated_only, turf/avoid, diagonal_handling, skip_first, use_dm_implementation = FALSE, allow_tick_yield = TRUE, allow_multiz = FALSE, max_path_cost = 0)
	if(allow_multiz && !use_dm_implementation)
		SSnavmap.sync_native_state()
	if(!use_dm_implementation && navmap_pathfinder_available())
		try
			return navmap_pathfinder(start_turf, end_turf, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first, allow_multiz, max_path_cost)
		catch
			return list()

	// DM fallback search object.
	var/datum/pathfind/navmap/search = new()
	search.force_dm = TRUE
	search.start = start_turf
	search.allow_tick_yield = allow_tick_yield
	search.setup_with_pass_info(requester, end_turf, max_distance, minimum_distance, pass_info, simulated_only, avoid, skip_first, diagonal_handling, null, allow_multiz, max_path_cost)
	if(!search.start())
		qdel(search)
		return list()
	while(!search.complete)
		if(!search.search_step())
			search.early_exit()
			return list()
		if(allow_tick_yield)
			CHECK_TICK
	// Copy the completed path before destroying the search.
	var/list/result = search.path ? search.path.Copy() : list()
	qdel(search)
	return result
