/datum/ai_controller/basic_controller/stoat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_GUILTY_CONSCIOUS_CHANCE = 5,
		BB_STEAL_CHANCE = 2,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/random_speech/blackboard,
		/datum/ai_planning_subtree/steal_items,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_food,
	)
