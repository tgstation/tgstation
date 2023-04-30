/datum/ai_planning_subtree/haunted/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/obj/item/item_pawn = controller.pawn

	if(ismob(item_pawn.loc)) //We're being held, maybe escape?
		if(controller.blackboard[BB_LIKES_EQUIPPER])//don't unequip from people it's okay with
			return
		if(SPT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, seconds_per_tick))
			controller.queue_behavior(/datum/ai_behavior/item_escape_grasp)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!SPT_PROB(HAUNTED_ITEM_ATTACK_HAUNT_CHANCE, seconds_per_tick))
		return

	var/list/to_haunt_list = controller.blackboard[BB_TO_HAUNT_LIST]

	for(var/mob/living/haunt_target as anything in to_haunt_list)
		if(to_haunt_list[haunt_target] <= 0)
			controller.remove_thing_from_blackboard_key(BB_TO_HAUNT_LIST, haunt_target)
			continue

		if(get_dist(haunt_target, item_pawn) <= 7)
			controller.set_blackboard_key(BB_HAUNT_TARGET, haunt_target)
			controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/ghostly/haunted, BB_HAUNT_TARGET, BB_HAUNTED_THROW_ATTEMPT_COUNT)
			return SUBTREE_RETURN_FINISH_PLANNING
