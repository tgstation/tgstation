///Template class of the movement datums, handles the timing portion of the loops
/datum/move_loop
	///The movement packet that owns us
	var/datum/movement_packet/owner
	///The subsystem we're processing on
	var/datum/controller/subsystem/movement/controller
	///The thing we're moving about
	var/atom/movable/moving
	///Different flags that apply to the loop
	var/flags = NONE
	///Defines how different move loops override each other. Lower numbers beat higher numbers
	var/precedence = MOVEMENT_DEFAULT_PRECEDENCE
	///Time till we stop processing in deci-seconds, defaults to forever
	var/lifetime = INFINITY
	///Delay between each move in deci-seconds
	var/delay = 1
	///The next time we should process
	var/timer = 0

/datum/move_loop/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, flags, precedence, precedence)
	src.owner = owner
	src.controller = controller
	src.moving = moving
	src.flags = flags
	src.precedence = precedence
	RegisterSignal(moving, COMSIG_PARENT_QDELETING, .proc/nuke_loop)

/datum/move_loop/proc/setup(delay = 1, timeout = INFINITY)
	if(!ismovable(moving) || !owner)
		return FALSE

	src.delay = max(delay, 1) //Please...
	src.lifetime = timeout
	return TRUE

/datum/move_loop/proc/start_loop()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_START)
	src.timer = world.time + delay

/datum/move_loop/proc/stop_loop()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_STOP)

/datum/move_loop/Destroy()
	if(owner)
		owner.remove_loop(controller, src)
		owner = null
	moving = null
	controller = null
	return ..()

/datum/move_loop/proc/nuke_loop()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	qdel(src)

/datum/move_loop/process(delta_ticks)
	if(SEND_SIGNAL(src, COMSIG_MOVELOOP_PREPROCESS_CHECK) & MOVELOOP_STOP_PROCESSING) //Chance for the object to react
		qdel(src)
		return

	lifetime -= delay //This needs to be based on work over time, not just time passed
	if(lifetime <= 0) //Otherwise lag would make things look really weird
		nuke_loop()
		return

	var/visual_delay = max((world.time - timer) / delay, 1)
	timer = world.time + delay
	var/success = move()
	if(QDELETED(src)) //Can happen
		return

	if(success)
		moving.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, visual_delay))
	SEND_SIGNAL(src, COMSIG_MOVELOOP_POSTPROCESS, success, delay * visual_delay)

///Handles the actual move, overriden by children
///Returns FALSE if nothing happen, TRUE otherwise
/datum/move_loop/proc/move()
	return FALSE


/proc/stop_looping(atom/moving, subsystem)
	SSmove_manager.remove_from_subsystem(subsystem)

