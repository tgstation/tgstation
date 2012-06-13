/mob/living/carbon/metroid/Login()
	..()

	update_hud()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == DEAD)
		src.verbs += /mob/proc/ghost

	return
