/mob/living/carbon/alien/larva/Login()
	..()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
