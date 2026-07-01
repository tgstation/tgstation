/datum/ai_controller/basic_controller/regal_rat
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/regal_rat/regal_rat.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/// Only activate the domain when it isn't already running.
/datum/bt_node/ai_behavior/use_mob_ability/domain

/datum/bt_node/ai_behavior/use_mob_ability/domain/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/mob_cooldown/domain/domain = controller.blackboard[ability_key]
	if(!istype(domain) || domain.is_active)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()
