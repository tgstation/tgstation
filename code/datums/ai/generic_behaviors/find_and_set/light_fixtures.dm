/datum/bt_node/ai_behavior/find_and_set/in_list/light_fixtures

/// Finds lights that are not already broken
/datum/bt_node/ai_behavior/find_and_set/in_list/light_fixtures/valid_target(datum/ai_controller/controller, obj/machinery/light/candidate, search_range)
	if(candidate.status == LIGHT_BROKEN)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
