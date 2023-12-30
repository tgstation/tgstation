/datum/uplink_handler
	/// Extra stuff that cannot be purchased by an uplink, regardless of flag.
	var/list/locked_entries = list()
	///how much contractor rep we have
	var/contractor_rep = 0
	///list of our contractor market items
	var/list/contractor_market_items = list()
	///list of purchased contractor items
	var/list/purchased_contractor_items = list()

///Add items to our locked_entries
/datum/uplink_handler/proc/add_locked_entries(list/items_to_add)
	for(var/datum/uplink_item/item as anything in items_to_add)
		locked_entries |= item

///Clear a handler's potential_objectives
/**
 * fail_active - should we also call fail_objective() their active_objectives
 * regenerate_objectives - should we let their objectives regenerate or not
 */
/datum/uplink_handler/proc/clear_secondaries(fail_active = FALSE, regenerate_objectives = FALSE)
	var/original_max = maximum_potential_objectives
	if(!regenerate_objectives)
		maximum_potential_objectives = 0 //janky, but it needs the least new code and should work with what this proc does

	for(var/datum/traitor_objective/possible_objective in potential_objectives + (fail_active ? active_objectives : list()))
		possible_objective.fail_objective()
	maximum_potential_objectives = original_max
