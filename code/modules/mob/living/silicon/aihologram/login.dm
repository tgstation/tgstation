/mob/living/silicon/aihologram/Login()
	..()

	src.client.screen = null

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE

	return