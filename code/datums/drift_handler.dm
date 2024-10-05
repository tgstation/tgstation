///Component that handles drifting
///Manages a movement loop that actually does the legwork of moving someone
///Alongside dealing with the post movement input blocking required to make things look nice
/datum/drift_handler
	var/atom/movable/parent
	var/atom/inertia_last_loc
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
		flags |= MOVEMENT_LOOP_START_FAST
	src.drift_force = drift_force
	drifting_loop = GLOB.move_manager.smooth_move(moving = parent, angle = inertia_angle, delay = get_loop_delay(parent), subsystem = SSnewtonian_movement, priority = MOVEMENT_SPACE_PRIORITY, flags = flags)

	if(!drifting_loop)
		qdel(src)
		return

	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_START, PROC_REF(drifting_start))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_STOP, PROC_REF(drifting_stop))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(before_move))
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(after_move))
	RegisterSignal(drifting_loop, COMSIG_QDELETING, PROC_REF(loop_death))
	RegisterSignal(parent, COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE, PROC_REF(attempt_halt))
	if(drifting_loop.status & MOVELOOP_STATUS_RUNNING)
		drifting_start(drifting_loop) // There's a good chance it'll autostart, gotta catch that

	var/visual_delay = get_loop_delay(parent)

	// Start delay is essentially a more granular version of instant
	// Isn't used in the standard case, just for things that have odd wants
	if(!instant && start_delay)
		drifting_loop.pause_for(start_delay)
		visual_delay = start_delay

	apply_initial_visuals(visual_delay)

/datum/drift_handler/Destroy()
	inertia_last_loc = null
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

/datum/drift_handler/proc/newtonian_impulse(inertia_angle, start_delay, additional_force, controlled_cap)
	SIGNAL_HANDLER
	inertia_last_loc = parent.loc
	// We've been told to move in the middle of deletion process, tell parent to create a new handler instead
	if(!drifting_loop)
		qdel(src)
		return FALSE

	var/applied_force = additional_force

	var/force_x = sin(drifting_loop.angle) * drift_force + sin(inertia_angle) * applied_force / parent.inertia_force_weight
	var/force_y = cos(drifting_loop.angle) * drift_force + cos(inertia_angle) * applied_force / parent.inertia_force_weight

	drift_force = clamp(sqrt(force_x * force_x + force_y * force_y), 0, !isnull(controlled_cap) ? controlled_cap : INERTIA_FORCE_CAP)
	if(drift_force < 0.1) // Rounding issues
		qdel(src)
		return TRUE

	drifting_loop.set_angle(delta_to_angle(force_x, force_y))
	drifting_loop.set_delay(get_loop_delay(parent))
	return TRUE

/datum/drift_handler/proc/drifting_start()
	SIGNAL_HANDLER
	inertia_last_loc = parent.loc
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

	inertia_last_loc = parent.loc
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
		return
	if(world.time < block_inputs_until)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/datum/drift_handler/proc/attempt_halt(mob/source, movement_dir, continuous_move, atom/backup)
	SIGNAL_HANDLER

	if (get_dir(source, backup) == movement_dir || source.loc == backup.loc)
		if (drift_force >= INERTIA_FORCE_THROW_FLOOR)
			source.throw_at(backup, 1, floor(1 + (drift_force - INERTIA_FORCE_THROW_FLOOR) / INERTIA_FORCE_PER_THROW_FORCE), spin = FALSE)
		return

	if (drift_force < INERTIA_FORCE_SPACEMOVE_GRAB || isnull(drifting_loop))
		return

	if (drift_force <= INERTIA_FORCE_SPACEMOVE_REDUCTION / source.inertia_force_weight)
		glide_to_halt(get_loop_delay(source))
		return COMPONENT_PREVENT_SPACEMOVE_HALT

	drift_force -= INERTIA_FORCE_SPACEMOVE_REDUCTION / source.inertia_force_weight
	drifting_loop.set_delay(get_loop_delay(source))
	return COMPONENT_PREVENT_SPACEMOVE_HALT

/datum/drift_handler/proc/get_loop_delay(atom/movable/movable)
	return (DEFAULT_INERTIA_SPEED / ((1 - INERTIA_SPEED_COEF) + drift_force * INERTIA_SPEED_COEF)) * movable.inertia_move_multiplier

/datum/drift_handler/proc/stabilize_drift(target_angle, target_force, stabilization_force)
	/// We aren't drifting
	if (isnull(drifting_loop))
		return

	/// Lack of angle means that we are trying to halt movement
	if (isnull(target_angle))
		// Going through newtonian_move ensures that all Process_Spacemove code runs properly, instead of directly adjusting forces
		parent.newtonian_move(reverse_angle(drifting_loop.angle), drift_force = min(drift_force, stabilization_force))
		return

	// Force required to be applied in order to get to the desired movement vector, with projection of current movement onto desired vector to ensure that we only compensate for excess
	var/drift_projection = max(0, cos(target_angle - drifting_loop.angle)) * drift_force
	var/force_x = sin(target_angle) * target_force - sin(drifting_loop.angle) * drift_force
	var/force_y = cos(target_angle) * target_force - cos(drifting_loop.angle) * drift_force
	var/force_angle = delta_to_angle(force_x, force_y)
	var/applied_force = sqrt(force_x * force_x + force_y * force_y)
	var/force_projection = max(0, cos(target_angle - force_angle)) * applied_force
	force_x -= min(force_projection, drift_projection) * sin(target_angle)
	force_x -= min(force_projection, drift_projection) * cos(target_angle)
	applied_force = min(sqrt(force_x * force_x + force_y * force_y), stabilization_force)
	parent.newtonian_move(force_angle, instant = TRUE, drift_force = applied_force)

/// Removes all force in a certain direction
/datum/drift_handler/proc/remove_angle_force(target_angle)
	/// We aren't drifting
	if (isnull(drifting_loop))
		return

	var/projected_force = max(0, cos(target_angle - drifting_loop.angle)) * drift_force
	if (projected_force > 0)
		parent.newtonian_move(reverse_angle(target_angle), projected_force)
