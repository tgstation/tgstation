/datum/objective/infiltrator
	explanation_text = "Generic Infiltrator Objective!"
	martyr_compatible = FALSE


/datum/objective/infiltrator/exploit
	explanation_text = "Exploit the station's Nanotrasen AI and make it loyal to the syndicate."

/datum/objective/infiltrator/exploit/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/infiltrator/exploit/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Hijack [station_name()]'s AI unit, [target.name], and make it loyal to the Syndicate."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/exploit/check_completion()
	if(isAI(target))
		var/mob/living/silicon/ai/A = target
		return A && A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai)
	return FALSE