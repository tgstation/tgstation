#define MIN_POWER_DRAIN 25000000
#define MAX_POWER_DRAIN 100000000

GLOBAL_LIST_INIT(minor_infiltrator_objectives, list(/datum/objective/assassinate, /datum/objective/steal))

/datum/objective/infiltrator
	explanation_text = "Generic Infiltrator Objective!"
	martyr_compatible = FALSE


/datum/objective/infiltrator/exploit
	explanation_text = "Exploit the station's Nanotrasen AI and make it loyal to the Syndicate."

/datum/objective/infiltrator/exploit/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/infiltrator/exploit/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Hijack [station_name()]'s AI unit, [target.name]."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/exploit/check_completion()
	if(isAI(target))
		var/mob/living/silicon/ai/A = target
		return A && A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai)
	return FALSE


/datum/objective/infiltrator/power
	explanation_text = "Drain power from the station with a power sink."

/datum/objective/infiltrator/power/New()
	target_amount = rand(MIN_POWER_DRAIN, MAX_POWER_DRAIN)
	update_explanation_text()

/datum/objective/infiltrator/power/update_explanation_text()
	..()
	if(target_amount)
		explanation_text = "Drain [DisplayPower(target_amount)] from [station_name()]'s powernet with a special transmitter powersink."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/power/check_completion()
	return GLOB.powersink_transmitted >= target_amount