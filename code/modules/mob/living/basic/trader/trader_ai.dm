/datum/ai_controller/basic_controller/trader
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/syndicate

/datum/ai_behavior/basic_ranged_attack/trader
	action_cooldown = 3 SECONDS
