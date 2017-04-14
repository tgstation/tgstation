/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 7
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination/start()
	for(var/mob/living/carbon/C in GLOB.living_mob_list)
		C.hallucination += rand(20, 50)