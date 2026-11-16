/datum/target_source/oview_living_no_slimes

/datum/target_source/oview_living_no_slimes/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/list/candidates = list()
	for(var/mob/living/living_candidate in oview(range, pawn))
		if(isslime(living_candidate))
			continue
		candidates += living_candidate

	return candidates
