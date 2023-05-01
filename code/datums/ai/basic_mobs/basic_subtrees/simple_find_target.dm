/datum/ai_planning_subtree/simple_find_target

/datum/ai_planning_subtree/simple_find_target/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/datum/ai_planning_subtree/simple_find_target/setup(datum/ai_controller/controller)
	if(!controller.blackboard[BB_VISION_RANGE])
		controller.set_blackboard_key(BB_VISION_RANGE, DEFAULT_BASIC_AI_VISION_RANGE)
