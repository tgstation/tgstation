/mob/living/carbon/metroid/Login()
	..()

	update_clothing()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghost

	return