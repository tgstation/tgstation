/// Gathers nearby carbon humans within BB_MAXIMUM_DISTANCE_TO_VILLAGE of the BB_HOME_VILLAGE anchor.
/datum/target_source/near_village_humans

/datum/target_source/near_village_humans/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/atom/anchor = controller.blackboard[BB_HOME_VILLAGE]
	var/max_dist = controller.blackboard[BB_MAXIMUM_DISTANCE_TO_VILLAGE] || range
	var/list/candidates = list()
	for(var/mob/living/carbon/human/candidate in oview(max_dist, pawn))
		if(!isnull(anchor) && get_dist(candidate, anchor) > max_dist)
			continue
		candidates += candidate
	return candidates
