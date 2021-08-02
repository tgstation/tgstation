/datum/ai_planning_subtree/simple_attack_target

/datum/ai_planning_subtree/simple_attack_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	controller.AddBehavior(/datum/ai_behavior/can_still_attack_target, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM)
	controller.AddBehavior(/datum/ai_behavior/basic_melee_attack, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
