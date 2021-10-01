/datum/ai_planning_subtree/haunted/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	if(ismob(item_pawn.loc)) //We're being held, maybe escape?
		if(DT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, delta_time))
			LAZYADD(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/item_escape_grasp))
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
			controller.current_movement_target = potential_target
			LAZYADD(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/item_move_close_and_attack/haunted))
			return SUBTREE_RETURN_FINISH_PLANNING
