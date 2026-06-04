/datum/bt_node/ai_behavior/find_and_set/in_list/valid_deer

/// Finds living deer; notifies the target that this pawn is approaching to play
/datum/bt_node/ai_behavior/find_and_set/in_list/valid_deer/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	if(candidate.stat == DEAD)
		return FALSE
	if(!can_see(controller.pawn, candidate, search_range))
		return FALSE
	candidate.ai_controller?.set_blackboard_key(BB_DEER_PLAYFRIEND, controller.pawn)
	return TRUE
