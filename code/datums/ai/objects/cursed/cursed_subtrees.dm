/datum/ai_planning_subtree/cursed/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	//make sure we have a target
	var/mob/living/carbon/curse_target = controller.blackboard[BB_ITEM_TARGET]

	if(curse_target && get_dist(curse_target, item_pawn) > ITEM_AGGRO_VIEW_RANGE)
		controller.blackboard[BB_ITEM_TARGET] = null
		return

	if(!controller.blackboard[BB_ITEM_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/item_target, BB_ITEM_TARGET, /mob/living/carbon, ITEM_AGGRO_VIEW_RANGE)

	controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/ghostly, BB_ITEM_TARGET, BB_ITEM_THROW_ATTEMPT_COUNT)
