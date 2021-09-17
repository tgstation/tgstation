/mob/living/carbon/alien/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddInfectionImages()
	return
