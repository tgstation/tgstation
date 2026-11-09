/// Deletes the atom with a little fading out animation after a specified time
/atom/proc/fade_into_nothing(life_time = 5 SECONDS, fade_time = 3 SECONDS)
	QDEL_IN(src, life_time)
	if (fade_time <= 0)
		return

	if (life_time > fade_time)
		addtimer(CALLBACK(src, PROC_REF(fade_into_nothing_animate), fade_time), life_time - fade_time, TIMER_DELETE_ME)
	else
		fade_into_nothing_animate(fade_time)

/// Actually does the fade out, used by fade_into_nothing()
/atom/proc/fade_into_nothing_animate(fade_time)
	animate(src, alpha = 0, time = fade_time, flags = ANIMATION_PARALLEL)
