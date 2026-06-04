/datum/bt_node/ai_behavior/find_and_set/in_list/injured_raptor

/// Finds any living mob below max health (excluding the pawn)
/datum/bt_node/ai_behavior/find_and_set/in_list/injured_raptor/valid_target(datum/ai_controller/controller, mob/living/candidate, search_range)
	return controller.pawn != candidate && candidate.health < candidate.maxHealth
