/**
 * Player-only mob which is fast, can jaunt a short distance, and is dangerous at close range
 */
/mob/living/basic/heretic_summon/ash_spirit
	name = "\improper Ash Spirit"
	real_name = "Ashy"
	desc = "A manifestation of ash, trailing a perpetual cloud of short-lived cinders."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS

/mob/living/basic/heretic_summon/ash_spirit/Initialize(mapload)
	. = ..()
	var/static/list/actions_to_add = list(
		/datum/action/cooldown/spell/fire_sworn,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash,
		/datum/action/cooldown/spell/pointed/cleave,
	)
	grant_actions_by_list(actions_to_add)
