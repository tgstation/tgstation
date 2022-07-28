///Component that handles drifting
///Manages a movement loop that actually does the legwork of moving someone
///Alongside dealing with the post movement input blocking required to make things look nice
/datum/component/drift
	var/atom/inertia_last_loc
	var/old_dir
	var/datum/move_loop/move/drifting_loop
	///Should we ignore the next glide rate input we get?
	///This is to some extent a hack around the order of operations
	///Around COMSIG_MOVELOOP_POSTPROCESS. I'm sorry lad
	var/ignore_next_glide = FALSE
	///Have we been delayed? IE: active, but not working right this second?
	var/delayed = FALSE
	var/block_inputs_until

/// Accepts three args. The direction to drift in, if the drift is instant or not, and if it's not instant, the delay on the start
/datum/component/drift/Initialize(direction, instant = FALSE, start_delay = 0)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

	var/flags = NONE
	if(instant)
		flags |= MOVEMENT_LOOP_START_FAST
	var/atom/movable/movable_parent = parent
	drifting_loop = SSmove_manager.move(moving = parent, direction = direction, delay = movable_parent.inertia_move_delay, subsystem = SSspacedrift, priority = MOVEMENT_SPACE_PRIORITY, flags = flags)

	if(!drifting_loop) //Really want to qdel here but can't
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_START, .proc/drifting_start)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_STOP, .proc/drifting_stop)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/before_move)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/after_move)
	RegisterSignal(drifting_loop, COMSIG_PARENT_QDELETING, .proc/loop_death)
	if(drifting_loop.running)
		drifting_start(drifting_loop) // There's a good chance it'll autostart, gotta catch that

	var/visual_delay = movable_parent.inertia_move_delay

	// Start delay is essentially a more granular version of instant
	// Isn't used in the standard case, just for things that have odd wants
	if(!instant && start_delay)
		drifting_loop.pause_for(start_delay)
		visual_delay = start_delay

	apply_initial_visuals(visual_delay)

/datum/component/drift/Destroy()
	inertia_last_loc = null
	if(!QDELETED(drifting_loop))
		qdel(drifting_loop)
	drifting_loop = null
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	return ..()

/datum/component/drift/proc/apply_initial_visuals(visual_delay)
	// If something "somewhere" doesn't want us to apply our glidesize delays, don't
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT) & DRIFT_VISUAL_FAILED)
		return

	// Ignore the next glide because it's literally just us
	ignore_next_glide = TRUE
	var/atom/movable/movable_parent = parent
	movable_parent.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSspacedrift.visual_delay))
	if(ismob(parent))
		var/mob/mob_parent = parent
		//Ok this is slightly weird, but basically, we need to force the client to glide at our rate
		//Make sure moving into a space move looks like a space move essentially
		//There is an inbuilt assumption that gliding will be added as a part of a move call, but eh
		//It's ok if it's not, it's just important if it is.
		mob_parent.client?.visual_delay = MOVEMENT_ADJUSTED_GLIDE_SIZE(visual_delay, SSspacedrift.visual_delay)

/datum/component/drift/proc/newtonian_impulse(datum/source, inertia_direction)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	inertia_last_loc = movable_parent.loc
	drifting_loop.direction = inertia_direction
	if(!inertia_direction)
		qdel(src)
	return COMPONENT_MOVABLE_NEWTONIAN_BLOCK

/datum/component/drift/proc/drifting_start()
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	inertia_last_loc = movable_parent.loc
	RegisterSignal(movable_parent, COMSIG_MOVABLE_MOVED, .proc/handle_move)
	RegisterSignal(movable_parent, COMSIG_MOVABLE_NEWTONIAN_MOVE, .proc/newtonian_impulse)
	// We will use glide size to intuit how long to delay our loop's next move for
	// This way you can't ride two movements at once while drifting, since that'd be dumb as fuck
	RegisterSignal(movable_parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, .proc/handle_glidesize_update)
	// If you stop pulling something mid drift, I want it to retain that momentum
	RegisterSignal(movable_parent, COMSIG_ATOM_NO_LONGER_PULLING, .proc/stopped_pulling)

/datum/component/drift/proc/drifting_stop()
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	ignore_next_glide = FALSE
	UnregisterSignal(movable_parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_NEWTONIAN_MOVE, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, COMSIG_ATOM_NO_LONGER_PULLING))

/datum/component/drift/proc/before_move(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = TRUE
	old_dir = movable_parent.dir
	delayed = FALSE

/datum/component/drift/proc/after_move(datum/source, succeeded, visual_delay)
	SIGNAL_HANDLER
	if(!succeeded)
		qdel(src)
		return

	var/atom/movable/movable_parent = parent
	movable_parent.setDir(old_dir)
	movable_parent.inertia_moving = FALSE
	if(movable_parent.Process_Spacemove(drifting_loop.direction, continuous_move = TRUE))
		glide_to_halt(visual_delay)
		return

	inertia_last_loc = movable_parent.loc
	ignore_next_glide = TRUE

/datum/component/drift/proc/loop_death(datum/source)
	SIGNAL_HANDLER
	drifting_loop = null
	UnregisterSignal(parent, COMSIG_MOVABLE_NEWTONIAN_MOVE)

/datum/component/drift/proc/handle_move(datum/source, old_loc)
	SIGNAL_HANDLER
	// This can happen, because signals once sent cannot be stopped
	if(QDELETED(src))
		return
	var/atom/movable/movable_parent = parent
	if(!isturf(movable_parent.loc))
		qdel(src)
		return
	if(movable_parent.inertia_moving)
		return
	if(!movable_parent.Process_Spacemove(drifting_loop.direction, continuous_move = TRUE))
		return
	qdel(src)

/// We're going to take the passed in glide size
/// and use it to manually delay our loop for that period
/// to allow the other movement to complete
/datum/component/drift/proc/handle_glidesize_update(datum/source, glide_size)
	SIGNAL_HANDLER
	// If we aren't drifting, or this is us, fuck off
	var/atom/movable/movable_parent = parent
	if(!drifting_loop || movable_parent.inertia_moving)
		return
	// If we are drifting, but this set came from the moveloop itself, drop the input
	// I'm sorry man
	if(ignore_next_glide)
		ignore_next_glide = FALSE
		return
	var/glide_delay = round(world.icon_size / glide_size, 1) * world.tick_lag
	drifting_loop.pause_for(glide_delay)
	delayed = TRUE

/// If we're pulling something and stop, we want it to continue at our rate and such
/datum/component/drift/proc/stopped_pulling(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER
	// This does mean it falls very slightly behind, but otherwise they'll potentially run into us
	var/next_move_in = drifting_loop.timer - world.time + world.tick_lag
	was_pulling.newtonian_move(drifting_loop.direction, start_delay = next_move_in)

/datum/component/drift/proc/glide_to_halt(glide_for)
	if(!ismob(parent))
		qdel(src)
		return

	var/mob/mob_parent = parent
	var/client/our_client = mob_parent.client
	// If we're not active, don't do the glide because it'll look dumb as fuck
	if(!our_client || delayed)
		qdel(src)
		return

	block_inputs_until = world.time + glide_for
	QDEL_IN(src, glide_for + 1)
	qdel(drifting_loop)
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, .proc/allow_final_movement)

/datum/component/drift/proc/allow_final_movement(datum/source)
	// Some things want to allow movement out of spacedrift, we should let them
	if(SEND_SIGNAL(parent, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT) & DRIFT_ALLOW_INPUT)
		return
	if(world.time < block_inputs_until)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
