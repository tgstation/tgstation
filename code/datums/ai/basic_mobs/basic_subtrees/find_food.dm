/// similar to finding a target but looks for food types in the
/datum/ai_planning_subtree/find_food

/datum/ai_planning_subtree/find_food/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(target && !QDELETED(target))
		return
	var/list/wanted = controller.blackboard[BB_BASIC_FOODS]
	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_BASIC_MOB_CURRENT_TARGET, wanted)
