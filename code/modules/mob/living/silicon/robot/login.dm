
/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	if(mind)
		SSticker.mode.remove_revolutionary(mind)
