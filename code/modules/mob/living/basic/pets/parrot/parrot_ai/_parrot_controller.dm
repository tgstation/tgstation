/datum/ai_controller/basic_controller/parrot
	behavior_tree_json = "parrot.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_HOARD_LOCATION_RANGE = 9,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance


/datum/bt_node/subtree/perching
	behavior_tree_json = "perching.bt.json"
