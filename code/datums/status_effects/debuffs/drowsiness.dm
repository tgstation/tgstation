/datum/status_effect/drowsiness
	id = "drowsiness"
	tick_interval = 2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/drowsiness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/drowsiness/on_apply()
	if(HAS_TRAIT(owner, TRAIT_SLEEPIMMUNE) || !(owner.status_flags & CANUNCONSCIOUS))
		return FALSE
	// Do robots dream of electric sheep?
	if(issilicon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(on_face_clean))
	return TRUE

/datum/status_effect/drowsiness/on_remove()
	UnregisterSignal(owner, COMSIG_COMPONENT_CLEAN_FACE_ACT)

/// Signal proc for [COMSIG_COMPONENT_CLEAN_FACE_ACT]. When we wash our face, reduce drowsiness by a bit.
/datum/status_effect/drowsiness/proc/on_face_clean(datum/source)
	SIGNAL_HANDLER

	remove_duration(rand(4 SECONDS, 6 SECONDS))

/datum/status_effect/drowsiness/tick(seconds_between_ticks)
	// You do not feel drowsy while unconscious or in stasis
	if(owner.stat >= UNCONSCIOUS || HAS_TRAIT(owner, TRAIT_STASIS))
		return

	// Resting helps against drowsiness
	// While resting, we lose 4 seconds of duration (2 additional ticks) per tick
	if(owner.resting && remove_duration(2 * seconds_between_ticks))
		return

	owner.set_eye_blur_if_lower(4 SECONDS)
	if(prob(5))
		owner.AdjustSleeping(10 SECONDS)
