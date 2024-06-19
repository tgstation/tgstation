/// similar to finding a target but looks for food types in the // the what?
/datum/ai_planning_subtree/find_food
	///behavior we use to find the food
	var/datum/ai_behavior/finding_behavior = /datum/ai_behavior/find_and_set/in_list
	///key of foods list
	var/food_list_key = BB_BASIC_FOODS

/datum/ai_planning_subtree/find_food/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		// Busy with something
		return

	controller.queue_behavior(finding_behavior, BB_BASIC_MOB_CURRENT_TARGET, controller.blackboard[food_list_key])
