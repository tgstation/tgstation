/// A rust-g navmap search advanced one native slice per SSpathfinder fire.
/datum/pathfind/navmap
	var/atom/movable/requester
	var/turf/end
	var/minimum_distance
	var/skip_first
	var/diagonal_handling
	var/job_id
	var/complete = FALSE
	var/list/path

/datum/pathfind/navmap/proc/setup(atom/movable/requester, atom/goal, max_distance, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(goal)
	src.max_distance = max_distance
	src.minimum_distance = minimum_distance || 0
	// An empty access profile cannot operate even unrestricted airlocks.
	src.pass_info = new(requester, access, no_id = !length(access))
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	src.on_finish = on_finish

/datum/pathfind/navmap/start()
	start = get_turf(requester) //start needs to be set
	. = ..()
	if(!. || !end || start.z != end.z)
		return FALSE
	var/list/result
	try
		result = rustg_navmap_pathfinder_start(start, end, pass_info, NAV_IS_FLYING(pass_info), max_distance, minimum_distance, simulated_only, avoid, diagonal_handling, skip_first)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/search_step()
	if(QDELETED(requester) || QDELETED(end))
		return FALSE
	if(complete)
		return TRUE
	var/list/result
	try
		result = rustg_navmap_pathfinder_resume(job_id, pass_info)
	catch
		return FALSE
	return handle_result(result)

/datum/pathfind/navmap/proc/handle_result(list/result)
	if(!islist(result))
		return FALSE
	switch(result["status"])
		if(RUSTG_NAVMAP_PATH_IN_PROGRESS)
			job_id = result["job_id"]
			return !!job_id
		if(RUSTG_NAVMAP_PATH_COMPLETE, RUSTG_NAVMAP_PATH_NO_PATH)
			path = result["path"] || list()
			complete = TRUE
			return TRUE
		if(RUSTG_NAVMAP_PATH_ERROR)
			path = list()
			complete = TRUE
			return TRUE
	return FALSE

/datum/pathfind/navmap/finished()
	if(!length(path))
		EVLOG_TEXT(requester, EVLOG_CATEGORY_NAVMAP, "No navmap A* path (pass_flags=[pass_info.pass_flags])")
	hand_back(path || list())
	return ..()

/datum/pathfind/navmap/early_exit()
	if(job_id)
		try
			rustg_navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	return ..()

/datum/pathfind/navmap/Destroy(force)
	if(job_id && !complete)
		try
			rustg_navmap_pathfinder_cancel(job_id)
		catch
			job_id = null
	SSpathfinder.navmap_pathing -= src
	SSpathfinder.current_navmap_run -= src
	requester = null
	end = null
	return ..()
