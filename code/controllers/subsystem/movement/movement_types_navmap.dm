
/// Starts a movement loop that follows async navmap A* paths.
/datum/move_manager/proc/navmap_astar_move(moving,
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
	initial_path,
	allow_multiz = FALSE,
	max_path_cost = 0)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/navmap_astar,
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
		initial_path,
		allow_multiz,
		max_path_cost)

/datum/move_loop/has_target/navmap_astar
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
	var/allow_multiz = FALSE
	var/max_path_cost = 0
	///The path we're currently following
	var/list/movement_path
	var/list/movement_actions
	///The SSpathfinder job currently producing a path.
	var/datum/pathfind/navmap/pathfinding
	var/is_pathing = FALSE
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	/// A target update arrived while a path was being generated or repathing was rate-limited.
	var/repath_pending = FALSE
	var/datum/nav_link/active_link
	var/turf/link_target
	var/is_link_traversing = FALSE

/// Stores pathing options and creates the mover's passability profile.
/datum/move_loop/has_target/navmap_astar/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/initial_path, allow_multiz = FALSE, max_path_cost = 0)
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
	src.allow_multiz = allow_multiz
	src.max_path_cost = max_path_cost
	movement_path = initial_path?.Copy()

/// Returns whether another request can reuse this loop.
/datum/move_loop/has_target/navmap_astar/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, initial_path, allow_multiz = FALSE, max_path_cost = 0)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && access ~= src.access && simulated_only == src.simulated_only && avoid == src.avoid && skip_first == src.skip_first && diagonal_handling == src.diagonal_handling && allow_multiz == src.allow_multiz && max_path_cost == src.max_path_cost)
		return TRUE
	return FALSE

/// Plans an initial path when one was not supplied.
/datum/move_loop/has_target/navmap_astar/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/// Releases the path when movement stops.
/datum/move_loop/has_target/navmap_astar/loop_stopped()
	. = ..()
	cancel_pathfinding()
	repath_pending = FALSE
	movement_path = null
	movement_actions = null

/// Releases the mover passability profile.
/datum/move_loop/has_target/navmap_astar/Destroy()
	cancel_pathfinding()
	is_link_traversing = FALSE
	active_link = null
	repath_pending = FALSE
	avoid = null
	return ..()

/// Cancels the outstanding native job, if any.
/datum/move_loop/has_target/navmap_astar/proc/cancel_pathfinding()
	if(pathfinding)
		pathfinding.on_finish = null
		qdel(pathfinding)
		pathfinding = null
	is_pathing = FALSE

/// Rebuilds the path when the repath cooldown permits it.
/datum/move_loop/has_target/navmap_astar/proc/recalculate_path()
	// Preserve an active search and usable path. A moving target otherwise repeatedly cancels
	// its own search before a result is returned; one follow-up search is enough to catch up.
	if(is_pathing || !COOLDOWN_FINISHED(src, repath_cooldown))
		repath_pending = TRUE
		return
	repath_pending = FALSE
	movement_path = null
	var/turf/start = get_turf(moving)
	var/turf/goal = get_turf(target)
	if(!start || !goal || (!allow_multiz && start.z != goal.z))
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMAP_REPATH)
	pathfinding = SSpathfinder.navmap_pathfind(moving, target, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, list(CALLBACK(src, PROC_REF(on_finish_pathing))), allow_multiz, max_path_cost)
	is_pathing = !!pathfinding

/// Accepts the completed path returned by SSpathfinder.
/datum/move_loop/has_target/navmap_astar/proc/on_finish_pathing(list/path, list/actions)
	pathfinding = null
	is_pathing = FALSE
	movement_path = path || list()
	movement_actions = actions || list()
	if(moving)
		EVLOG_PATH(moving, EVLOG_CATEGORY_NAVMAP, "Planned navmap A* path", movement_path)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMAP_FINISHED_PATHING, movement_path, movement_actions)
	if(repath_pending && COOLDOWN_FINISHED(src, repath_cooldown))
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/// Moves one step and replans after an obstruction.
/datum/move_loop/has_target/navmap_astar/move()
	if(is_pathing)
		return MOVELOOP_NOT_READY
	if(is_link_traversing)
		return MOVELOOP_NOT_READY
	if(!length(movement_path))
		EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMAP, "Path recalculating due to lack of path")
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/action = movement_actions?[1]
	if(action && action < 0)
		var/datum/nav_link/link = SSnavmap.nav_links[-action]
		if(!link)
			return handle_move_attempt_failure()
		active_link = link
		link_target = next_step
		is_link_traversing = TRUE
		link.begin_traversal(moving, CALLBACK(src, PROC_REF(on_link_finished)))
		return MOVELOOP_NOT_READY
	var/atom/old_loc = moving.loc
	if(action == UP || action == DOWN)
		moving.zMove(target = next_step, z_move_flags = ZMOVE_CHECK_PULLS|ZMOVE_ALLOW_BUCKLED)
	else
		moving.Move(next_step, get_dir(moving, next_step), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE
	if(get_turf(moving) == next_step)
		if(length(movement_path))
			movement_path.Cut(1, 2)
		if(length(movement_actions))
			movement_actions.Cut(1, 2)
	else
		return handle_move_attempt_failure()

/// Drops a stale path after a blocked movement attempt.
/datum/move_loop/has_target/navmap_astar/proc/handle_move_attempt_failure()
	EVLOG_TEXT(moving, EVLOG_CATEGORY_NAVMAP, "Path recalculating due to obstruction")
	movement_path = null
	INVOKE_ASYNC(src, PROC_REF(recalculate_path))
	return MOVELOOP_FAILURE

/datum/move_loop/has_target/navmap_astar/proc/on_link_finished(success)
	if(!is_link_traversing)
		return
	is_link_traversing = FALSE
	active_link = null
	if(success && get_turf(moving) == link_target)
		movement_path?.Cut(1, 2)
		movement_actions?.Cut(1, 2)
		link_target = null
		return
	link_target = null
	handle_move_attempt_failure()

/datum/move_manager/proc/navmap_frustrations_move(moving, chasing, delay, timeout, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, subsystem, priority, flags, datum/extra_info, initial_path)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/navmap_astar/frustrations, priority, flags, extra_info, delay, timeout, chasing, repath_delay, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, initial_path)

/datum/move_loop/has_target/navmap_astar/frustrations
	var/maximum_frustrations = 10
	var/current_frustrations = 0
	var/frustration_delay = 2 SECONDS
	var/initial_path_drawn = FALSE
	COOLDOWN_DECLARE(frustration_cooldown)

/datum/move_loop/has_target/navmap_astar/frustrations/recalculate_path()
	if(initial_path_drawn && current_frustrations < maximum_frustrations)
		return
	return ..()

/datum/move_loop/has_target/navmap_astar/frustrations/on_finish_pathing(list/path, list/actions)
	. = ..(path, actions)
	if(length(movement_path))
		initial_path_drawn = TRUE

/datum/move_loop/has_target/navmap_astar/frustrations/handle_move_attempt_failure()
	if(!initial_path_drawn)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE
	if(!COOLDOWN_FINISHED(src, frustration_cooldown))
		return NONE
	COOLDOWN_START(src, frustration_cooldown, frustration_delay)
	current_frustrations++
	SEND_SIGNAL(src, COMSIG_MOVELOOP_NAVMAP_FRUSTRATION_INCREMENTED, current_frustrations)
	if(current_frustrations >= maximum_frustrations)
		current_frustrations = 0
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE
