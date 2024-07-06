/// THE GRAVITY!!! IT WEIGHS!!!
/datum/movespeed_modifier/grounded_voidwalker
	multiplicative_slowdown = 1.3

/// Regenerate in space
/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = INFINITE
	alert_type = null

/datum/status_effect/space_regeneration/on_apply()
	heal_owner()
	return TRUE

/datum/status_effect/space_regeneration/tick(effect)
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 1, burn = 1, required_bodytype = BODYTYPE_ORGANIC)

/datum/status_effect/planet_allergy
	id = "planet_allergy"
	duration = INFINITE
	alert_type = /atom/movable/screen/alert/veryhighgravity

/datum/status_effect/planet_allergy/tick()
	owner.adjustBruteLoss(1)
