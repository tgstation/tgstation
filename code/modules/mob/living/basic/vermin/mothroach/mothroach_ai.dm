/datum/ai_controller/basic_controller/mothroach
	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_EAT_FOOD_COOLDOWN = 1 MINUTES,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_food/mothroach,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/random_speech/mothroach,
	)

/datum/ai_planning_subtree/find_food/mothroach
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/mothroach_food

/datum/ai_behavior/find_and_set/in_list/mothroach_food

/datum/ai_behavior/find_and_set/in_list/mothroach_food/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	var/mob/living/living_pawn = controller.pawn
	found -= living_pawn.loc
	if(length(found))
		return pick(found)
