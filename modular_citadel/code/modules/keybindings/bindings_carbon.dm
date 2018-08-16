/mob/living/carbon/key_down(_key, client/user)
	switch(_key)
		if("C")
			toggle_combat_mode()
			return
	return ..()
