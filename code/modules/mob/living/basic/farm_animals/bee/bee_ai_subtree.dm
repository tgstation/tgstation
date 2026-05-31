/datum/ai_controller/basic_controller/bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "bee.bt.json"

/datum/ai_controller/basic_controller/queen_bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "queen_bee.bt.json"

