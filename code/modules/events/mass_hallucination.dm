/datum/event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/event/mass_hallucination
	weight = 7
	max_occurrences = 2

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.hallucination += rand(20, 50)