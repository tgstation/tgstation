/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 7
	max_occurrences = 2

/datum/round_event/mass_hallucination/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.hallucination += rand(50, 75) //was 20-50. Since hallucination only works when it's above 20, this would do nothing.