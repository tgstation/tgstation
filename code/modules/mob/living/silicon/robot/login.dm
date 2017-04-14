
/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	if(mind)
		SSticker.mode.remove_revolutionary(mind)
		SSticker.mode.remove_gangster(mind,1,remove_bosses=1)
