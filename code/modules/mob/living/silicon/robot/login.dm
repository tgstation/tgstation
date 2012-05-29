/mob/living/silicon/robot/Login()
	..()

	rebuild_appearance()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghost
	if(src.real_name == "Cyborg")
		src.ident = rand(1, 999)
		src.real_name += " "
		src.real_name += "-[ident]"
		src.name = src.real_name
	/*if(!src.connected_ai)
		for(var/mob/living/silicon/ai/A in world)
			src.connected_ai = A
			A.connected_robots += src
			break
	*/
	return