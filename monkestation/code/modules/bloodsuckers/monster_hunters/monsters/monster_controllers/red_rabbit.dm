/**
 * AI controller
 */
/datum/ai_controller/basic_controller/red_rabbit
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/rabbit,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/rabbit
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/rabbit

/datum/ai_behavior/basic_melee_attack/rabbit
	action_cooldown = 1.2 SECONDS
