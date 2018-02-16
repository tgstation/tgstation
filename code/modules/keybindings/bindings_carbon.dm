/mob/living/carbon/key_down(_key, client/user)
	switch(_key)
		if("R", "Southwest") // Southwest is End
			toggle_throw_mode()
			return
		if("1")
			a_intent_change("help")
			return
		if("2")
			a_intent_change("disarm")
			return
		if("3")
			a_intent_change("grab")
			return
		if("4")
			a_intent_change("harm")
			return
	return ..()