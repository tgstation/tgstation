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
	AddComponent(/datum/component/ai_target_timer)

	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/jaunt = new(src)
	jaunt.Grant(src)

	var/datum/action/cooldown/spell/shapeshift/eldritch/change = new(src)
	change.Grant(src)
	ai_controller?.set_blackboard_key(BB_SHAPESHIFT_ACTION, change)

	var/datum/action/cooldown/spell/emp/eldritch/emp = new(src)
	emp.Grant(src)
	ai_controller?.set_blackboard_key(BB_GENERIC_ACTION, emp)

/// Changes shape and lies in wait when it has no target, uses EMP and attacks once it does
/datum/ai_controller/basic_controller/stalker
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/shapechange_ambush,
		/datum/ai_planning_subtree/use_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
