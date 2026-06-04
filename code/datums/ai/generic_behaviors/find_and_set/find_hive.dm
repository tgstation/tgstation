/datum/bt_node/ai_behavior/find_and_set/in_list/find_hive

/// Finds beehives that contain at least one honeycomb
/datum/bt_node/ai_behavior/find_and_set/in_list/find_hive/valid_target(datum/ai_controller/controller, obj/structure/beebox/candidate, search_range)
	if(!length(candidate.honeycombs))
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
