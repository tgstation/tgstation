/mob/living/carbon/alien/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddInfectionImages()
	return

/mob/living/carbon/alien/humanoid/royal/queen/Login()
	. = ..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno/queen))
		mind.add_antag_datum(/datum/antagonist/xeno/queen)
