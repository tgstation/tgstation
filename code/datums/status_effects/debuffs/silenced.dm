/datum/status_effect/silenced
	id = "silent"
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/silenced/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/silenced/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_silence))
	ADD_TRAIT(owner, TRAIT_MUTE, id)
	return TRUE

/datum/status_effect/silenced/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	REMOVE_TRAIT(owner, TRAIT_MUTE, id)

/// Signal proc that clears any silence we have (self-deletes).
/datum/status_effect/silenced/proc/clear_silence(mob/living/source)
	SIGNAL_HANDLER

	qdel(src)
