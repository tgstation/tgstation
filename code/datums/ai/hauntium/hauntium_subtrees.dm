/datum/ai_planning_subtree/haunted/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	if(ismob(item_pawn.loc)) //We're being held, maybe escape?
		if(controller.blackboard[BB_LIKES_EQUIPPER])//don't unequip from people it's okay with
			return
		if(DT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, delta_time))
			controller.queue_behavior(/datum/ai_behavior/item_escape_grasp)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!DT_PROB(HAUNTED_ITEM_ATTACK_HAUNT_CHANCE, delta_time))
		return

	var/list/to_haunt_list = controller.blackboard[BB_TO_HAUNT_LIST]

	for(var/i in to_haunt_list)
		if(to_haunt_list[i] <= 0)
			continue
		var/mob/living/potential_target = i
		if(get_dist(potential_target, item_pawn) <= 7)
			controller.blackboard[BB_HAUNT_TARGET] = potential_target
			controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/haunted, BB_HAUNT_TARGET, BB_HAUNTED_THROW_ATTEMPT_COUNT)
			return SUBTREE_RETURN_FINISH_PLANNING
