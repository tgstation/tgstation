/mob/living/carbon/human/Login()
	..()

	update_hud()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == DEAD)
		src.verbs += /client/proc/ghost

	return
