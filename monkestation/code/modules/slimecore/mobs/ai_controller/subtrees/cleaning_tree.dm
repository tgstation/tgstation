
/datum/ai_planning_subtree/cleaning_subtree

/datum/ai_planning_subtree/cleaning_subtree/SelectBehaviors(datum/ai_controller/basic_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_CLEAN_TARGET))
		controller.queue_behavior(/datum/ai_behavior/execute_clean, BB_CLEAN_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/list/final_hunt_list = list()

	final_hunt_list += controller.blackboard[BB_CLEANABLE_DECALS]
	final_hunt_list += controller.blackboard[BB_CLEANABLE_BLOOD]
	final_hunt_list += controller.blackboard[BB_HUNTABLE_PESTS]
	final_hunt_list += controller.blackboard[BB_HUNTABLE_TRASH]

	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list/clean_targets, BB_CLEAN_TARGET, final_hunt_list)

