/datum/ai_planning_subtree/cursed/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!controller.blackboard[BB_ITEM_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_ITEM_TARGET, /mob/living/carbon, ITEM_AGGRO_VIEW_RANGE)
		return

	controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/ghostly, BB_ITEM_TARGET, BB_ITEM_THROW_ATTEMPT_COUNT)
	return SUBTREE_RETURN_FINISH_PLANNING
