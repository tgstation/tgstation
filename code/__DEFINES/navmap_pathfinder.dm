// DM API for the navmap_pathfinder DLL.

#ifndef NAVMAP_PATHFINDER
/var/__navmap_pathfinder

/proc/__detect_navmap_pathfinder()
	var/arch_suffix = null
	#ifdef OPENDREAM
	arch_suffix = "64"
	#endif
	if (world.system_type == UNIX)
		if (fexists("./libnavmap_pathfinder[arch_suffix].so"))
			return __navmap_pathfinder = "./libnavmap_pathfinder[arch_suffix].so"
		else if (fexists("./navmap_pathfinder[arch_suffix]"))
			return __navmap_pathfinder = "./navmap_pathfinder[arch_suffix]"
		else
			return __navmap_pathfinder = "libnavmap_pathfinder[arch_suffix].so"
	else
		return __navmap_pathfinder = "navmap_pathfinder[arch_suffix]"

#define NAVMAP_PATHFINDER (__navmap_pathfinder || __detect_navmap_pathfinder())
#endif

#if DM_VERSION >= 515
#define NAVMAP_PATHFINDER_CALL call_ext
#else
#define NAVMAP_PATHFINDER_CALL call
#endif

/proc/navmap_pathfinder_get_version()
	return NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:get_version")()

/**
 * Navmap A*. Each start/resume call works for about 5ms, then returns a list
 * with `status` (`in_progress`, `complete`, `no_path`, or `error`), an
 * optional `job_id`, and a final `path` for complete/no_path results.
 */

#define NAVMAP_PATH_IN_PROGRESS "in_progress"
#define NAVMAP_PATH_COMPLETE "complete"
#define NAVMAP_PATH_NO_PATH "no_path"
#define NAVMAP_PATH_ERROR "error"

/** Synchronous call. Use this sparingly for long distances. */
#define navmap_pathfinder(start, end, pass_info, is_flying, max_range, min_target_distance, simulated_only, avoid_turf, diagonal_handling, skip_first) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_pathfinder_ffi")(start, end, pass_info, is_flying, max_range, min_target_distance, simulated_only, avoid_turf, diagonal_handling, skip_first)

#define navmap_pathfinder_start(start, end, pass_info, is_flying, max_range, min_target_distance, simulated_only, avoid_turf, diagonal_handling, skip_first) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_pathfinder_start_ffi")(start, end, pass_info, is_flying, max_range, min_target_distance, simulated_only, avoid_turf, diagonal_handling, skip_first)

/** Resume an in-progress job. Re-supply the current mover pass_info. */
#define navmap_pathfinder_resume(job_id, pass_info) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_pathfinder_resume_ffi")(job_id, pass_info)

/** Drop an in-progress job immediately. Jobs expire after 30 seconds. */
#define navmap_pathfinder_cancel(job_id) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_pathfinder_cancel_ffi")(job_id)

#define navmap_update(x, y, z, nav_pass) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_update_ffi")(x, y, z, nav_pass)

#define navmap_bulk_update(flat_list) \
	NAVMAP_PATHFINDER_CALL(NAVMAP_PATHFINDER, "byond:navmap_bulk_update_ffi")(flat_list)

// Cache the extension probe so a missing or unloadable library does not produce
// repeated call_ext errors from the game.
/var/__navmap_pathfinder_available = null

/proc/navmap_pathfinder_available()
	if(!isnull(__navmap_pathfinder_available))
		return __navmap_pathfinder_available
	try
		__navmap_pathfinder_available = !!navmap_pathfinder_get_version()
	catch
		__navmap_pathfinder_available = FALSE
	return __navmap_pathfinder_available

/proc/navmap_pathfinder_update(x, y, z, nav_pass)
	if(!navmap_pathfinder_available())
		return
	try
		navmap_update(x, y, z, nav_pass)
	catch
		return

/proc/navmap_pathfinder_bulk_update(list/flat_list)
	if(!length(flat_list) || !navmap_pathfinder_available())
		return
	try
		navmap_bulk_update(flat_list)
	catch
		return
