/datum/bt_node/ai_behavior/find_and_set/in_list/bonfire

/// Finds bonfires that are not currently lit
/datum/bt_node/ai_behavior/find_and_set/in_list/bonfire/valid_target(datum/ai_controller/controller, obj/structure/bonfire/candidate, search_range)
	if(candidate.burning)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
