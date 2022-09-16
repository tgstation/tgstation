/datum/status_effect/drowsiness
	id = "drowsiness"
	tick_interval = 2 SECONDS
	alert_type = null

/datum/status_effect/drowsiness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/drowsiness/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/clear_drowsiness)
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_FACE_ACT, .proc/on_face_clean)
	return TRUE

/datum/status_effect/drowsiness/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_COMPONENT_CLEAN_FACE_ACT))

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL]. On heal, self terminate
/datum/status_effect/drowsiness/proc/clear_drowsiness(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// Signal proc for [COMSIG_COMPONENT_CLEAN_FACE_ACT]. When we wash our face, reduce drowsiness by a bit.
/datum/status_effect/drowsiness/proc/on_face_clean(datum/source)
	SIGNAL_HANDLER

	duration -= rand(-4 SECONDS, -6 SECONDS)
	if(duration < world.time)
		qdel(src)

/datum/status_effect/drowsiness/tick(delta_time)
	// You do not feel drowsy while unconscious or in stasis
	if(owner.stat >= UNCONSCIOUS || IS_IN_STASIS(owner))
		return

	// If our owner's resting, lose another 3 seconds of duration every tick
	// (Effectively meaning we lose 5 seconds of duration per tick while resting instead of 2 seconds)
	if(owner.resting)
		duration -= 3 SECONDS

	owner.set_eye_blur_if_lower(4 SECONDS)
	if(prob(5))
		owner.AdjustSleeping(10 SECONDS)
