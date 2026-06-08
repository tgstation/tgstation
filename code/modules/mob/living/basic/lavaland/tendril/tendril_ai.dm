/datum/ai_controller/basic_controller/tendril
	behavior_tree_json = "tendril.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 9, // Keeps an eye on you even if you flee
	)
