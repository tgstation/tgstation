/datum/status_effect/staggered
	id = "staggered"
	tick_interval = 0.5 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/staggered/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/staggered/on_apply()

	//a very mild animation, but you can't stagger the dead.
	if(owner.stat == DEAD)
		owner.do_stagger_animation(duration / 10)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_staggered))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/staggered)
	return TRUE

/datum/status_effect/staggered/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/staggered)
	// Resetting both X on remove so we're back to normal
	owner.pixel_x = owner.base_pixel_x

/// Signal proc that self deletes our staggered effect
/datum/status_effect/staggered/proc/clear_staggered(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/staggered/tick(seconds_between_ticks)
	owner.do_stagger_animation()

/// Helper proc that causes the mob to do a stagger animation.
/// Doesn't change significantly, just meant to represent swaying back and forth
/mob/living/proc/do_stagger_animation()
	animate(src, pixel_x = 4, time = 0.2 SECONDS, loop = 6, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
