///Template class of the movement datums, handles the timing portion of the loops
/datum/move_loop
	///The movement packet that owns us
	var/datum/movement_packet/owner
	///The subsystem we're processing on
	var/datum/controller/subsystem/movement/controller
	///An extra reference we pass around
	///It is on occasion useful to have a reference to some datum without storing it on the moving object
	///Mostly comes up in high performance senarios where we care about things being singletons
	///This feels horrible, but constantly making components seems worse
	var/datum/extra_info
	///The thing we're moving about
	var/atom/movable/moving
	///Defines how different move loops override each other. Higher numbers beat lower numbers
	var/priority = MOVEMENT_DEFAULT_PRIORITY
	///Bitfield of different things that affect how a loop operates, and other mechanics around it as well.
	var/flags
	///Time till we stop processing in deci-seconds, defaults to forever
	var/lifetime = INFINITY
	///Delay between each move in deci-seconds
	var/delay = 1
	///The next time we should process
	///Used primarially as a hint to be reasoned about by our [controller], and as the id of our bucket
	var/timer = 0
	///The time we are CURRENTLY queued for processing
	///Do not modify this directly
	var/queued_time = -1
	/// Status bitfield for what state the move loop is currently in
	var/status = NONE

/datum/move_loop/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	src.owner = owner
	src.controller = controller
	src.extra_info = extra_info
	if(extra_info)
		RegisterSignal(extra_info, COMSIG_QDELETING, PROC_REF(info_deleted))
	src.moving = moving
	src.priority = priority
	src.flags = flags

/datum/move_loop/proc/setup(delay = 1, timeout = INFINITY)
	if(!ismovable(moving) || !owner)
		return FALSE

	src.delay = max(delay, world.tick_lag) //Please...
	src.lifetime = timeout
	return TRUE

///check if this exact moveloop datum already exists (in terms of vars) so we can avoid creating a new one to overwrite the old duplicate
/datum/move_loop/proc/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay = 1, timeout = INFINITY)
	SHOULD_CALL_PARENT(TRUE)
	if(loop_type == type && priority == src.priority && flags == src.flags && delay == src.delay && timeout == lifetime)
		return TRUE
	return FALSE

///Called when a loop is starting by a movement subsystem
/datum/move_loop/proc/loop_started()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_START)
	status |= MOVELOOP_STATUS_RUNNING
	//If this is our first time starting to move with this loop
	//And we're meant to start instantly
	if(!timer && flags & MOVEMENT_LOOP_START_FAST)
		timer = world.time
		return
	timer = world.time + delay

///Called when a loop is stopped, doesn't stop the loop itself
/datum/move_loop/proc/loop_stopped()
	SHOULD_CALL_PARENT(TRUE)
	status &= ~MOVELOOP_STATUS_RUNNING
	SEND_SIGNAL(src, COMSIG_MOVELOOP_STOP)

/datum/move_loop/proc/info_deleted(datum/source)
	SIGNAL_HANDLER
	extra_info = null

/datum/move_loop/Destroy()
	if(owner)
		owner.remove_loop(controller, src)
	owner = null
	moving = null
	controller = null
	extra_info = null
	return ..()

///Exists as a helper so outside code can modify delay in a sane way
/datum/move_loop/proc/set_delay(new_delay)
	delay =  max(new_delay, world.tick_lag)

///Pauses the move loop for some passed in period
///This functionally means shifting its timer up, and clearing it from its current bucket
/datum/move_loop/proc/pause_for(time)
	if(!controller || !(status & MOVELOOP_STATUS_RUNNING)) //No controller or not running? go away
		return
	//Dequeue us from our current bucket
	controller.dequeue_loop(src)
	//Offset our timer
	timer = world.time + time
	//Now requeue us with our new target start time
	controller.queue_loop(src)

