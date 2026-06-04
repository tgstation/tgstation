/datum/bt_node/ai_behavior/find_and_set/in_list/snail_people

/// Finds conscious, snail-species carbon mobs
/datum/bt_node/ai_behavior/find_and_set/in_list/snail_people/valid_target(datum/ai_controller/controller, mob/living/carbon/candidate, search_range)
	if(!istype(candidate))
		return FALSE
	if(candidate.stat != CONSCIOUS)
		return FALSE
	if(!is_species(candidate, /datum/species/snail))
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
