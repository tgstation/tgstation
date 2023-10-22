/// Pretty basic, just click people to death. Also hunt and eat bananas.
/datum/ai_controller/basic_controller/gorilla
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_EMOTE_KEY = "ooga",
		BB_EMOTE_CHANCE = 40,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/run_emote,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/gorilla,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/gorilla
	attack_behaviour = /datum/ai_behavior/attack_obstructions/gorilla

/datum/ai_behavior/attack_obstructions/gorilla
	can_attack_turfs = TRUE

/datum/ai_controller/basic_controller/gorilla/lesser
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items,
		BB_EMOTE_KEY = "ooga",
		BB_EMOTE_CHANCE = 60,
	)
