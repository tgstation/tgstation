/datum/bt_node/ai_behavior/find_and_set/in_list/decorate_donuts

/// Finds decorated donuts
/datum/bt_node/ai_behavior/find_and_set/in_list/decorate_donuts/valid_target(datum/ai_controller/controller, obj/item/food/donut/candidate, search_range)
	if(!candidate.is_decorated)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
