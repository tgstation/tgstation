
/datum/ai_controller/basic_controller/penguin
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ONLY_FISH_WHILE_HUNGRY = TRUE,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/fish/drilled_ice,
		/datum/ai_planning_subtree/find_and_hunt_target/drill_ice,
		/datum/ai_planning_subtree/find_and_hunt_target/penguin_egg,
		/datum/ai_planning_subtree/random_speech/penguin,
	)

///subtree to find baby eggs!
/datum/ai_planning_subtree/find_and_hunt_target/penguin_egg
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target
	finding_behavior = /datum/ai_behavior/find_hunt_target/penguin_egg
	hunt_targets = list(/obj/item/food/egg/penguin_egg)
	hunt_range = 7

/datum/ai_behavior/find_hunt_target/penguin_egg/valid_dinner(mob/living/source, atom/dinner, radius)
	return can_see(source, dinner, radius) && !(dinner in source.contents)

///subtree to find diggable ice we can fish from!
/datum/ai_planning_subtree/find_and_hunt_target/drill_ice
	target_key = BB_DRILLABLE_ICE
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target
	finding_behavior = /datum/ai_behavior/find_hunt_target/search_turf_types/drillable_ice
	hunt_targets = list(/turf/open/misc/ice)
	hunt_range = 7

/datum/ai_behavior/find_hunt_target/search_turf_types/drillable_ice

/datum/ai_behavior/find_hunt_target/search_turf_types/drillable_ice/valid_dinner(mob/living/source, turf/open/misc/ice/ice, radius)
	return ice.can_make_hole && can_see(source, ice, radius)

/datum/ai_planning_subtree/find_and_hunt_target/drill_ice/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_FISHING_TARGET))
		return
	return ..()

/datum/ai_planning_subtree/fish/drilled_ice
	find_fishable_behavior = /datum/ai_behavior/find_and_set/in_list/drilled_ice

/datum/ai_behavior/find_and_set/in_list/drilled_ice/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	for(var/atom/possible_ice as anything in RANGE_TURFS(search_range, controller.pawn))
		if(!istype(possible_ice, /turf/open/misc/ice))
			continue
		if(HAS_TRAIT(possible_ice, TRAIT_FISHING_SPOT))
			return possible_ice
	return null

///ai controller for the baby penguin
/datum/ai_controller/basic_controller/penguin/baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/pet/penguin),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/pet/penguin/baby),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/look_for_adult,
	)
