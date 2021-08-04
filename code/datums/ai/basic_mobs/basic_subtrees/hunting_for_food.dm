/datum/ai_planning_subtree/hunting

/datum/ai_planning_subtree/hunting/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.AddBehavior(/datum/ai_behavior/find_target, BB_CURRENT_HUNTING_TARGET, BB_HUNTING_TARGET_TYPES)
	controller.AddBehavior(/datum/ai_behavior/hunt_target, BB_CURRENT_HUNTING_TARGET)
