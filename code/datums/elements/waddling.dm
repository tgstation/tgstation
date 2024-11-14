/datum/element/waddling

/datum/element/waddling/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(!HAS_TRAIT(target, TRAIT_WADDLING))
		stack_trace("[type] added to [target] without adding TRAIT_WADDLING first. Please use AddElementTrait instead.")
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
		if (living_moved.incapacitated || (living_moved.body_position == LYING_DOWN && !HAS_TRAIT(living_moved, TRAIT_FLOPPING)))
			return
	waddling_animation(moved)

/datum/element/waddling/proc/waddling_animation(atom/movable/target)
	var/prev_pixel_z = target.pixel_z
	animate(target, pixel_z = target.pixel_z + 4, time = 0)
	var/prev_transform = target.transform
	animate(pixel_z = prev_pixel_z, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
	animate(transform = prev_transform, time = 0)
