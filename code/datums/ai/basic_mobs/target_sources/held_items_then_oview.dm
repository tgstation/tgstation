/// Returns the pawn's held items first, then nearby atoms via oview(). Used for food searches that prefer held items.
/datum/target_source/held_items_then_oview

/datum/target_source/held_items_then_oview/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/candidates = (pawn.held_items || list())
	var/list/nearby = oview(range, pawn)
	if(nearby.len)
		candidates += reverse_range(nearby)
	return candidates
