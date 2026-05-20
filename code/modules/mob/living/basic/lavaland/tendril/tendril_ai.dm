/datum/ai_controller/basic_controller/tendril
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/target_retaliate/check_faction/multi_target,
		/datum/ai_planning_subtree/simple_find_target/multi_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/multi_target,
	)
