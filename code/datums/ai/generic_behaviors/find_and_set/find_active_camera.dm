/datum/bt_node/ai_behavior/find_and_set/in_list/find_active_camera

/// Finds machinery that is not broken
/datum/bt_node/ai_behavior/find_and_set/in_list/find_active_camera/valid_target(datum/ai_controller/controller, obj/machinery/candidate, search_range)
	if(candidate.machine_stat & BROKEN)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
