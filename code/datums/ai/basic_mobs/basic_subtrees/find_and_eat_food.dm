/// similar to finding a target but looks for food types in the wanted list
/datum/ai_planning_subtree/find_and_eat_food

/datum/ai_planning_subtree/find_and_eat_food/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()
	var/list/wanted = controller.blackboard[BB_BASIC_FOODS]
	if(!target || QDELETED(target))
		//we need to find some food
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_BASIC_MOB_CURRENT_TARGET, wanted)
		return

	if(target in wanted)
		controller.queue_behavior(/datum/ai_behavior/basic_melee_attack, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		return SUBTREE_RETURN_FINISH_PLANNING
