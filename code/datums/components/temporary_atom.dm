/// Deletes the atom with a little fading out animation after a specified time
/datum/component/temporary_atom

/datum/component/temporary_atom/Initialize(life_time = 5 SECONDS, fade_time = 3 SECONDS)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), parent), life_time, TIMER_DELETE_ME)
	if (life_time > fade_time)
		addtimer(CALLBACK(src, PROC_REF(fade_out), fade_time), life_time - fade_time, TIMER_DELETE_ME)

/datum/component/temporary_atom/proc/fade_out(fade_time)
	animate(parent, alpha = 0, time = fade_time, flags = ANIMATION_PARALLEL)
