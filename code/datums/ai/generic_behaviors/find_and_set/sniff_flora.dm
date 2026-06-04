/datum/bt_node/ai_behavior/find_and_set/in_list/sniff_flora

/// Finds hydroponics trays with a growing seed that are not too weedy or pest-ridden
/datum/bt_node/ai_behavior/find_and_set/in_list/sniff_flora/valid_target(datum/ai_controller/controller, obj/machinery/hydroponics/candidate, search_range)
	if(!istype(candidate))
		return TRUE
	if(isnull(candidate.myseed))
		return FALSE
	if(candidate.weedlevel > 5 || candidate.pestlevel > 5)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
