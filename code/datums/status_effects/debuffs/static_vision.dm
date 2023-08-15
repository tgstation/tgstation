/datum/status_effect/static_vision
	id = "static_vision"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/static_vision/on_creation(mob/living/new_owner, duration = 3 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/static_vision/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(remove_static_vision))

	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/static_vision)
	owner.sound_environment_override = SOUND_ENVIRONMENT_UNDERWATER

	return TRUE

/datum/status_effect/static_vision/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

	owner.clear_fullscreen(id)
	if(owner.sound_environment_override == SOUND_ENVIRONMENT_UNDERWATER)
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/// Handles clearing on death
/datum/status_effect/static_vision/proc/remove_static_vision(datum/source, admin_revive)
	SIGNAL_HANDLER

	qdel(src)
