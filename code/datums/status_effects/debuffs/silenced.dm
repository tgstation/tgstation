/datum/status_effect/silenced
	id = "silent"
	alert_type = null

/datum/status_effect/silenced/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/silenced/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/clear_silence)
	RegisterSignal(owner, COMSIG_LIVING_VOCAL_SPEECH_CHECK, .proc/on_vocal_check)
	return TRUE

/datum/status_effect/silenced/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_LIVING_VOCAL_SPEECH_CHECK))

/// Signal proc for [COMSIG_LIVING_VOCAL_SPEECH_CHECK], being silenced prevents you from talking. Duh.
/datum/status_effect/silenced/proc/on_vocal_check(datum/source, message)
	SIGNAL_HANDLER

	return COMPONENT_CANNOT_SPEAK
