/// Synchronous fallback node. The heap stores the lowest f-value first.
/datum/navmap_fallback_node
	var/turf/tile
	var/cost
	var/f_value
	var/sequence

/datum/navmap_fallback_node/New(turf/our_tile, incoming_cost, incoming_f_value, incoming_sequence)
	tile = our_tile
	cost = incoming_cost
	f_value = incoming_f_value
	sequence = incoming_sequence

/proc/NavmapFallbackPathWeightCompare(datum/navmap_fallback_node/a, datum/navmap_fallback_node/b)
	if(a.f_value != b.f_value)
		return b.f_value - a.f_value
	return b.sequence - a.sequence

/// Returns the two possible cardinal routes for a diagonal. Bit 1 is north/south first,
/// bit 2 is east/west first.
/proc/navmap_fallback_diagonal_routes(turf/source, direction, is_flying, datum/can_pass_info/pass_info, datum/pathfind/navmap/search)
	var/turf/destination = get_step(source, direction)
	if(!destination || !search.fallback_can_occupy(destination))
		return NONE

	var/north_south = direction & (NORTH|SOUTH)
	var/east_west = direction & (EAST|WEST)
	var/routes = NONE
	var/edge_open
	var/turf/middle
	var/list/middle_info

	NAV_EDGE_OPEN_BAKED(source, north_south, is_flying, pass_info, edge_open)
	if(edge_open)
		middle = get_step(source, north_south)
		if(middle && search.fallback_can_occupy(middle))
			middle_info = search.fallback_resolve_turf(middle)
			if(middle_info && (middle_info["open_edges"] & east_west))
				routes |= 1

	NAV_EDGE_OPEN_BAKED(source, east_west, is_flying, pass_info, edge_open)
	if(edge_open)
		middle = get_step(source, east_west)
		if(middle && search.fallback_can_occupy(middle))
			middle_info = search.fallback_resolve_turf(middle)
			if(middle_info && (middle_info["open_edges"] & north_south))
				routes |= 2

	return routes

/// A path datum used by both the navmap DLL and the DM fallback.
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

	// DM fallback state. Each search has its own terrain and conditional-edge cache.
	var/datum/heap/fallback_open
	var/list/fallback_terrain
	var/list/fallback_costs
	var/list/fallback_previous
	var/list/fallback_closed
	var/fallback_sequence = 0

