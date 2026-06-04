/datum/bt_node/ai_behavior/find_and_set/in_list/penguin_egg

/// Finds eggs that the pawn is not already carrying
/datum/bt_node/ai_behavior/find_and_set/in_list/penguin_egg/valid_target(datum/ai_controller/controller, atom/candidate, search_range)
	return can_see(controller.pawn, candidate, search_range) && !(candidate in controller.pawn.contents)
