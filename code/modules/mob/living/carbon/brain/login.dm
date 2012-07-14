/mob/living/carbon/brain/Login()
	..()
	if (!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return