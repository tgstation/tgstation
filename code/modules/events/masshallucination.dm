/datum/event/mass_hallucination


/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.hallucination += rand(100, 250)