/**
 * Replacement for walk()
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move(moving, direction, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/move, override, flags, precedence, delay, timeout, direction)

///Replacement for walk()
/datum/move_loop/move
	var/direction

/datum/move_loop/move/setup(delay, timeout, dir)
	. = ..()
	if(!.)
		return
	direction = dir

/datum/move_loop/move/move()
	. = moving.Move(get_step(moving, direction), direction)

/datum/move_loop/has_target
	///The thing we're moving in relation to, either at or away from
	var/atom/target

/datum/move_loop/has_target/setup(delay, timeout, atom/chasing)
	. = ..()
	if(!.)
		return
	if(!isatom(chasing))
		nuke_loop()
		return FALSE

	target = chasing

	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/handle_no_target) //Don't do this for turfs, because of reasons

/datum/move_loop/has_target/Destroy()
	if(!isturf(target) && target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	return ..()

/datum/move_loop/has_target/proc/handle_no_target()
	SIGNAL_HANDLER
	nuke_loop()


/**
 * Used for force-move loops, similar to move_towards_legacy() but not quite the same
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/force_move(moving, chasing, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/has_target/force_move, override, flags, precedence, delay, timeout, chasing)

///Used for force-move loops
/datum/move_loop/has_target/force_move

/datum/move_loop/has_target/force_move/move()
	return moving.forceMove(get_step(moving, get_dir(moving, target)))


///Base class of move_to and move_away, deals with the distance and target aspect of things
/datum/move_loop/has_target/dist_bound
	var/distance = 0

/datum/move_loop/has_target/dist_bound/setup(delay, timeout, atom/chasing, dist = 0)
	. = ..()
	if(!.)
		return
	distance = dist

///Returns FALSE if the movement should pause, TRUE otherwise
/datum/move_loop/has_target/dist_bound/proc/check_dist()
	return FALSE

/datum/move_loop/has_target/dist_bound/move()
	if(!check_dist()) //If we're too close don't do the move
		timer = world.time //Make sure to move as soon as possible
		return FALSE
	return TRUE


/**
 * Wrapper around walk_to()
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_to(moving, chasing, min_dist, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_to, override, flags, precedence, delay, timeout, chasing, min_dist)

///Wrapper around walk_to()
/datum/move_loop/has_target/dist_bound/move_to

/datum/move_loop/has_target/dist_bound/move_to/check_dist()
	return (get_dist(moving, target) >= distance) //If you get too close, stop moving closer

/datum/move_loop/has_target/dist_bound/move_to/move()
	. = ..()
	if(!.)
		return
	return step_to(moving, target)


/**
 * Wrapper around walk_away()
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * max_dist - the furthest away from the target we're allowed to get
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_away(moving, chasing, max_dist, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_away, override, flags, precedence, delay, timeout, chasing, max_dist)

///Wrapper around walk_away()
/datum/move_loop/has_target/dist_bound/move_away

/datum/move_loop/has_target/dist_bound/move_away/check_dist()
	return (get_dist(moving, target) <= distance) //If you get too far out, stop moving away

/datum/move_loop/has_target/dist_bound/move_away/move()
	. = ..()
	if(!.)
		return
	return step_away(moving, target)


/**
 * Helper proc for the move_towards datum
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_towards(moving, chasing, delay, home, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards, override, flags, precedence, delay, timeout, chasing, home)

///Helper proc for homing
/proc/home_onto(moving, chasing, delay, timeout, override)
	return move_towards(moving, chasing, delay, TRUE, timeout, override)

///Used as a alternative to walk_towards
/datum/move_loop/has_target/move_towards
	///The turf we want to move into, used for course correction
	var/turf/moving_towards
	///Should we try and stay on the path, or is deviation alright
	var/home = FALSE
	///When this gets larger then 1 or smaller then -1 we move a turf
	var/x_ticker = 0
	var/y_ticker = 0
	///The rate at which we move, between -1 and 1
	var/x_rate = 1
	var/y_rate = 1

/datum/move_loop/has_target/move_towards/setup(delay, timeout, atom/chasing, home = FALSE)
	. = ..()
	if(!.)
		return FALSE
	src.home = home

	if(home)
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/update_slope) //If it can move, update your slope when it does
		RegisterSignal(moving, COMSIG_MOVABLE_MOVED, .proc/handle_move)

/datum/move_loop/has_target/move_towards/start_loop()
	update_slope()
	return ..()

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
		x_ticker = round(x_ticker + x_rate, x_rate)
	if(y_rate)
		y_ticker = round(y_ticker + y_rate, y_rate)

	var/x = moving.x
	var/y = moving.y
	var/z = moving.z

	moving_towards = locate(x + round(x_ticker), y + round(y_ticker), z)
	//The tickers serve as good methods of tracking remainder
	if(abs(x_ticker) >= 1)
		x_ticker -= (x_ticker > 0) ? 1 : -1
	if(abs(y_ticker) >= 1)
		y_ticker -= (y_ticker > 0) ? 1 : -1
	return moving.Move(moving_towards, get_dir(moving, moving_towards))

/datum/move_loop/has_target/move_towards/proc/handle_move(source, atom/OldLoc, Dir, Forced = FALSE)
	SIGNAL_HANDLER
	if(moving.loc != moving_towards) //If we didn't go where we should have, update slope to account for the deviation
		update_slope()

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
	//This is so we never move more then once tile at once
	var/delta_y = target.y - moving.y
	var/delta_x = target.x - moving.x
	if(abs(delta_x) >= abs(delta_y))
		if(delta_x == 0) //Just go up/down
			x_rate = 0
			y_rate = (delta_y > 0) ? 1 : -1
			return
		x_rate = (delta_x > 0) ? 1 : -1
		y_rate = delta_y / abs(delta_x) //rise over run, you know the deal
	else
		if(delta_y == 0) //Just go right/left
			y_rate = 0
			x_rate = (delta_x > 0) ? 1 : -1
			return
		y_rate = (delta_y > 0) ? 1 : -1
		x_rate = delta_x / abs(delta_y) //Keep the larger step size at 1


/**
 * Wrapper for walk_towards, not reccomended, as it's movement ends up being a bit stilted
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_towards_legacy(moving, chasing, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards_budget, override, flags, precedence, delay, timeout, chasing)

///The actual implementation of walk_towards()
/datum/move_loop/has_target/move_towards_budget

/datum/move_loop/has_target/move_towards_budget/move()
	var/dir = get_dir(moving, target)
	return moving.Move(get_step(moving, dir), dir)


/**
 * Helper proc for the move_rand datum
 *
 * Arguments:
 * moving - The atom we want to move
 * directions - A list of acceptable directions to try and move in. Defaults to GLOB.alldirs
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_rand(moving, directions, delay, timeout, override, subsystem, flags, precedence)
	if(!directions)
		directions = GLOB.alldirs
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/move_rand, override, flags, precedence, delay, timeout, directions)

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

/datum/move_loop/move_rand/move()
	var/list/potential_dirs = potential_directions.Copy()
	while(potential_dirs.len)
		var/testdir = pick(potential_dirs)
		var/turf/moving_towards = get_step(moving, testdir)
		if(moving.Move(moving_towards, testdir)) //If it worked, we're done
			return TRUE
		potential_dirs -= testdir
	return FALSE

/**
 * Wrapper around walk_rand(), doesn't actually result in a random walk, it's more like moving to random places in viewish
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one datum may run on any one subsystem at once
 * flags - Different toggles that effect the loop datum. See _DEFINES/movement.dm
 * precedence - Defines how different move loops override each other. Lower numbers beat higher numbers. Defaults to MOVEMENT_DEFAULT_PRECEDENCE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/proc/move_to_rand(moving, delay, timeout, override, subsystem, flags, precedence)
	return SSmove_manager.add_to_loop(moving, subsystem, /datum/move_loop/move_to_rand, override, flags, precedence, delay, timeout)

///Wrapper around step_rand
/datum/move_loop/move_to_rand

/datum/move_loop/move_to_rand/move()
	return step_rand(moving)
