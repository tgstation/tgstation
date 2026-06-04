/datum/bt_node/ai_behavior/find_and_set/in_list/find_owner

/// Finds allied mobs (used by pets looking for their owner)
/datum/bt_node/ai_behavior/find_and_set/in_list/find_owner/valid_target(datum/ai_controller/controller, atom/candidate, search_range)
	var/mob/living/pawn = controller.pawn
	return (candidate != pawn) && pawn.has_ally(candidate) && can_see(pawn, candidate, search_range)
