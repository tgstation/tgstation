/datum/ai_controller/basic_controller/clown
	behavior_tree_json = "clown.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = null,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/clown/murder
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = null,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
