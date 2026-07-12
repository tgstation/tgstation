
/**
 * Used for following rustg_turfmap_pathfinder() defined paths over SSnavmesh.
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
	///The mover profile handed to rustg_turfmap_pathfinder(), built from `moving` so pass_flags/movement_type track it live
	var/datum/can_pass_info/pass_info
	///The path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)

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
		recalculate_path()

/datum/move_loop/has_target/navmesh_astar/loop_stopped()
	. = ..()
	movement_path = null

/datum/move_loop/has_target/navmesh_astar/Destroy()
	pass_info = null
	return ..()

///Runs a fresh rust-g navmesh A* search and stores the result, unless we're still on repath cooldown.
///Synchronous: rustg_turfmap_pathfinder() returns the finished path inline, so there's nothing to poll.
/datum/move_loop/has_target/navmesh_astar/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	var/turf/start = get_turf(moving)
	var/turf/goal = get_turf(target)
	if(!start || !goal || start.z != goal.z)
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_REPATH)
	var/list/result
	try
		result = rustg_turfmap_pathfinder(start, goal, pass_info, NAV_IS_FLYING(pass_info), max_path_length)
	catch
		// rust-g missing turfmap_pathfinder, or the search errored
		return
	movement_path = result
	EVLOG_PATH(moving, EVLOG_CATEGORY_NAVMESH, "Planned navmesh A* path", movement_path)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_FINISHED_PATHING, movement_path)

/datum/move_loop/has_target/navmesh_astar/move()
	if(!length(movement_path))
		EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMESH, "Path recalculating due to lack of path")
		recalculate_path()
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
	recalculate_path()
	return MOVELOOP_FAILURE
