/datum/bt_node/ai_behavior/find_and_set/in_list/mouse_cable

/// Finds cables on accessible open floor tiles
/datum/bt_node/ai_behavior/find_and_set/in_list/mouse_cable/valid_target(datum/ai_controller/controller, obj/structure/cable/candidate, search_range)
	if(!can_see(controller.pawn, candidate, search_range))
		return FALSE
	var/turf/open/floor/below_the_cable = get_turf(candidate)
	if(!istype(below_the_cable))
		return FALSE
	return below_the_cable.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE
