/datum/bt_node/ai_behavior/find_and_set/in_list/corpses

/// Finds dead mobs
/datum/bt_node/ai_behavior/find_and_set/in_list/corpses/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	if(!isliving(candidate) || candidate.stat != DEAD)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)

/datum/bt_node/ai_behavior/find_and_set/in_list/corpses/dragon_corpse

/// Finds dead mobs that are not already being dragged
/datum/bt_node/ai_behavior/find_and_set/in_list/corpses/dragon_corpse/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	if(candidate.pulledby)
		return FALSE
	return ..()
