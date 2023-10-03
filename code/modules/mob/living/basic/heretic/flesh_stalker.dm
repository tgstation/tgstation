/// Durable ambush mob with an EMP ability
/mob/living/basic/heretic_summon/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "An abomination cobbled together from varied remains. Its appearance changes slightly every time you blink."
	icon_state = "stalker"
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS

/mob/living/basic/heretic_summon/stalker/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/jaunt = new(src)
	jaunt.Grant(src)

	var/datum/action/cooldown/spell/shapeshift/eldritch/shapeshift/change = new(src)
	change.Grant(src)

	var/datum/action/cooldown/spell/emp/eldritch/emp = new(src)
	emp.Grant(src)
	ai_controller?.set_blackboard_key(BB_GENERIC_ACTION, emp)
