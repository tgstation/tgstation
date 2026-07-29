
/// Starts a movement loop that follows synchronous navmesh A* paths.
/datum/move_manager/proc/navmesh_astar_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	list/access,
	simulated_only,
	turf/avoid,
	skip_first,
	diagonal_handling,
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
		minimum_distance,
		access,
		simulated_only,
		avoid,
		skip_first,
		diagonal_handling,
		initial_path)

/datum/move_loop/has_target/navmesh_astar
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Chebyshev distance cap from start, in tiles. 0 = unlimited
	var/max_path_length
	var/minimum_distance
	///A list representing what access we have and what doors we can open
	var/list/access
	var/simulated_only
	var/turf/avoid
	var/skip_first
	var/diagonal_handling
	///The mover profile handed to rustg_turfmap_pathfinder(), built from `moving` so pass_flags/movement_type track it live
	var/datum/can_pass_info/pass_info
	///The path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)

/// Stores pathing options and creates the mover's passability profile.
/datum/move_loop/has_target/navmesh_astar/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/initial_path)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.minimum_distance = minimum_distance
	src.access = access
	src.simulated_only = simulated_only
	src.avoid = avoid
	// Native paths include the starting turf unless explicitly omitted.
	src.skip_first = isnull(skip_first) ? TRUE : skip_first
	src.diagonal_handling = isnull(diagonal_handling) ? DIAGONAL_DO_NOTHING : diagonal_handling
	pass_info = new /datum/can_pass_info(moving, access)
	movement_path = initial_path?.Copy()

/// Returns whether another request can reuse this loop.
/datum/move_loop/has_target/navmesh_astar/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, initial_path)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && access ~= src.access && simulated_only == src.simulated_only && avoid == src.avoid && skip_first == src.skip_first && diagonal_handling == src.diagonal_handling)
		return TRUE
	return FALSE

/// Plans an initial path when one was not supplied.
/datum/move_loop/has_target/navmesh_astar/loop_started()
	. = ..()
	if(!movement_path)
		recalculate_path()

/// Releases the path when movement stops.
/datum/move_loop/has_target/navmesh_astar/loop_stopped()
	. = ..()
	movement_path = null

/// Releases the mover passability profile.
/datum/move_loop/has_target/navmesh_astar/Destroy()
	pass_info = null
	avoid = null
	return ..()
/// Rebuilds the path when the repath cooldown permits it.
/datum/move_loop/has_target/navmesh_astar/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	var/turf/start = get_turf(moving)
	var/turf/goal = get_turf(target)
	if(!start || !goal || start.z != goal.z)
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_REPATH)
	pass_info = new /datum/can_pass_info(moving, access)
	var/list/result
	try
		result = rustg_turfmap_pathfinder(start, goal, pass_info, NAV_IS_FLYING(pass_info), max_path_length, minimum_distance || 0, simulated_only, avoid, diagonal_handling, skip_first)
	catch
		return
	movement_path = result
	EVLOG_PATH(moving, EVLOG_CATEGORY_NAVMESH, "Planned navmesh A* path", movement_path)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_FINISHED_PATHING, movement_path)

/// Moves one step and replans after an obstruction.
/datum/move_loop/has_target/navmesh_astar/move()
	if(!length(movement_path))
		EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMESH, "Path recalculating due to lack of path")
		recalculate_path()
		return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	moving.Move(next_step, get_dir(moving, next_step), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE
	if(get_turf(moving) == next_step)
		if(length(movement_path))
			movement_path.Cut(1, 2)
	else
		return handle_move_attempt_failure()
/// Drops a stale path after a blocked movement attempt.
/datum/move_loop/has_target/navmesh_astar/proc/handle_move_attempt_failure()
	EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMESH, "Path recalculating due to obstruction")
	movement_path = null
	recalculate_path()
	return MOVELOOP_FAILURE

/datum/move_manager/proc/navmesh_frustrations_move(moving, chasing, delay, timeout, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, subsystem, priority, flags, datum/extra_info, initial_path)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/navmesh_astar/frustrations, priority, flags, extra_info, delay, timeout, chasing, repath_delay, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, initial_path)

/datum/move_loop/has_target/navmesh_astar/frustrations
	var/maximum_frustrations = 10
	var/current_frustrations = 0
	var/frustration_delay = 2 SECONDS
	var/initial_path_drawn = FALSE
	COOLDOWN_DECLARE(frustration_cooldown)

/datum/move_loop/has_target/navmesh_astar/frustrations/recalculate_path()
	if(initial_path_drawn && current_frustrations < maximum_frustrations)
		return
	. = ..()
	if(length(movement_path))
		initial_path_drawn = TRUE

/datum/move_loop/has_target/navmesh_astar/frustrations/handle_move_attempt_failure()
	if(!initial_path_drawn)
		recalculate_path()
		return MOVELOOP_FAILURE
	if(!COOLDOWN_FINISHED(src, frustration_cooldown))
		return NONE
	COOLDOWN_START(src, frustration_cooldown, frustration_delay)
	current_frustrations++
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMESH_FRUSTRATION_INCREMENTED, current_frustrations)
	if(current_frustrations >= maximum_frustrations)
		current_frustrations = 0
		recalculate_path()
		return MOVELOOP_FAILURE
