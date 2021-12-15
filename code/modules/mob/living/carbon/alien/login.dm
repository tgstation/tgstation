/mob/living/carbon/human/species/alien/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddInfectionImages()
	return
