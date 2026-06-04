/datum/bt_node/ai_behavior/find_and_set/in_list/apcs

/// Finds APCs that have a cell and are not at full charge
/datum/bt_node/ai_behavior/find_and_set/in_list/apcs/valid_target(datum/ai_controller/controller, obj/machinery/power/apc/candidate, search_range)
	if(!candidate.cell)
		return FALSE
	var/obj/item/stock_parts/power_store/cell/apc_cell = candidate.cell
	if(apc_cell.charge == apc_cell.maxcharge)
		return FALSE
	return can_see(controller.pawn, candidate, search_range)
