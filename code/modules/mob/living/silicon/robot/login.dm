
/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	if(mind)
		ticker.mode.remove_revolutionary(mind)
		ticker.mode.remove_gangster(mind,1,remove_bosses=1)
