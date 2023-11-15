/datum/ai_controller/basic_controller/cow
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/find_food,
		//attacking the food will eat it
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/cow,
	)