/datum/move_loop/process()
	if(isnull(controller))
		qdel(src)
		return

	var/old_delay = delay //The signal can sometimes change delay

	if(SEND_SIGNAL(src, COMSIG_MOVELOOP_PREPROCESS_CHECK) & MOVELOOP_SKIP_STEP) //Chance for the object to react
		return

	lifetime -= old_delay //This needs to be based on work over time, not just time passed

	if(lifetime < 0) //Otherwise lag would make things look really weird
		qdel(src)
		return

	var/visual_delay = controller.visual_delay
	var/old_dir = moving.dir
	var/old_loc = moving.loc

	owner?.processing_move_loop_flags = flags
	var/result = move() //Result is an enum value. Enums defined in __DEFINES/movement.dm
	if(moving)
		var/direction = get_dir(old_loc, moving.loc)
		SEND_SIGNAL(moving, COMSIG_MOVABLE_MOVED_FROM_LOOP, src, old_dir, direction)
	owner?.processing_move_loop_flags = NONE

	SEND_SIGNAL(src, COMSIG_MOVELOOP_POSTPROCESS, result, delay * visual_delay)

	if(QDELETED(src) || result != MOVELOOP_SUCCESS) //Can happen
		return

	if(flags & MOVEMENT_LOOP_IGNORE_GLIDE)
		return

	moving.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, visual_delay))

///Handles the actual move, overriden by children
///Returns FALSE if nothing happen, TRUE otherwise
/datum/move_loop/proc/move()
	return MOVELOOP_FAILURE


///Pause our loop untill restarted with resume_loop()
/datum/move_loop/proc/pause_loop()
	if(!controller || !(status & MOVELOOP_STATUS_RUNNING) || (status & MOVELOOP_STATUS_PAUSED)) //we dead
		return

	//Dequeue us from our current bucket
	controller.dequeue_loop(src)
	status |= MOVELOOP_STATUS_PAUSED

///Resume our loop after being paused by pause_loop()
/datum/move_loop/proc/resume_loop()
	if(!controller || (status & (MOVELOOP_STATUS_RUNNING|MOVELOOP_STATUS_PAUSED)) != (MOVELOOP_STATUS_RUNNING|MOVELOOP_STATUS_PAUSED))
		return

	timer = world.time
	controller.queue_loop(src)
	status &= ~MOVELOOP_STATUS_PAUSED

///Removes the atom from some movement subsystem. Defaults to SSmovement
/datum/move_manager/proc/stop_looping(atom/movable/moving, datum/controller/subsystem/movement/subsystem = SSmovement)
	var/datum/movement_packet/our_info = moving.move_packet
	if(!our_info)
		return FALSE
	return our_info.remove_subsystem(subsystem)

