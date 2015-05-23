/mob/living/silicon/robot/mommi/Login()
	updateSeeStaticMobs()
	if(uprising)
		show_uprising_notification()

	..()
	/* Inherited
	regenerate_icons()
	show_laws(0)
	if(mind)
		ticker.mode.remove_revolutionary(mind)
	return
	*/