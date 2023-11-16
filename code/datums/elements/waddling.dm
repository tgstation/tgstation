/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Waddle))

/datum/element/waddling/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/waddling/proc/Waddle(atom/movable/moved, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced || CHECK_MOVE_LOOP_FLAGS(moved, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	if(isliving(moved))
		var/mob/living/living_moved = moved
		if (living_moved.incapacitated() || living_moved.body_position == LYING_DOWN)
			return
	waddling_animation(moved)

/datum/element/waddling/proc/waddling_animation(atom/movable/target)
	animate(target, pixel_z = 4, time = 0)
	var/prev_trans = matrix(target.transform)
	animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = prev_trans, time = 0)