/**
 * Replacement for walk()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move, priority, flags, extra_info, delay, timeout, direction)

///Replacement for walk()
/datum/move_loop/move
	var/direction

/datum/move_loop/move/setup(delay, timeout, dir)
	. = ..()
	if(!.)
		return
	direction = dir

/datum/move_loop/move/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, dir)
	if(..() && direction == dir)
		return TRUE
	return FALSE

/datum/move_loop/move/move()
	var/atom/old_loc = moving.loc
	moving.Move(get_step(moving, direction), direction, FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	// We cannot rely on the return value of Move(), we care about teleports and it doesn't
	// Moving also can be null on occasion, if the move deleted it and therefor us
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/**
 * Like move(), but we don't care about collision at all
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/force_move_dir(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move/force, priority, flags, extra_info, delay, timeout, direction)

/datum/move_loop/move/force

/datum/move_loop/move/force/move()
	var/atom/old_loc = moving.loc
	moving.forceMove(get_step(moving, direction))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/datum/move_loop/has_target
	///The thing we're moving in relation to, either at or away from
	var/atom/target

/datum/move_loop/has_target/setup(delay, timeout, atom/chasing)
	. = ..()
	if(!.)
		return
	if(!isatom(chasing))
		qdel(src)
		return FALSE

	target = chasing

	if(!isturf(target))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(handle_no_target)) //Don't do this for turfs, because we don't care

/datum/move_loop/has_target/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing)
	if(..() && chasing == target)
		return TRUE
	return FALSE

/datum/move_loop/has_target/Destroy()
	target = null
	return ..()

/datum/move_loop/has_target/proc/handle_no_target()
	SIGNAL_HANDLER
	qdel(src)


/**
 * Used for force-move loops, similar to move_towards_legacy() but not quite the same
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/force_move(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/force_move, priority, flags, extra_info, delay, timeout, chasing)

///Used for force-move loops
/datum/move_loop/has_target/force_move

/datum/move_loop/has_target/force_move/move()
	var/atom/old_loc = moving.loc
	moving.forceMove(get_step(moving, get_dir(moving, target)))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/**
 * Used for following jps defined paths. The proc signature here's a bit long, I'm sorry
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * access - A list representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/jps_move(moving,
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
	subsystem,
	diagonal_handling,
	priority,
	flags,
	datum/extra_info,
	initial_path)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps,
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

/datum/move_loop/has_target/jps
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Max amount of steps to search
	var/max_path_length
	///Minimum distance to the target before path returns
	var/minimum_distance
	///A list representing what access we have and what doors we can open.
	var/list/access
	///Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
	var/simulated_only
	///A perticular turf to avoid
	var/turf/avoid
	///Should we skip the first step? This is the tile we're currently on, which breaks some things
	var/skip_first
	///Whether we replace diagonal movements with cardinal movements or follow through with them
	var/diagonal_handling
	///A list for the path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	///Bool used to determine if we're already making a path in JPS. this prevents us from re-pathing while we're already busy.
	var/is_pathing = FALSE
	///Callbacks to invoke once we make a path
	var/list/datum/callback/on_finish_callbacks = list()

/datum/move_loop/has_target/jps/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	. = ..()
	on_finish_callbacks += CALLBACK(src, PROC_REF(on_finish_pathing))

/datum/move_loop/has_target/jps/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/initial_path)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.minimum_distance = minimum_distance
	src.access = access
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	movement_path = initial_path?.Copy()

/datum/move_loop/has_target/jps/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, initial_path)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && access ~= src.access && simulated_only == src.simulated_only && avoid == src.avoid)
		return TRUE
	return FALSE

/datum/move_loop/has_target/jps/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/jps/loop_stopped()
	. = ..()
	movement_path = null

/datum/move_loop/has_target/jps/Destroy()
	avoid = null
	on_finish_callbacks = null
	return ..()

///Tries to calculate a new path for this moveloop.
/datum/move_loop/has_target/jps/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	if(SSpathfinder.pathfind(moving, target, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, on_finish = on_finish_callbacks))
		is_pathing = TRUE
		SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_REPATH)

///Called when a path has finished being created
/datum/move_loop/has_target/jps/proc/on_finish_pathing(list/path)
	movement_path = path
	is_pathing = FALSE
	SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_FINISHED_PATHING, path)

/datum/move_loop/has_target/jps/move()
	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		else
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
			movement_path.Cut(1,2)
	else
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE


///Base class of move_to and move_away, deals with the distance and target aspect of things
/datum/move_loop/has_target/dist_bound
	var/distance = 0

/datum/move_loop/has_target/dist_bound/setup(delay, timeout, atom/chasing, dist = 0)
	. = ..()
	if(!.)
		return
	distance = dist

/datum/move_loop/has_target/dist_bound/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, dist = 0)
	if(..() && distance == dist)
		return TRUE
	return FALSE

///Returns FALSE if the movement should pause, TRUE otherwise
/datum/move_loop/has_target/dist_bound/proc/check_dist()
	return FALSE

/datum/move_loop/has_target/dist_bound/move()
	if(!check_dist()) //If we're too close don't do the move
		return MOVELOOP_FAILURE
	return MOVELOOP_SUCCESS


/**
 * Wrapper around walk_to()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_to(moving, chasing, min_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_to, priority, flags, extra_info, delay, timeout, chasing, min_dist)

///Wrapper around walk_to()
/datum/move_loop/has_target/dist_bound/move_to

/datum/move_loop/has_target/dist_bound/move_to/check_dist()
	return (get_dist(moving, target) > distance) //If you get too close, stop moving closer

/datum/move_loop/has_target/dist_bound/move_to/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_to(moving, target)
	moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Wrapper around walk_away()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * max_dist - the furthest away from the target we're allowed to get
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_away(moving, chasing, max_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_away, priority, flags, extra_info, delay, timeout, chasing, max_dist)

///Wrapper around walk_away()
/datum/move_loop/has_target/dist_bound/move_away

/datum/move_loop/has_target/dist_bound/move_away/check_dist()
	return (get_dist(moving, target) < distance) //If you get too far out, stop moving away

/datum/move_loop/has_target/dist_bound/move_away/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_away(moving, target)
	moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/**
 * Helper proc for the move_towards datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_towards(moving, chasing, delay, home, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards, priority, flags, extra_info, delay, timeout, chasing, home)

/**
 * Helper proc for homing onto something with move_towards
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/home_onto(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return move_towards(moving, chasing, delay, TRUE, timeout, subsystem, priority, flags, extra_info)

///Used as a alternative to walk_towards
/datum/move_loop/has_target/move_towards
	///The turf we want to move into, used for course correction
	var/turf/moving_towards
	///Should we try and stay on the path, or is deviation alright
	var/home = FALSE
	///When this gets larger then 1 we move a turf
	var/x_ticker = 0
	var/y_ticker = 0
	///The rate at which we move, between 0 and 1
	var/x_rate = 1
	var/y_rate = 1
	//We store the signs of x and y seperately, because byond will round negative numbers down
	//So doing all our operations with absolute values then multiplying them is easier
	var/x_sign = 0
	var/y_sign = 0

/datum/move_loop/has_target/move_towards/setup(delay, timeout, atom/chasing, home = FALSE)
	. = ..()
	if(!.)
		return FALSE
	src.home = home

	if(home)
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(update_slope)) //If it can move, update your slope when it does
		RegisterSignal(moving, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
	update_slope()

/datum/move_loop/has_target/move_towards/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, home = FALSE)
	if(..() && home == src.home)
		return TRUE
	return FALSE

/datum/move_loop/has_target/move_towards/Destroy()
	if(home)
		if(ismovable(target))
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		if(moving)
			UnregisterSignal(moving, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/move_loop/has_target/move_towards/move()
	//Move our tickers forward a step, we're guaranteed at least one step forward because of how the code is written
	if(x_rate) //Did you know that rounding by 0 throws a divide by 0 error?
		x_ticker = FLOOR(x_ticker + x_rate, x_rate)
	if(y_rate)
		y_ticker = FLOOR(y_ticker + y_rate, y_rate)

	var/x = moving.x
	var/y = moving.y
	var/z = moving.z

	moving_towards = locate(x + round(x_ticker) * x_sign, y + round(y_ticker) * y_sign, z)
	//The tickers serve as good methods of tracking remainder
	if(x_ticker >= 1)
		x_ticker = MODULUS(x_ticker, 1) //I swear to god if you somehow go up by one then one in a tick I'm gonna go mad
	if(y_ticker >= 1)
		y_ticker = MODULUS(x_ticker, 1)
	var/atom/old_loc = moving.loc
	moving.Move(moving_towards, get_dir(moving, moving_towards), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))

	//YOU FOUND THEM! GOOD JOB
	if(home && get_turf(moving) == get_turf(target))
		x_rate = 0
		y_rate = 0
		return
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/datum/move_loop/has_target/move_towards/proc/handle_move(source, atom/OldLoc, Dir, Forced = FALSE)
	SIGNAL_HANDLER
	if(moving.loc != moving_towards && home) //If we didn't go where we should have, update slope to account for the deviation
		update_slope()

/datum/move_loop/has_target/move_towards/handle_no_target()
	if(home)
		return ..()
	target = null

/**
 * Recalculates the slope between our object and the target, sets our rates to it
 *
 * The math below is reminiscent of something like y = mx + b
 * Except we don't need to care about axis, since we do all our movement in steps of 1
 * Because of that all that matters is we only move one tile at a time
 * So we take the smaller delta, divide it by the larger one, and get smaller step per large step
 * Then we set the large step to 1, and we're done. This way we're guaranteed to never move more then a tile at once
 * And we can have nice lines
**/
/datum/move_loop/has_target/move_towards/proc/update_slope()
	SIGNAL_HANDLER

	//You'll notice this is rise over run, except we flip the formula upside down depending on the larger number
	//This is so we never move more then one tile at once
	var/delta_y = target.y - moving.y
	var/delta_x = target.x - moving.x
	//It's more convienent to store delta x and y as absolute values
	//and modify them right at the end then it is to deal with rounding errors
	x_sign = (delta_x > 0) ? 1 : -1
	y_sign = (delta_y > 0) ? 1 : -1
	delta_x = abs(delta_x)
	delta_y = abs(delta_y)

	if(delta_x >= delta_y)
		if(delta_x == 0) //Just go up/down
			x_rate = 0
			y_rate = 1
			return
		x_rate = 1
		y_rate = delta_y / delta_x //rise over run, you know the deal
	else
		if(delta_y == 0) //Just go right/left
			x_rate = 1
			y_rate = 0
			return
		x_rate = delta_x / delta_y //Keep the larger step size at 1
		y_rate = 1

