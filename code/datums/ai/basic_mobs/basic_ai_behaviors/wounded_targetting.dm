/// Picks targets based on which one has the lowest health
/datum/ai_behavior/find_potential_targets/most_wounded

/datum/ai_behavior/find_potential_targets/most_wounded/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/list/living_targets = list()
	for(var/mob/living/living_target in filtered_targets)
		living_targets += filtered_targets
	if(living_targets.len)
		sortTim(living_targets, GLOBAL_PROC_REF(cmp_mob_health))
		return living_targets[1]
	return ..()
