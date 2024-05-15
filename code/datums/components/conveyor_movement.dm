//Make a component to do things like gravity/flying checks
///Manages the loop caused by being on a conveyor belt
///Prevents movement while you're floating, etc
///Takes the direction to move, delay between steps, and time before starting to move as arguments
/datum/component/convey
	var/living_parent = FALSE
	var/speed

/datum/component/convey/Initialize(direction, speed, start_delay)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	living_parent = isliving(parent)
	src.speed = speed
	if(!start_delay)
		start_delay = speed
	var/atom/movable/moving_parent = parent
	var/datum/move_loop/loop = GLOB.move_manager.move(moving_parent, direction, delay = start_delay, subsystem = SSconveyors, flags=MOVEMENT_LOOP_IGNORE_PRIORITY|MOVEMENT_LOOP_OUTSIDE_CONTROL)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(should_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_ended))

/datum/component/convey/proc/should_move(datum/move_loop/source)
	SIGNAL_HANDLER
	source.delay = speed //We use the default delay
	if(living_parent)
		var/mob/living/moving_mob = parent
		if((moving_mob.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && !moving_mob.stat)
			return MOVELOOP_SKIP_STEP
	var/atom/movable/moving_parent = parent
	if(moving_parent.anchored || !moving_parent.has_gravity())
		return MOVELOOP_SKIP_STEP

/datum/component/convey/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)