/datum/pathfind/navmap/proc/setup(atom/movable/requester, atom/goal, max_distance, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	var/datum/can_pass_info/info = new /datum/can_pass_info(requester, access, no_id = !length(access))
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
	start = get_turf(requester) // start needs to be set
	. = ..()
	if(!. || !end || start.z != end.z)
		return FALSE

	use_native = !force_dm && navmap_pathfinder_available()
	if(!use_native)
		fallback_initialize()
		return TRUE

	var/list/result
	try
		result = navmap_pathfinder_start(start, end, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
	catch
		navmap_pathfinder_mark_unavailable()
		use_native = FALSE
		fallback_initialize()
		return TRUE
	return handle_result(result)

/datum/pathfind/navmap/search_step()
	if(QDELETED(requester) || QDELETED(end))
		return FALSE
	if(complete)
		return TRUE
	if(!use_native)
		return fallback_search_step()

	var/list/result
	try
		result = navmap_pathfinder_resume(job_id, pass_info)
	catch
		// A DLL can disappear or fail to load after the initial probe. Restart this
		// search in DM rather than dropping the movement request.
		navmap_pathfinder_mark_unavailable()
		use_native = FALSE
		job_id = null
		fallback_initialize()
		return fallback_search_step()
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

/datum/pathfind/navmap/proc/fallback_initialize()
	fallback_open = new /datum/heap(/proc/NavmapFallbackPathWeightCompare)
	fallback_terrain = list()
	fallback_costs = list()
	fallback_previous = list()
	fallback_closed = list()
	fallback_sequence = 0
	path = null
	complete = FALSE
	if(start == avoid || (max_distance && get_dist(start, end) > max_distance + minimum_distance) || !fallback_can_occupy(start))
		path = list()
		complete = TRUE
		return
	fallback_push(start, 0)

/datum/pathfind/navmap/proc/fallback_resolve_turf(turf/tile)
	if(!tile || tile.z != start.z)
		return null
	var/list/cached = fallback_terrain[tile]
	if(cached)
		return cached

	NAV_ENSURE_BAKED(tile)
	if(isnull(tile.nav_pass) || !(tile.nav_pass & NAV_BAKED))
		return null

	var/open_edges = NONE
	var/edge_open
	for(var/direction in GLOB.cardinals)
		NAV_EDGE_OPEN_BAKED(tile, direction, NAV_IS_FLYING(pass_info), pass_info, edge_open)
		if(edge_open)
			open_edges |= direction

	cached = list(
		"open_edges" = open_edges,
		"simulated" = !!(tile.nav_pass & NAV_SIMULATED),
	)
	fallback_terrain[tile] = cached
	return cached

/datum/pathfind/navmap/proc/fallback_can_occupy(turf/tile)
	if(!tile || tile.z != start.z || tile == avoid)
		return FALSE
	if(max_distance && get_dist(start, tile) > max_distance)
		return FALSE
	if(simulated_only && SSpathfinder.space_type_cache[tile.type])
		return FALSE
	var/list/info = fallback_resolve_turf(tile)
	return info && (!simulated_only || info["simulated"])

/datum/pathfind/navmap/proc/fallback_can_step(turf/source, turf/destination, direction)
	if(!source || !destination || !fallback_can_occupy(destination))
		return FALSE
	if(direction & (direction - 1))
		return !!navmap_fallback_diagonal_routes(source, direction, NAV_IS_FLYING(pass_info), pass_info, src)
	var/list/source_info = fallback_resolve_turf(source)
	return source_info && (source_info["open_edges"] & direction)

/datum/pathfind/navmap/proc/fallback_push(turf/tile, cost)
	fallback_costs[tile] = cost
	fallback_sequence++
	var/dx = abs(tile.x - end.x)
	var/dy = abs(tile.y - end.y)
	dx = max(dx - minimum_distance, 0)
	dy = max(dy - minimum_distance, 0)
	var/heuristic = 14 * min(dx, dy) + 10 * abs(dx - dy)
	fallback_open.insert(new /datum/navmap_fallback_node(tile, cost, cost + heuristic, fallback_sequence))

/datum/pathfind/navmap/proc/fallback_reconstruct(turf/goal_tile)
	var/list/reversed = list(goal_tile)
	var/turf/current = goal_tile
	while(current != start)
		current = fallback_previous[current]
		if(!current)
			path = list()
			complete = TRUE
			return
		reversed += current

	var/list/nodes = reverseList(reversed)
	var/list/final_path = list(nodes[1])
	for(var/i in 1 to (length(nodes) - 1))
		var/turf/from = nodes[i]
		var/turf/next_turf = nodes[i + 1]
		var/direction = get_dir(from, next_turf)
		if(direction & (direction - 1))
			var/routes = navmap_fallback_diagonal_routes(from, direction, NAV_IS_FLYING(pass_info), pass_info, src)
			if(diagonal_handling == DIAGONAL_REMOVE_ALL)
				if(routes & 1)
					final_path += get_step(from, direction & (NORTH|SOUTH))
				else if(routes & 2)
					final_path += get_step(from, direction & (EAST|WEST))
				else
					path = list()
					complete = TRUE
					return
			else if(diagonal_handling == DIAGONAL_REMOVE_CLUNKY && !(routes & 1) && (routes & 2))
				final_path += get_step(from, direction & (EAST|WEST))
		final_path += next_turf

	if(skip_first && length(final_path))
		final_path.Cut(1, 2)
	path = final_path
	complete = TRUE

/datum/pathfind/navmap/proc/fallback_consider(turf/current, direction, movement_cost)
	var/turf/next = get_step(current, direction)
	if(!fallback_can_step(current, next, direction))
		return
	var/next_cost = fallback_costs[current] + movement_cost
	if(!isnull(fallback_costs[next]) && next_cost >= fallback_costs[next])
		return
	fallback_previous[next] = current
	fallback_closed[next] = FALSE
	fallback_push(next, next_cost)

/datum/pathfind/navmap/proc/fallback_search_step()
	while(!fallback_open.is_empty())
		var/datum/navmap_fallback_node/current_node = fallback_open.pop()
		if(isnull(current_node))
			break
		if(fallback_costs[current_node.tile] != current_node.cost || fallback_closed[current_node.tile])
			continue
		fallback_closed[current_node.tile] = TRUE

		if(get_dist(current_node.tile, end) <= minimum_distance)
			fallback_reconstruct(current_node.tile)
			return TRUE

		for(var/direction in GLOB.cardinals)
			fallback_consider(current_node.tile, direction, 10)
		for(var/direction in GLOB.diagonals)
			fallback_consider(current_node.tile, direction, 14)

		CHECK_TICK

	path = list()
	complete = TRUE
	return TRUE

/datum/pathfind/navmap/finished()
	if(!length(path))
		EVLOG_TEXT(requester, EVLOG_CATEGORY_NAVMAP, "No navmap A* path (pass_flags=[pass_info.pass_flags])")
	hand_back(path || list())
	return ..()

/datum/pathfind/navmap/early_exit()
	if(job_id && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			navmap_pathfinder_mark_unavailable()
	job_id = null
	return ..()

/datum/pathfind/navmap/Destroy(force)
	if(job_id && !complete && use_native && navmap_pathfinder_available())
		try
			navmap_pathfinder_cancel(job_id)
		catch
			navmap_pathfinder_mark_unavailable()
	job_id = null
	QDEL_NULL(fallback_open)
	fallback_terrain = null
	fallback_costs = null
	fallback_previous = null
	fallback_closed = null
	SSpathfinder.navmap_pathing -= src
	SSpathfinder.current_navmap_run -= src
	requester = null
	end = null
	return ..()

/proc/navmap_pathfinder_blocking(atom/movable/requester, turf/start_turf, turf/end_turf, datum/can_pass_info/pass_info, max_distance, minimum_distance, simulated_only, turf/avoid, diagonal_handling, skip_first, use_dm_implementation = FALSE)
	if(!use_dm_implementation && navmap_pathfinder_available())
		try
			return navmap_pathfinder(start_turf, end_turf, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
		catch
			navmap_pathfinder_mark_unavailable()

	var/datum/pathfind/navmap/search = new()
	search.force_dm = TRUE
	search.setup_with_pass_info(requester, end_turf, max_distance, minimum_distance, pass_info, simulated_only, avoid, skip_first, diagonal_handling)
	if(!search.start())
		qdel(search)
		return list()
	while(!search.complete)
		if(!search.search_step())
			search.early_exit()
			return list()
		CHECK_TICK
	var/list/result = search.path ? search.path.Copy() : list()
	qdel(search)
	return result
