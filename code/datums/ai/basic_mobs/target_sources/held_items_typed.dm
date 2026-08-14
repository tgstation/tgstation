/// Gathers held items matching a fixed typepath.
/datum/target_source/held_items_typed
	var/locate_typepath

/datum/target_source/held_items_typed/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/candidates = list()
	for(var/atom/candidate as anything in pawn.held_items)
		if(istype(candidate, locate_typepath))
			candidates += candidate
	return candidates

/datum/target_source/held_items_typed/instrument
	locate_typepath = /obj/item/instrument
