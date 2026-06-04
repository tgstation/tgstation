/datum/bt_node/ai_behavior/find_and_set/in_list/injured_mooks

/// Finds mooks below max health
/datum/bt_node/ai_behavior/find_and_set/in_list/injured_mooks/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	return candidate.health < candidate.maxHealth
