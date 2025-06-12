/**
 * Effectively grants a temporary form of x-ray with a cooldown period.
 */
/datum/status_effect/temporary_xray
	id = "temp xray"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// Stores world.time when the effect is applied
	var/time_applied
	/// Duration after which our xray expires
	var/lockout_period = 10 SECONDS // 10 SECONDS of xray by default

/datum/status_effect/temporary_xray/on_creation(mob/living/new_owner, duration = 3 MINUTES, lockout_period = 10 SECONDS, ...)
	src.duration = duration
	src.lockout_period = lockout_period
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	time_applied = world.time

/datum/status_effect/temporary_xray/tick(seconds_between_ticks)
	. = ..()
	if(!lockout_period)
		return
	if(world.time < time_applied + lockout_period)
		return
	// Remove the xray but don't delete the status effect.
	// So in order to re-gain the xray we must wait out the remaining duration (or somehow clear the effect)
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

/datum/status_effect/temporary_xray/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
