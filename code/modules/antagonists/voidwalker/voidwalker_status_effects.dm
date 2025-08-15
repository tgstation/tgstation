/// THE GRAVITY!!! IT WEIGHS!!!
/datum/movespeed_modifier/grounded_voidwalker
	multiplicative_slowdown = 1.1

/datum/status_effect/planet_allergy
	id = "planet_allergy"
	duration = STATUS_EFFECT_PERMANENT
	alert_type = /atom/movable/screen/alert/status_effect/veryhighgravity

/datum/status_effect/planet_allergy/tick()
	owner.adjustBruteLoss(1)

/atom/movable/screen/alert/status_effect/veryhighgravity
	name = "Crushing Gravity"
	desc = "You're getting crushed by high gravity, picking up items and movement will be slowed. You'll also accumulate brute damage!"
	icon_state = "paralysis"

/datum/status_effect/void_eatered
	id = "void_eatered"
	duration = 10 SECONDS
	remove_on_fullheal = TRUE
	alert_type = null

/datum/status_effect/void_eatered/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/void_eatered/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))
