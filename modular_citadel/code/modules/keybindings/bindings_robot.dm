/mob/living/silicon/robot/key_down(_key, client/user)
	switch(_key)
		if("Shift")
			togglesprint()
			return
	return ..()

/mob/living/silicon/robot/key_up(_key, client/user)
	switch(_key)
		if("Shift")
			togglesprint()
			return
	return ..()
