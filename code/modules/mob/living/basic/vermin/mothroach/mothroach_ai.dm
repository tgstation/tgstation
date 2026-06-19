/datum/ai_controller/basic_controller/mothroach
	behavior_tree_json = "mothroach.bt.json"
	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_EAT_FOOD_COOLDOWN = 1 MINUTES,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