/**
 * Wrapper for walk_towards, not reccomended, as its movement ends up being a bit stilted
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_towards_legacy(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards_budget, priority, flags, extra_info, delay, timeout, chasing)

///The actual implementation of walk_towards()
/datum/move_loop/has_target/move_towards_budget

/datum/move_loop/has_target/move_towards_budget/move()
	var/turf/target_turf = get_step_towards(moving, target)
	var/atom/old_loc = moving.loc
	moving.Move(target_turf, get_dir(moving, target_turf), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Assigns a target to a move loop that immediately freezes for a set duration of time.
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * halted_turf - The turf we want to freeze on. This should typically be the loc of moving.
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. This should be considered extremely non-optional as it will completely stun out the movement loop <i>forever</i> if unset.
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 */
/datum/move_manager/proc/freeze(moving, halted_turf, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/freeze, priority, flags, extra_info, delay, timeout, halted_turf)

/// As close as you can get to a "do-nothing" move loop, the pure intention of this is to absolutely resist all and any automated movement until the move loop times out.
/datum/move_loop/freeze

/datum/move_loop/freeze/move()
	return MOVELOOP_SUCCESS // it's successful because it's not moving. we autoclear outselves when `timeout` is reached

/**
 * Helper proc for the move_rand datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * directions - A list of acceptable directions to try and move in. Defaults to GLOB.alldirs
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_rand(moving, directions, delay, timeout, subsystem, priority, flags, datum/extra_info)
	if(!directions)
		directions = GLOB.alldirs
	return add_to_loop(moving, subsystem, /datum/move_loop/move_rand, priority, flags, extra_info, delay, timeout, directions)

/**
 * This isn't actually the same as walk_rand
 * Because walk_rand is really more like walk_to_rand
 * It appears to pick a spot outside of range, and move towards it, then pick a new spot, etc.
 * I can't actually replicate this on our side, because of how bad our pathfinding is, and cause I'm not totally sure I know what it's doing.
 * I can just implement a random-walk though
**/
/datum/move_loop/move_rand
	var/list/potential_directions

