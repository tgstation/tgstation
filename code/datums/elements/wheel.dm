/// Element which spins you as you move
/datum/element/wheel


/datum/element/wheel/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/element/wheel/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	var/atom/movable/owner = source
	var/matrix/to_turn = matrix(owner.transform)
	to_turn = turn(owner.transform, 360 - to_turn.get_angle())
	animate(src.owner, transform = to_turn, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)
	return ..()

/datum/element/wheel/proc/on_moved(atom/movable/moved, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced || CHECK_MOVE_LOOP_FLAGS(moved, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	if(isliving(moved))
		var/mob/living/living_moved = moved
		if (living_moved.incapacitated || living_moved.body_position == LYING_DOWN)
			return
	var/rotation_degree = (360 / 3)
	if(direction & SOUTHWEST)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(moved.transform)
	to_turn = turn(moved.transform, rotation_degree)
	animate(moved, transform = to_turn, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)
