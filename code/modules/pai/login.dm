/mob/living/silicon/pai/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	client.perspective = EYE_PERSPECTIVE
	if(holoform)
		client.eye = src
	else
		client.eye = card
