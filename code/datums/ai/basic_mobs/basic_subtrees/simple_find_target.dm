/datum/ai_planning_subtree/simple_find_target

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	AddBehavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_VISION_TARGETS)
	AddBehavior(/datum/ai_behavior/select_target, BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_VISION_TARGETS, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
