/datum/status_effect/jitter
	id = "jitter"
	tick_interval = 2 SECONDS
	alert_type = null
	/// While resting, our jitters go away faster.
	var/resting_modifier = 1

/datum/status_effect/jitter/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/jitter/on_apply()
	RegisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_LIVING_DEATH), .proc/remove_jitter)
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, .proc/on_rest)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/jittery)
	return TRUE

/datum/status_effect/jitter/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_LIVING_DEATH, COMSIG_LIVING_SET_BODY_POSITION))
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)

/// Removes all of our jitteriness on a signal
/datum/status_effect/jitter/proc/remove_jitter(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// Signal proc for [COMSIG_LIVING_SET_BODY_POSITION]. Whenever we rest, it depletes faster but is more dizzying
/datum/status_effect/jitter/proc/on_rest(mob/living/source)
	SIGNAL_HANDLER

	resting_modifier = source.resting ? 5 : initial(resting_modifier)

/datum/status_effect/jitter/tick()

	var/time_left_in_seconds = (duration - world.time) / 10
	do_jitter_animation(time_left_in_seconds)

	// Decrease the duration by our resting_modifier, effectively skipping resting_modifier ticks
	duration -= ((resting_modifier - 1) * initial(tick_interval))

/mob/living/proc/do_jitter_animation(jitter_amount)
	var/amplitude = min(4, (jitter_amount / 100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff , time = 2, loop = 6, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -pixel_x_diff , pixel_y = -pixel_y_diff , time = 2, flags = ANIMATION_RELATIVE)
