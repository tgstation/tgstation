/datum/component/infective_floor
	var/list/datum/disease/diseases //make sure these are the static, non-processing versions!

/datum/component/infective_floor/Initialize(list/datum/disease/_diseases)
	RegisterSignal(COMSIG_MOVABLE_CROSSED, .proc/Infect)
	diseases = _diseases

/datum/component/infective_floor/proc/Infect(atom/movable/AM)
	var/mob/living/carbon/victim = AM
	if(istype(victim))
		for(var/datum/disease/D in diseases)
			victim.ContactContractDisease(D, "feet")
		return TRUE