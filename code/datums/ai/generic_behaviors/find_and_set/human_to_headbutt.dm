/datum/bt_node/ai_behavior/find_and_set/in_list/human_to_headbutt

/// Finds conscious humans who have at least one leg
/datum/bt_node/ai_behavior/find_and_set/in_list/human_to_headbutt/valid_target(datum/ai_controller/controller, mob/living/carbon/human/candidate, search_range)
	if(candidate.stat != CONSCIOUS)
		return FALSE
	if(isnull(candidate.get_bodypart(BODY_ZONE_R_LEG)) && isnull(candidate.get_bodypart(BODY_ZONE_L_LEG)))
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
