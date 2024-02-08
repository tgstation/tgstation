/// Picks targets based on which one is closest to you, choice between targets at equal distance is arbitrary
/datum/ai_behavior/find_potential_targets/nearest

/datum/ai_behavior/find_potential_targets/nearest/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/turf/our_position = get_turf(controller.pawn)
	return get_closest_atom(/atom/, filtered_targets, our_position)

/// As above but targets have been filtered from the 'retaliate' blackboard list
/datum/ai_behavior/target_from_retaliate_list/nearest

/datum/ai_behavior/target_from_retaliate_list/nearest/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	var/turf/our_position = get_turf(controller.pawn)
	return get_closest_atom(/atom/, enemies_list, our_position)
