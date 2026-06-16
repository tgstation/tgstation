
/datum/ai_controller/basic_controller/penguin
	behavior_tree_json = "penguin.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

///ai controller for the baby penguin
/datum/ai_controller/basic_controller/penguin/baby
	behavior_tree_json = "penguin_baby.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/pet/penguin),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/pet/penguin/baby),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
