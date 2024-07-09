/// THE GRAVITY!!! IT WEIGHS!!!
/datum/movespeed_modifier/grounded_voidwalker
	multiplicative_slowdown = 1.1

/// Regenerate in space
/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = INFINITE
	alert_type = null
	// How much do we heal per tick?
	var/healing = 1.5

/datum/status_effect/space_regeneration/tick(effect)
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	if(isspaceturf(get_turf(owner)))
		owner.heal_ordered_damage(healing, list(BRUTE, BURN, OXY, STAMINA, TOX, BRAIN))

/datum/status_effect/planet_allergy
	id = "planet_allergy"
	duration = INFINITE
	alert_type = /atom/movable/screen/alert/veryhighgravity

/datum/status_effect/planet_allergy/tick()
	owner.adjustBruteLoss(1)
