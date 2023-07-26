/// Find the nearest thing which we assume is hostile and set it as the flee target
/datum/ai_planning_subtree/simple_find_nearest_target_to_flee

/datum/ai_planning_subtree/simple_find_nearest_target_to_flee/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/nearest, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/// Find the nearest thing on our list of 'things which have done damage to me' and set it as the flee target
/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee
	var/targeting_key = BB_TARGETTING_DATUM

/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list/nearest, BB_BASIC_MOB_RETALIATE_LIST, BB_BASIC_MOB_CURRENT_TARGET, targeting_key, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/from_flee_key
	targeting_key = BB_FLEE_TARGETTING_DATUM
