
/datum/target_source/oview_water_turfs

/datum/target_source/oview_water_turfs/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/list/candidates = list()
	for(var/turf/open/water/water_turf in oview(range, pawn))
		candidates += water_turf

	return candidates


/datum/target_source/oview_land_turfs

/datum/target_source/oview_water_turfs/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = ..()
	var/list/candidates = list()
	for(var/turf/open/potential_floor in oview(range, pawn))
		if(iswaterturf(potential_floor))
			continue
		candidates += potential_floor

	return candidates
