/datum/bt_node/ai_behavior/find_and_set/in_list/raptor_baby

/// Finds baby raptors
/datum/bt_node/ai_behavior/find_and_set/in_list/raptor_baby/valid_target(datum/ai_controller/controller, mob/living/basic/raptor/candidate, search_range)
	if(!can_see(controller.pawn, candidate, search_range) || candidate.stat == DEAD)
		return FALSE
	return candidate.growth_stage == RAPTOR_BABY
