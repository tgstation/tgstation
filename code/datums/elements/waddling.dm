/datum/element/waddling
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/waddle_type = WADDLE_WADDLE

/datum/element/waddling/Attach(datum/target, waddle_type = WADDLE_WADDLE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.waddle_type = waddle_type
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
	if(HAS_TRAIT(target, TRAIT_MOVE_FLYING))
		return
	switch(waddle_type)
		if(WADDLE_WADDLE)
			animate(target, pixel_z = 4, time = 0)
			var/prev_trans = matrix(target.transform)
			animate(pixel_z = 0, transform = turn(target.transform, pick(-12, 0, 12)), time=2)
			animate(pixel_z = 0, transform = prev_trans, time = 0)
		if(WADDLE_HOP)
			animate(target, pixel_y = target.pixel_y + 4, time = 1, easing = CIRCULAR_EASING|EASE_OUT)
			animate(pixel_y = initial(target.pixel_y), time = 1, easing = CIRCULAR_EASING|EASE_IN)
