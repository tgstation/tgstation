/datum/bt_node/ai_behavior/find_and_set/in_list/stove

/// Finds stoves with finished baked goods (nothing still bakeable inside)
/datum/bt_node/ai_behavior/find_and_set/in_list/stove/valid_target(datum/ai_controller/controller, obj/machinery/oven/range/candidate, search_range)
	if(!length(candidate.used_tray?.contents) || candidate.open)
		return FALSE
	for(var/atom/baking in candidate.used_tray)
		if(HAS_TRAIT(baking, TRAIT_BAKEABLE))
			return FALSE
	return TRUE
