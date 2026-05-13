///Component that handles drifting
///Manages a movement loop that actually does the legwork of moving someone
///Alongside dealing with the post movement input blocking required to make things look nice
/datum/drift_handler
	var/atom/movable/parent
	var/old_dir
	var/datum/move_loop/smooth_move/drifting_loop
	///Should we ignore the next glide rate input we get?
	///This is to some extent a hack around the order of operations
	///Around COMSIG_MOVELOOP_POSTPROCESS. I'm sorry lad
	var/ignore_next_glide = FALSE
	///Have we been delayed? IE: active, but not working right this second?
	var/delayed = FALSE
	var/block_inputs_until
	/// How much force is behind this drift.
	var/drift_force = 1

/// Accepts three args. The direction to drift in, if the drift is instant or not, and if it's not instant, the delay on the start
/datum/drift_handler/New(atom/movable/parent, inertia_angle, instant = FALSE, start_delay = 0, drift_force = 1)
	. = ..()
	src.parent = parent
	parent.drift_handler = src
	var/flags = MOVEMENT_LOOP_OUTSIDE_CONTROL
	if(instant)
		flags |= MOVEMENT_LOOP_START_INSTANT
	src.drift_force = drift_force
	drifting_loop = GLOB.move_manager.smooth_move(
		moving = parent,
		angle = inertia_angle,
		delay = get_loop_delay(parent),
		subsystem = SSnewtonian_movement,
		priority = MOVEMENT_SPACE_PRIORITY,
		flags = flags,
	)

	if(!drifting_loop)
		qdel(src)
		return

	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_START, PROC_REF(drifting_start))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_STOP, PROC_REF(drifting_stop))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(before_move))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(after_move))
	RegisterSignal(drifting_loop, COMSIG_QDELETING, PROC_REF(loop_death))
	if(drifting_loop.status & MOVELOOP_STATUS_RUNNING)
		drifting_start(drifting_loop) // There's a good chance it'll autostart, gotta catch that

	var/visual_delay = get_loop_delay(parent)

	// Start delay is essentially a more granular version of instant
	// Isn't used in the standard case, just for things that have odd wants
	if(!instant && start_delay)
		drifting_loop.pause_for(start_delay)
		visual_delay = start_delay

	apply_initial_visuals(visual_delay)
	// Fire the engines!
	if (drifting_loop.timer <= world.time)
		SSnewtonian_movement.fire_moveloop(drifting_loop)

/datum/drift_handler/Destroy()
	if(!QDELETED(drifting_loop))
		qdel(drifting_loop)
	drifting_loop = null
	parent.inertia_moving = FALSE
	parent.drift_handler = null
	return ..()

/datum/drift_handler/proc/apply_initial_visuals(visual_delay)
	// If something "somewhere" doesn't want us to apply our glidesize delays, don't
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT) & DRIFT_VISUAL_FAILED)
		return

	// Ignore the next glide because it's literally just us
	ignore_next_glide = TRUE
	parent.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSnewtonian_movement.visual_delay))
	if(!ismob(parent))
		return
	var/mob/mob_parent = parent
	//Ok this is slightly weird, but basically, we need to force the client to glide at our rate
	//Make sure moving into a space move looks like a space move essentially
	//There is an inbuilt assumption that gliding will be added as a part of a move call, but eh
	//It's ok if it's not, it's just important if it is.
	mob_parent.client?.visual_delay = MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSnewtonian_movement.visual_delay)

/**
 * An impulse is being applied to this existing drift, react accordingly
 *
 * * inertia_angle - angle of the new impulse
 * * start_delay - if the new impulse has a delay before it starts, this is it
 * * additional_force - how much force the new impulse has
 * force is not added onto additional force, it will either override it entirely (if larger or a different direction) or be ignored (if smaller and same direction)
 * controlled_cap - the maximum amount of force this impulse can apply, regardless of input
 * force_loop - should we force the loop to fire immediately to react to this change, or wait for the next visual tick?
 * Generally, if the new impulse has a start delay, you should wait, otherwise it'll look really jank
 *
 * Return FALSE if the loop becomes invalid and should be replaced
 * Return TRUE if the loop is still valid and should be kept
 */
