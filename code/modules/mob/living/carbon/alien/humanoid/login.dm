/mob/living/carbon/alien/humanoid/Login()
	..()
	update_hud()
	updatePlasmaHUD()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
