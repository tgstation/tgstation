/datum/ai_planning_subtree/find_paper_and_write

/datum/ai_planning_subtree/find_paper_and_write/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/wizard = controller.pawn

	if(controller.blackboard_key_exists(BB_SIMPLE_CARRY_ITEM))
		controller.queue_behavior(/datum/ai_behavior/write_on_paper, BB_SIMPLE_CARRY_ITEM, BB_WRITING_LIST)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/obj/item/paper/target = controller.blackboard[BB_FOUND_PAPER]

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/empty_paper, BB_FOUND_PAPER, /obj/item/paper)
		return

	if(get_turf(wizard) != get_turf(target))
		controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_FOUND_PAPER)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!(target in wizard.contents))
		controller.queue_behavior(/datum/ai_behavior/pick_up_item, BB_FOUND_PAPER, BB_SIMPLE_CARRY_ITEM)
		return SUBTREE_RETURN_FINISH_PLANNING
