/mob/living/silicon/hivebot/Login()
	..()

	update_clothing()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /client/proc/ghost
	if(src.real_name == "Hiveborg")
		src.real_name += " "
		src.real_name += "-[rand(1, 999)]"
		src.name = src.real_name
	return