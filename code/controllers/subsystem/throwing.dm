#define MAX_THROWING_DIST 1280 // 5 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"
	priority = FIRE_PRIORITY_THROWING
	wait = 1
	flags = SS_NO_INIT|SS_KEEP_TIMING|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun
	var/list/processing = list()

/datum/controller/subsystem/throwing/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()


/datum/controller/subsystem/throwing/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[currentrun.len]
		var/datum/thrownthing/TT = currentrun[AM]
		currentrun.len--
		if (QDELETED(AM) || QDELETED(TT))
			processing -= AM
			if (MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if (MC_TICK_CHECK)
			return

	currentrun = null

/datum/thrownthing
	var/atom/movable/thrownthing
	var/datum/weakref/initial_target
	var/turf/target_turf
	var/target_zone
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/diagonals_first
	var/dist_travelled = 0
	var/start_time
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/force = MOVE_FORCE_DEFAULT
	var/gentle = FALSE
	var/pure_diagonal
	var/diagonal_error
	var/datum/callback/callback
	var/paused = FALSE
	var/delayed_time = 0
	var/last_move = 0


/datum/thrownthing/New(thrownthing, target, init_dir, maxrange, speed, thrower, diagonals_first, force, gentle, callback, target_zone)
	. = ..()
	src.thrownthing = thrownthing
	RegisterSignal(thrownthing, COMSIG_PARENT_QDELETING, .proc/on_thrownthing_qdel)
	src.target_turf = get_turf(target)
	if(target_turf != target)
		src.initial_target = WEAKREF(target)
	src.init_dir = init_dir
	src.maxrange = maxrange
	src.speed = speed
	src.thrower = thrower
	src.diagonals_first = diagonals_first
	src.force = force
	src.gentle = gentle
	src.callback = callback
	src.target_zone = target_zone


/datum/thrownthing/Destroy()
	SSthrowing.processing -= thrownthing
	SSthrowing.currentrun -= thrownthing
	thrownthing.throwing = null
	thrownthing = null
	thrower = null
	initial_target = null
	if(callback)
		QDEL_NULL(callback) //It stores a reference to the thrownthing, its source. Let's clean that.
	return ..()


///Defines the datum behavior on the thrownthing's qdeletion event.
/datum/thrownthing/proc/on_thrownthing_qdel(atom/movable/source, force)
	SIGNAL_HANDLER

	qdel(src)


/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if (!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if(paused)
		delayed_time += world.time - last_move
		return

	var/atom/movable/actual_target = initial_target?.resolve()

	if(dist_travelled) //to catch sneaky things moving on our tile while we slept
		for(var/atom/movable/obstacle as anything in get_turf(thrownthing))
			if (obstacle == thrownthing || (obstacle == thrower && !ismob(thrownthing)))
				continue
			if(obstacle.pass_flags_self & LETPASSTHROW)
				continue
			if (obstacle == actual_target || (obstacle.density && !(obstacle.flags_1 & ON_BORDER_1)))
				finalize(TRUE, obstacle)
				return

	var/atom/step

	last_move = world.time

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = CEILING(min(((((world.time+world.tick_lag) - start_time + delayed_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed*MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait), 1)
	while (tilestomove-- > 0)
		if ((dist_travelled >= maxrange || AM.loc == target_turf) && AM.has_gravity(AM.loc))
			finalize()
			return

		if (dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if (!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if (diagonal_error >= 0 && max(dist_x,dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x/2 : -dist_y

		if (!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finalize()
			return

		if(!AM.Move(step, get_dir(AM, step), DELAY_TO_GLIDE_SIZE(1 / speed))) // we hit something during our move...
			if(AM.throwing) // ...but finalize() wasn't called on Bump() because of a higher level definition that doesn't always call parent.
				finalize()
			return

		dist_travelled++

		if(actual_target && !(actual_target.pass_flags_self & LETPASSTHROW) && actual_target.loc == AM.loc) // we crossed a movable with no density (e.g. a mouse or APC) we intend to hit anyway.
			finalize(TRUE, actual_target)
			return

		if (dist_travelled > MAX_THROWING_DIST)
			finalize()
			return

/datum/thrownthing/proc/finalize(hit = FALSE, target=null)
	set waitfor = FALSE
	//done throwing, either because it hit something or it finished moving
	if(!thrownthing)
		return
	thrownthing.throwing = null
	if (!hit)
		for (var/atom/movable/obstacle as anything in get_turf(thrownthing)) //looking for our target on the turf we land on.
			if (obstacle == target)
				hit = TRUE
				thrownthing.throw_impact(obstacle, src)
				if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
					return //deletion should already be handled by on_thrownthing_qdel()
				break
		if (!hit)
			thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.
			if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
				return //deletion should already be handled by on_thrownthing_qdel()
			thrownthing.newtonian_move(init_dir)
	else
		thrownthing.newtonian_move(init_dir)

	if(target)
		thrownthing.throw_impact(target, src)
		if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
			return //deletion should already be handled by on_thrownthing_qdel()

	if (callback)
		callback.Invoke()

	if(!thrownthing.currently_z_moving) // I don't think you can zfall while thrown but hey, just in case.
		var/turf/T = get_turf(thrownthing)
		T?.zFall(thrownthing)

	if(thrownthing)
		SEND_SIGNAL(thrownthing, COMSIG_MOVABLE_THROW_LANDED, src)

	qdel(src)
