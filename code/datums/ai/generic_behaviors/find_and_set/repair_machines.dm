/datum/bt_node/ai_behavior/find_and_set/in_list/repair_machines

/// Finds machinery below max integrity
/datum/bt_node/ai_behavior/find_and_set/in_list/repair_machines/valid_target(datum/ai_controller/controller, obj/machinery/candidate, search_range)
	if(candidate.get_integrity() >= candidate.max_integrity)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