/datum/move_loop/move_rand/setup(delay, timeout, list/directions)
	. = ..()
	if(!.)
		return
	potential_directions = directions

/datum/move_loop/move_rand/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, list/directions)
	if(..() && (length(potential_directions | directions) == length(potential_directions))) //i guess this could be useful if actually it really has yet to move
		return MOVELOOP_SUCCESS
	return MOVELOOP_FAILURE

/datum/move_loop/move_rand/move()
	var/list/potential_dirs = potential_directions.Copy()
	while(potential_dirs.len)
		var/testdir = pick(potential_dirs)
		var/turf/moving_towards = get_step(moving, testdir)
		var/atom/old_loc = moving.loc
		moving.Move(moving_towards, testdir, FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
		if(old_loc != moving?.loc)  //If it worked, we're done
			return MOVELOOP_SUCCESS
		potential_dirs -= testdir
	return MOVELOOP_FAILURE

/**
 * Wrapper around walk_rand(), doesn't actually result in a random walk, it's more like moving to random places in viewish
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_to_rand(moving, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move_to_rand, priority, flags, extra_info, delay, timeout)

///Wrapper around step_rand
/datum/move_loop/move_to_rand

/datum/move_loop/move_to_rand/move()
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_rand(moving)
	moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Snowflake disposal movement. Moves a disposal holder along a chain of disposal pipes
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/move_disposals(moving, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/disposal_holder, priority, flags, extra_info, delay, timeout)

/// Disposal holders need to move through a chain of pipes
/// Rather then through the world. This supports this
/// If this ever changes, get rid of this, add drift component like logic to the holder
/// And move them to move()
/datum/move_loop/disposal_holder

/datum/move_loop/disposal_holder/setup(delay = 1, timeout = INFINITY)
	// This is a horrible pattern.
	// Move loops should almost never need to be one offs. Please don't do this if you can help it
	if(!istype(moving, /obj/structure/disposalholder))
		stack_trace("You tried to make a [moving.type] object move like a disposals holder, stop that!")
		return FALSE
	return ..()

/datum/move_loop/disposal_holder/move()
	var/obj/structure/disposalholder/holder = moving
	if(!holder.current_pipe)
		return FALSE
	var/atom/old_loc = moving.loc
	holder.current_pipe = holder.current_pipe.transfer(holder)
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/**
 * Helper proc for the smooth_move datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * angle - Angle at which we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/

/datum/move_manager/proc/smooth_move(moving, angle, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/smooth_move, priority, flags, extra_info, delay, timeout, angle)

/datum/move_loop/smooth_move
	/// Angle at which we move. 0 is north because byond.
	var/angle = 0
	/// When this gets bigger than 1, we move a turf
	var/x_ticker = 0
	var/y_ticker = 0
	/// The rate at which we move, between 0 and 1. Cached to cut down on trig
	var/x_rate = 0
	var/y_rate = 1
	/// Sign for our movement
	var/x_sign = 1
	var/y_sign = 1
	/// Actual move delay, as delay will be modified by move() depending on what direction we move in
	var/saved_delay

/datum/move_loop/smooth_move/setup(delay, timeout, angle)
	. = ..()
	if(!.)
		return FALSE
	set_angle(angle)
	saved_delay = delay

/datum/move_loop/smooth_move/set_delay(new_delay)
	new_delay = round(new_delay, world.tick_lag)
	. = ..()
	saved_delay = delay

/datum/move_loop/smooth_move/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, home = FALSE)
	if(..() && angle == src.angle)
		return TRUE
	return FALSE

/datum/move_loop/smooth_move/move()
	var/atom/old_loc = moving.loc
	// Defaulting to 2 because if one rate is 0 the other is guaranteed to be 1, so maxing out at 1 to_move
	var/x_to_move = x_rate > 0 ? (1 - x_ticker) / x_rate : 2
	var/y_to_move = y_rate > 0 ? (1 - y_ticker) / y_rate : 2
	var/move_dist = min(x_to_move, y_to_move)
	x_ticker += x_rate * move_dist
	y_ticker += y_rate * move_dist

	// Per Bresenham's, if we are closer to the next tile's center move diagonally. Checked by seeing if we pass into the next tile after moving another half a tile
	var/move_x = (x_ticker + x_rate * 0.5) > 1
	var/move_y = (y_ticker + y_rate * 0.5) > 1
	if (move_x)
		x_ticker = 0
	if (move_y)
		y_ticker = 0

	var/turf/next_turf = locate(moving.x + (move_x ? x_sign : 0), moving.y + (move_y ? y_sign : 0), moving.z)
	moving.Move(next_turf, get_dir(moving, next_turf), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))

	if (old_loc == moving?.loc)
		return MOVELOOP_FAILURE

	delay = saved_delay
	if (move_x && move_y)
		delay *= 1.4

	return MOVELOOP_SUCCESS

/datum/move_loop/smooth_move/proc/set_angle(new_angle)
	angle = new_angle
	x_rate = sin(angle)
	y_rate = cos(angle)
	x_sign = SIGN(x_rate)
	y_sign = SIGN(y_rate)
	x_rate = abs(x_rate)
	y_rate = abs(y_rate)
	x_ticker = 0
	y_ticker = 0
