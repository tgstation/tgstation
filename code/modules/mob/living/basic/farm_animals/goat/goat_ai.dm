/// Goats are normally content to sorta hang around and crunch any plant in sight, but they will go ape on someone who attacks them.
/datum/ai_controller/basic_controller/goat
	behavior_tree_json = "goat.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