/datum/drift_handler/proc/newtonian_impulse(inertia_angle, start_delay, additional_force, controlled_cap = INERTIA_FORCE_CAP, force_loop = TRUE)
	// We've been told to move in the middle of deletion process, tell parent to create a new handler instead
	if(!drifting_loop)
		qdel(src)
		return FALSE

	var/new_force = clamp(additional_force / parent.inertia_force_weight, 0, controlled_cap)
	if(new_force < drift_force && drifting_loop.angle == inertia_angle) // If we're already moving faster in this direction, don't change anything
		return TRUE

	drift_force = new_force
	if(drift_force < 0.1) // Rounding issues
		qdel(src)
		return TRUE

	drifting_loop.set_angle(inertia_angle)
	drifting_loop.set_delay(get_loop_delay(parent))
	// We have to forcefully fire it here to avoid stuttering in case of server lag
	if (drifting_loop.timer <= world.time && force_loop)
		SSnewtonian_movement.fire_moveloop(drifting_loop)
	return TRUE

/datum/drift_handler/proc/drifting_start()
	SIGNAL_HANDLER
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
	// We will use glide size to intuit how long to delay our loop's next move for
	// This way you can't ride two movements at once while drifting, since that'd be dumb as fuck
	RegisterSignal(parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(handle_glidesize_update))
	// If you stop pulling something mid drift, I want it to retain that momentum
	RegisterSignal(parent, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(stopped_pulling))

/datum/drift_handler/proc/drifting_stop()
	SIGNAL_HANDLER
	parent.inertia_moving = FALSE
	ignore_next_glide = FALSE
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, COMSIG_ATOM_NO_LONGER_PULLING))

/datum/drift_handler/proc/before_move(datum/source)
	SIGNAL_HANDLER
	parent.inertia_moving = TRUE
	old_dir = parent.dir
	delayed = FALSE

/datum/drift_handler/proc/after_move(datum/source, result, visual_delay)
	SIGNAL_HANDLER
	if(result == MOVELOOP_FAILURE)
		qdel(src)
		return

	parent.setDir(old_dir)
	parent.inertia_moving = FALSE
	if(parent.Process_Spacemove(angle2dir(drifting_loop.angle), continuous_move = TRUE))
		glide_to_halt(visual_delay)
		return

	ignore_next_glide = TRUE

/datum/drift_handler/proc/loop_death(datum/source)
	SIGNAL_HANDLER
	drifting_loop = null

/datum/drift_handler/proc/handle_move(datum/source, old_loc)
	SIGNAL_HANDLER
	// This can happen, because signals once sent cannot be stopped
	if(QDELETED(src))
		return
	if(!isturf(parent.loc))
		qdel(src)
		return
	if(parent.inertia_moving)
		return
	if(!parent.Process_Spacemove(angle2dir(drifting_loop.angle), continuous_move = TRUE))
		return
	qdel(src)

/// We're going to take the passed in glide size
/// and use it to manually delay our loop for that period
/// to allow the other movement to complete
/datum/drift_handler/proc/handle_glidesize_update(datum/source, glide_size)
	SIGNAL_HANDLER
	// If we aren't drifting, or this is us, fuck off
	if(!drifting_loop || parent.inertia_moving)
		return
	// If we are drifting, but this set came from the moveloop itself, drop the input
	// I'm sorry man
	if(ignore_next_glide)
		ignore_next_glide = FALSE
		return
	var/glide_delay = round(ICON_SIZE_ALL / glide_size, 1) * world.tick_lag
	drifting_loop.pause_for(glide_delay)
	delayed = TRUE

/// If we're pulling something and stop, we want it to continue at our rate and such
/datum/drift_handler/proc/stopped_pulling(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER
	// This does mean it falls very slightly behind, but otherwise they'll potentially run into us
	var/next_move_in = drifting_loop.timer - world.time + world.tick_lag
	was_pulling.newtonian_move(angle2dir(drifting_loop.angle), start_delay = next_move_in, drift_force = drift_force, controlled_cap = drift_force)

/datum/drift_handler/proc/glide_to_halt(glide_for)
	if(!ismob(parent))
		qdel(src)
		return

	var/mob/mob_parent = parent
	var/client/our_client = mob_parent.client
	// If we're not active, don't do the glide because it'll look dumb as fuck
	if(!our_client || delayed)
		qdel(src)
		return

	block_inputs_until = world.time + glide_for + 1
	QDEL_IN(src, glide_for + 1)
	qdel(drifting_loop)
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(allow_final_movement))

/datum/drift_handler/proc/allow_final_movement(datum/source)
	SIGNAL_HANDLER
	// Some things want to allow movement out of spacedrift, we should let them
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT) & DRIFT_ALLOW_INPUT)
		return NONE
	if(world.time >= block_inputs_until)
		return NONE
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/drift_handler/proc/get_loop_delay(atom/movable/movable)
	return (DEFAULT_INERTIA_SPEED / ((1 - INERTIA_SPEED_COEF) + drift_force * INERTIA_SPEED_COEF)) * movable.inertia_move_multiplier
