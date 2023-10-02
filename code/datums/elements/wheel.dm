/// Element which spins you as you move
/datum/element/wheel

/datum/element/wheel/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, isliving(target) ? PROC_REF(on_living_moved) : PROC_REF(on_moved))

/datum/element/wheel/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/wheel/proc/on_living_moved(mob/living/target, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced || target.incapacitated() || target.body_position == LYING_DOWN || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	on_moved(target, oldloc, direction, forced)

/datum/element/wheel/proc/on_moved(atom/movable/target, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced || CHECK_MOVE_LOOP_FLAGS(target, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	var/rotation_degree = (360 / 3)
	if(direction & WEST || direction & SOUTH)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(target.transform)
	to_turn = turn(target.transform, rotation_degree)
	animate(target, transform = to_turn, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)
