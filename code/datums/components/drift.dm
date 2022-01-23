///Component that handles drifting
///Manages a movement loop that actually does the legwork of moving someone
///Alongside dealing with the post movement input blocking required to make things look nice
/datum/component/drift
	var/atom/inertia_last_loc
	var/old_dir
	var/datum/move_loop/move/drifting_loop
	var/block_inputs_until

/datum/component/drift/Initialize(direction)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

	var/atom/movable/movable_parent = parent
	drifting_loop = SSmove_manager.move(moving = parent, direction = direction, delay = movable_parent.inertia_move_delay, subsystem = SSspacedrift, priority = MOVEMENT_SPACE_PRIORITY)

	if(!drifting_loop) //Really want to qdel here but can't
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_START, .proc/drifting_start)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_STOP, .proc/drifting_stop)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/before_move)
	RegisterSignal(drifting_loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/after_move)
	RegisterSignal(drifting_loop, COMSIG_PARENT_QDELETING, .proc/loop_death)
	if(drifting_loop.running)
		drifting_start(drifting_loop) // There's a good chance it'll autostart, gotta catch that

/datum/component/drift/Destroy()
	inertia_last_loc = null
	if(!QDELETED(drifting_loop))
		qdel(drifting_loop)
	drifting_loop = null
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	return ..()

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

/datum/component/drift/proc/drifting_stop()
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	UnregisterSignal(movable_parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_NEWTONIAN_MOVE))

/datum/component/drift/proc/before_move(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = TRUE
	old_dir = movable_parent.dir

/datum/component/drift/proc/after_move(datum/source, succeeded, visual_delay)
	SIGNAL_HANDLER
	if(!succeeded)
		qdel(src)
		return

	var/atom/movable/movable_parent = parent
	movable_parent.inertia_moving = FALSE
	movable_parent.setDir(old_dir)
	if(movable_parent.Process_Spacemove(0))
		glide_to_halt(visual_delay)
		return

	inertia_last_loc = movable_parent.loc

/datum/component/drift/proc/loop_death(datum/source)
	SIGNAL_HANDLER
	drifting_loop = null
	UnregisterSignal(parent, COMSIG_MOVABLE_NEWTONIAN_MOVE)

/datum/component/drift/proc/handle_move(datum/source, old_loc)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(!isturf(movable_parent.loc))
		qdel(src)
		return
	if(movable_parent.inertia_moving) //This'll be handled elsewhere
		return
	if(!movable_parent.Process_Spacemove(0))
		return
	qdel(src)

/datum/component/drift/proc/glide_to_halt(glide_for)
	if(!ismob(parent))
		qdel(src)
		return

	var/mob/mob_parent = parent
	var/client/our_client = mob_parent.client
	if(!our_client)
		qdel(src)
		return

	block_inputs_until = world.time + glide_for
	QDEL_IN(src, glide_for + 1)
	qdel(drifting_loop)
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, .proc/allow_final_movement)

/datum/component/drift/proc/allow_final_movement(datum/source)
	if(world.time < block_inputs_until)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
