/mob/living/silicon/robot/key_down(key, client/user)
	switch(key)
		if("1", "2", "3")
			cmd_toggle_module(text2num(key))
		if("4")
			a_intent_change("left")

		if("q", "northwest")
			cmd_unequip_module()

	return ..()