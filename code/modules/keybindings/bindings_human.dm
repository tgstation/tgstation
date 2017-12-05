/mob/living/carbon/human/key_down(_key, client/user)
	switch(_key)
		if("E")
			quick_equip()
			return
	return ..()