/// Deletes the atom with a little fading out animation after a specified time
/datum/element/temporary_atom

/datum/element/temporary_atom/Attach(datum/target, life_time = 5 SECONDS, fade_time = 3 SECONDS)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), WEAKREF(target)), life_time, TIMER_DELETE_ME)
	if (life_time > fade_time && fade_time > 0)
		addtimer(CALLBACK(src, PROC_REF(fade_out), WEAKREF(target), fade_time), life_time - fade_time, TIMER_DELETE_ME)

/datum/element/temporary_atom/proc/fade_out(datum/weakref/target_ref, fade_time)
	var/atom/target = target_ref?.resolve()
	if (isnull(target))
		return
	animate(target, alpha = 0, time = fade_time, flags = ANIMATION_PARALLEL)
