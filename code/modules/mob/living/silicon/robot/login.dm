/mob/living/silicon/robot/Login()
	..()

	update_clothing()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghost
	if(!src.connected_ai)
		for(var/mob/living/silicon/ai/A in world)
			src.connected_ai = A
			A.connected_robots += src
			break
	return