/mob/living/carbon/human/species/alien/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddInfectionImages()

/mob/living/carbon/human/species/alien/Logout()
	..()
	RemoveInfectionImages()
