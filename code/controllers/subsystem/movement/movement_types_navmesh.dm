/*
 * Move loop for following rust-g threaded A* paths over the experimental navmesh (SSnavmesh).
 * Mirrors /datum/move_loop/has_target/jps's shape (see movement_types.dm), but repaths via
 * rustg_nav_astar_async()/rustg_nav_astar_check() instead of SSpathfinder: the search runs on a
 * background thread with no callback into DM, so it has to be polled rather than waited on. Polling
 * happens once per move_loop tick from move() - never via UNTIL() - so a slow/stuck search just holds
 * the loop at MOVELOOP_NOT_READY instead of blocking the movement subsystem.
 */

/**
 * Used for following rustg_nav_astar_async() defined paths over SSnavmesh.
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - Chebyshev distance cap from start, in tiles (0 = unlimited)
 * access - A list representing what access we have and what doors we can open
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/navmesh_astar_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	list/access,
	subsystem,
	priority,
	flags,
	datum/extra_info,
	initial_path)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/navmesh_astar,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		access,
		initial_path)

/datum/move_loop/has_target/navmesh_astar
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Chebyshev distance cap from start, in tiles. 0 = unlimited
	var/max_path_length
	///A list representing what access we have and what doors we can open
	var/list/access
	///The mover profile handed to rustg_nav_astar_async(), built from `moving` so pass_flags/movement_type track it live
	var/datum/can_pass_info/pass_info
	///The path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	///Job id of an in-flight rustg_nav_astar_async() search, or null if none is running
	var/job_id
	///TRUE while a search is in flight (job_id set, not yet resolved)
	var/is_pathing = FALSE

/datum/move_loop/has_target/navmesh_astar/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, list/access, list/initial_path)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.access = access
	pass_info = new /datum/can_pass_info(moving, access)
	movement_path = initial_path?.Copy()

/datum/move_loop/has_target/navmesh_astar/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, list/access, initial_path)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && access ~= src.access)
		return TRUE
	return FALSE

/datum/move_loop/has_target/navmesh_astar/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/navmesh_astar/loop_stopped()
	. = ..()
	movement_path = null
	job_id = null
	is_pathing = FALSE

/datum/move_loop/has_target/navmesh_astar/Destroy()
	pass_info = null
	return ..()

///Starts a new rust-g navmesh A* search, unless one is already in flight or we're on repath cooldown.
/datum/move_loop/has_target/navmesh_astar/proc/recalculate_path()
	if(is_pathing || !COOLDOWN_FINISHED(src, repath_cooldown))
		return
	var/turf/start = get_turf(moving)
	var/turf/goal = get_turf(target)
	if(!start || !goal || start.z != goal.z)
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	try
		job_id = rustg_nav_astar_async(start, goal, pass_info, NAV_IS_FLYING(pass_info), max_path_length)
		is_pathing = TRUE
	catch
		job_id = null
		is_pathing = FALSE
		return
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_REPATH)

///Non-blocking poll of the in-flight search, if any. One check per call - never UNTIL()s, the move_loop's own ticking is how we "wait".
/datum/move_loop/has_target/navmesh_astar/proc/poll_path()
	if(!is_pathing)
		return
	var/result
	try
		result = rustg_nav_astar_check(job_id)
	catch
		// rust-g missing turf_pathfinder, or the job died - give up on this search, next move() attempt will start a fresh one
		is_pathing = FALSE
		job_id = null
		return
	if(result == RUSTG_JOB_NO_RESULTS_YET)
		return
	is_pathing = FALSE
	job_id = null
	movement_path = result
	EVLOG_PATH(moving, EVLOG_CATEGORY_NAVMESH, "Planned navmesh A* path", movement_path)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_FINISHED_PATHING, movement_path)

/datum/move_loop/has_target/navmesh_astar/move()
	if(is_pathing)
		poll_path()

	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMESH, "Path recalculating due to lack of path")
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	moving.Move(next_step, get_dir(moving, next_step), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	if(get_turf(moving) == next_step)
		if(length(movement_path))
			movement_path.Cut(1, 2)
	else
		return handle_move_attempt_failure()

///Discards the stale path and starts a fresh search after a queued move lands us somewhere unexpected (bump/obstruction).
/datum/move_loop/has_target/navmesh_astar/proc/handle_move_attempt_failure()
	EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMESH, "Path recalculating due to obstruction")
	movement_path = null
	INVOKE_ASYNC(src, PROC_REF(recalculate_path))
	return MOVELOOP_FAILURE
