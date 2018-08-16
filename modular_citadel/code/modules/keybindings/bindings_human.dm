/mob/living/carbon/human/key_down(_key, client/user)
	switch(_key)
		if("Shift")
			togglesprint()
			return
	return ..()

/mob/living/carbon/human/key_up(_key, client/user)
	switch(_key)
		if("Shift")
			togglesprint()
			return
	return ..()
