/datum/ai_controller/basic_controller/ice_whelp
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "ice_whelp.bt.json"
