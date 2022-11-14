/datum/ai_planning_subtree/simple_find_nearest_target_to_flee

/datum/ai_planning_subtree/simple_find_nearest_target_to_flee/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/nearest, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
