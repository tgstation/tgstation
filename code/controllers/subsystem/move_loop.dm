SUBSYSTEM_DEF(movement_loop)
	name = "Movement Loop"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 1 //Fire each tick
	///The list of datums we're processing
	var/list/processing = list()
	///Used to make pausing possible
	var/list/currentrun = list()
	///An assoc list of source to movement datum, used for lookups and removal
	var/list/lookup = list()

/**
 * Adds an object to the subsystem,
 *
 * Arguments:
 * looptype - What sort of loop do we want to make
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * moving - The atom we want to move
 * delay - How many seconds to wait between fires, defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires, defaults to INFINITY
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/start_looping(looptype, override = TRUE, atom/moving, delay = 0.1, timeout = INFINITY)
	PRIVATE_PROC(TRUE)
	var/datum/move_loop/old = lookup[moving]
	if(old)
		if(!override)
			return FALSE
		remove_from_loop(moving, old) //Kill it

	//Kill me
	var/datum/move_loop/loop = new looptype()
	processing += loop
	currentrun += loop
	lookup[moving] = loop //Cache the datum so lookups are cheap
	var/list/arguments = args.Copy(3) //Send all the arguments past override to the new datum
	return loop.setup(arglist(arguments))

///Stops an object from being processed, assuming it is being processed
/datum/controller/subsystem/movement_loop/proc/stop_looping(atom/moving)
	var/datum/loop = lookup[moving]
	if(loop)
		remove_from_loop(moving, lookup[moving])
		return TRUE
	return FALSE

///Removes a loop from processing based on the moving and the loop itself
/datum/controller/subsystem/movement_loop/proc/remove_from_loop(atom/moving, datum/move_loop/loop)
	processing -= loop
	currentrun -= loop
	lookup -= moving
	qdel(loop)

/datum/controller/subsystem/movement_loop/fire(resumed)
	if(!resumed)
		currentrun = processing.Copy()

	var/list/running = currentrun //Cache for... you've heard this before
	while(running.len)
		var/datum/move_loop/loop = running[running.len]
		running.len--
		loop.process(wait * 0.1) //This shouldn't get nulls, if it does, runtime
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/movement_loop/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()

/**
 * Replacement for walk()
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move(moving, direction, delay, timeout, override)
	return start_looping(/datum/move_loop/move, override, moving, delay, timeout, direction)

/**
 * Used for force-move loops, similar to move_towards_legacy() but not quite the same
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/force_move(moving, chasing, delay, timeout, override)
	return start_looping(/datum/move_loop/has_target/force_move, override, moving, delay, timeout, chasing)

/**
 * Wrapper around walk_to()
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_to(moving, chasing, min_dist, delay, timeout, override)
	return start_looping(/datum/move_loop/has_target/dist_bound/move_to, override, moving, delay, timeout, chasing, min_dist)

/**
 * Wrapper around walk_away()
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * max_dist - the furthest away from the target we're allowed to get
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_away(moving, chasing, max_dist, delay, timeout, override)
	return start_looping(/datum/move_loop/has_target/dist_bound/move_away, override, moving, delay, timeout, chasing, max_dist)

/**
 * Helper proc for the move_towards datum
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in seconds until the moveloop self expires. Defaults to INFINITY
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_towards(moving, chasing, delay, home, timeout, override)
	return start_looping(/datum/move_loop/has_target/move_towards, override, moving, delay, timeout, chasing, home)

///Helper proc for homing
/datum/controller/subsystem/movement_loop/proc/home_onto(moving, chasing, delay, timeout, override)
	return move_towards(moving, chasing, delay, TRUE, timeout, override)

/**
 * Wrapper for walk_towards, not reccomended, as it's movement ends up being a bit stilted
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_towards_legacy(moving, chasing, delay, timeout, override)
	return start_looping(/datum/move_loop/has_target/move_towards_budget, override, moving, delay, timeout, chasing)

/**
 * Helper proc for the move_rand datum
 *
 * Arguments:
 * moving - The atom we want to move
 * directions - A list of acceptable directions to try and move in. Defaults to GLOB.alldirs
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_rand(moving, directions, delay, timeout, override)
	if(!directions)
		directions = GLOB.alldirs
	return start_looping(/datum/move_loop/move_rand, override, moving, delay, timeout, directions)

/**
 * Wrapper around walk_rand(), doesn't actually result in a random walk, it's more like moving to random places in viewish
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in seconds until the moveloop self expires. Defaults to infinity
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement_loop/proc/move_to_rand(moving, delay, timeout, override)
	return start_looping(/datum/move_loop/move_to_rand, override, moving, delay, timeout)

///Template class of the walk() replacements, handles the timing portion of the loops
/datum/move_loop
	///The thing we're moving about
	var/atom/movable/moving
	///Lifetime in seconds, defaults to forever
	var/lifetime = INFINITY
	///Delay between each move in seconds
	var/delay = 0.1
	///We use this to track the delay between movements
	var/timer = 0
	///The last tick we processed
	var/lasttick = 0

/datum/move_loop/proc/setup(atom/moving, delay = 0.1, timeout = INFINITY)
	if(!ismovable(moving))
		handle_delete()
		return FALSE

	src.moving = moving
	src.delay = delay
	lifetime = timeout

	RegisterSignal(moving, COMSIG_PARENT_QDELETING, .proc/handle_delete)
	return TRUE

/datum/move_loop/Destroy()
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(moving, COMSIG_PARENT_QDELETING)
	if(!QDELETED(moving))
		SEND_SIGNAL(moving, COMSIG_MOVELOOP_END)
	return ..()

/datum/move_loop/proc/handle_delete()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	SSmovement_loop.remove_from_loop(moving, src)

/datum/move_loop/process(delta_time)
	timer = round(timer + delta_time, 0.1) //Round up due to floating point shit
	if(timer >= lifetime)
		handle_delete()
		return
	if(round(timer - delay, 0.1) < lasttick)
		return
	if(SEND_SIGNAL(moving, COMSIG_MOVELOOP_PROCESS_CHECK) & MOVELOOP_STOP_PROCESSING) //Chance for the object to react
		return

	lasttick = timer
	move()

///Handles the actual move, overriden by children
/datum/move_loop/proc/move()
	return

///Replacement for walk()
/datum/move_loop/move
	var/direction

/datum/move_loop/move/setup(atom/moving, delay, timeout, dir)
	. = ..()
	if(!.)
		return
	direction = dir

/datum/move_loop/move/move()
	moving.Move(get_step(moving, direction), direction)


/datum/move_loop/has_target
	///The thing we're moving in relation to, either at or away from
	var/atom/target

/datum/move_loop/has_target/setup(atom/moving, delay, timeout, atom/chasing)
	. = ..()
	if(!.)
		return
	if(!isatom(chasing))
		handle_delete()
		return FALSE

	target = chasing

	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/handle_no_target) //Don't do this for turfs, because of reasons


/datum/move_loop/has_target/Destroy()
	if(!isturf(target))
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	return ..()

/datum/move_loop/has_target/proc/handle_no_target()
	SIGNAL_HANDLER
	handle_delete()

///Used for force-move loops
/datum/move_loop/has_target/force_move

/datum/move_loop/has_target/force_move/move()
	moving.forceMove(get_step(moving, get_dir(moving, target)))

///Base class of move_to and move_away, deals with the distance and target aspect of things
/datum/move_loop/has_target/dist_bound
	var/distance = 0

/datum/move_loop/has_target/dist_bound/setup(atom/moving, delay, timeout, atom/chasing, dist = 0)
	. = ..()
	if(!.)
		return
	distance = dist


/datum/move_loop/has_target/dist_bound/proc/check_dist()
	return (get_dist(moving, target) >= distance) //If you get too close, stop moving closer

/datum/move_loop/has_target/dist_bound/move()
	if(!check_dist()) //If we're too close don't do the move
		lasttick = round(lasttick - delay, 0.1) //Make sure to move as soon as possible
		return FALSE
	return TRUE

///Wrapper around walk_to()
/datum/move_loop/has_target/dist_bound/move_to

/datum/move_loop/has_target/dist_bound/move_to/check_dist()
	return (get_dist(moving, target) >= distance) //If you get too close, stop moving

/datum/move_loop/has_target/dist_bound/move_to/move()
	. = ..()
	if(!.)
		return
	step_to(moving, target)

///Wrapper around walk_away()
/datum/move_loop/has_target/dist_bound/move_away

/datum/move_loop/has_target/dist_bound/move_away/check_dist()
	return (get_dist(moving, target) <= distance) //If you get too far out, stop moving away

/datum/move_loop/has_target/dist_bound/move_away/move()
	. = ..()
	if(!.)
		return
	step_away(moving, target)

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

/datum/move_loop/has_target/move_towards/setup(atom/moving, delay, timeout, atom/chasing, home = FALSE)
	. = ..()
	if(!.)
		return FALSE
	src.home = home
	update_slope()

	if(home)
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/update_slope) //If it can move, update your slope when it does
		RegisterSignal(moving, COMSIG_MOVABLE_MOVED, .proc/handle_move)


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
	moving.Move(moving_towards, get_dir(moving, moving_towards))

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

///The actual implementation of walk_towards()
/datum/move_loop/has_target/move_towards_budget

/datum/move_loop/has_target/move_towards_budget/move()
	var/dir = get_dir(moving, target)
	moving.Move(get_step(moving, dir), dir)

/**
 * This isn't actually the same as walk_rand
 * Because walk_rand is really more like walk_to_rand
 * It appears to pick a spot outside of range, and move towards it, then pick a new spot, etc.
 * I can't actually replicate this on our side, because of how bad our pathfinding is, and cause I'm not totally sure I know what it's doing.
 * I can just implement a random-walk though
**/
/datum/move_loop/move_rand
	var/list/potential_directions

/datum/move_loop/move_rand/setup(atom/moving, delay, timeout, list/directions)
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
			break
		potential_dirs -= testdir

///Wrapper around step_rand
/datum/move_loop/move_to_rand

/datum/move_loop/move_to_rand/move()
	step_rand(moving)
