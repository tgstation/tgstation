/// similar to finding a target but looks for food types in the // the what?
/datum/ai_planning_subtree/find_food

/datum/ai_planning_subtree/find_food/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!QDELETED(target))
		// Busy with something
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_BASIC_MOB_CURRENT_TARGET, controller.blackboard[BB_BASIC_FOODS])
