/// Deletes the atom with a little fading out animation after a specified time
/atom/proc/fade_into_nothing(var/atom/target = src, life_time = 5 SECONDS, fade_time = 3 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), WEAKREF(target)), life_time, TIMER_DELETE_ME)
	if (life_time > fade_time && fade_time > 0)
		addtimer(CALLBACK(src, PROC_REF(fade_into_nothing_fade_out), WEAKREF(target), fade_time), life_time - fade_time, TIMER_DELETE_ME)

/// Actually does the fade out, used by fade_into_nothing()
/atom/proc/fade_into_nothing_animate(datum/weakref/target_ref, fade_time)
	var/atom/target = target_ref?.resolve()
	if (isnull(target))
		return
	animate(target, alpha = 0, time = fade_time, flags = ANIMATION_PARALLEL)
