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

	for(var/datum/weakref/target_ref as anything in to_haunt_list)
		if(to_haunt_list[target_ref] <= 0)
			to_haunt_list -= target_ref
			continue

		var/mob/living/real_target = target_ref.resolve()
		if(QDELETED(real_target))
			to_haunt_list -= target_ref
			continue

		if(get_dist(real_target, item_pawn) <= 7)
			controller.blackboard[BB_HAUNT_TARGET] = target_ref
			controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/ghostly/haunted, BB_HAUNT_TARGET, BB_HAUNTED_THROW_ATTEMPT_COUNT)
			return SUBTREE_RETURN_FINISH_PLANNING
