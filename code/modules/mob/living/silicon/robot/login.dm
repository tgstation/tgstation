
/mob/living/silicon/robot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	regenerate_icons()
