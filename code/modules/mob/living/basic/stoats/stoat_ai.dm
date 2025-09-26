/datum/ai_controller/basic_controller/stoat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_GUILTY_CONSCIOUS_CHANCE = 5,
		BB_STEAL_CHANCE = 2,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/stoat),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/stoat/kit),
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
		/datum/ai_planning_subtree/make_babies,
	)

/datum/ai_controller/basic_controller/stoat/kit
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
