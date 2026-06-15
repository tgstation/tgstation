/// Accepts APCs that have a cell which is not at full charge, and are visible to the pawn.
/datum/targeting_strategy/chargeable_apc

/datum/targeting_strategy/chargeable_apc/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/power/apc/candidate = target
	if(!istype(candidate) || !candidate.cell)
		return FALSE
	var/obj/item/stock_parts/power_store/cell/apc_cell = candidate.cell
	if(apc_cell.charge == apc_cell.maxcharge)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
