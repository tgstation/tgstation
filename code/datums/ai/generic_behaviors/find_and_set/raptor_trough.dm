/datum/bt_node/ai_behavior/find_and_set/in_list/raptor_trough

/// Finds troughs (or containers) that hold at least one ore item
/datum/bt_node/ai_behavior/find_and_set/in_list/raptor_trough/valid_target(datum/ai_controller/controller, atom/movable/candidate, search_range)
	return !!(locate(/obj/item/stack/ore) in candidate.contents)
