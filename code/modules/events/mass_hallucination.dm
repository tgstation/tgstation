/datum/event/mass_hallucination
	oneShot	= 1


/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.hallucination += rand(20, 50)