/datum/target_source/oview_living

/datum/target_source/oview_living/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/list/candidates = list()
	for(var/mob/living/living_candidate in oview(range, pawn))
		candidates += living_candidate

	return candidates


/datum/target_source/oview_raptor_babies

/datum/target_source/oview_raptor_babies/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/list/candidates = list()
	for(var/mob/living/basic/raptor/candidate in oview(range, pawn))
		candidates += candidate

	return candidates
