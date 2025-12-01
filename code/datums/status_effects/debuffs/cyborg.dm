/// Slows down a cyborg for a short time.
/datum/status_effect/borg_slow
	id = "borg_slowdown"
	alert_type = null
	duration = 3 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_CC_STATUS
	/// Amount of slowdown being applied
	var/slowdown = 1

/datum/status_effect/borg_slow/on_creation(mob/living/new_owner, slowdown = 1)
	src.slowdown = slowdown
	return ..()

/datum/status_effect/borg_slow/on_apply()
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/borg_slowdown, multiplicative_slowdown = slowdown)
	return TRUE

/datum/status_effect/borg_slow/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/borg_slowdown)

/datum/status_effect/borg_slow/refresh(mob/living/new_owner, slowdown = 1)
	. = ..()
	if(src.slowdown <= slowdown)
		return
	src.slowdown = slowdown
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/borg_slowdown, multiplicative_slowdown = src.slowdown)

/datum/movespeed_modifier/borg_slowdown
	variable = TRUE
