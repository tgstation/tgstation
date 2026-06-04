/datum/bt_node/ai_behavior/find_and_set/in_list/hunt_mice

/// Finds alive mice without a player mind
/datum/bt_node/ai_behavior/find_and_set/in_list/hunt_mice/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	if(candidate.stat == DEAD || candidate.mind)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
