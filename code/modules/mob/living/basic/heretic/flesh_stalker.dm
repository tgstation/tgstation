/// Durable ambush mob with an EMP ability
/mob/living/basic/heretic_summon/stalker
	name = "\improper Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "An abomination cobbled together from varied remains. Its appearance changes slightly every time you blink."
	icon_state = "stalker"
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	ai_controller = /datum/ai_controller/basic_controller/stalker
	/// Actions to grant on spawn
	var/static/list/actions_to_add = list(
		/datum/action/cooldown/spell/emp/eldritch = BB_GENERIC_ACTION,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash = null,
		/datum/action/cooldown/spell/shapeshift/eldritch = BB_SHAPESHIFT_ACTION,
	)

/mob/living/basic/heretic_summon/stalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_target_timer)
	grant_actions_by_list(actions_to_add)

/// Changes shape and lies in wait when it has no target, uses EMP and attacks once it does
/datum/ai_controller/basic_controller/stalker
	behavior_tree_json = "code/modules/mob/living/basic/heretic/stalker.bt.json"
	ai_traits = CAN_ACT_IN_STASIS
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
