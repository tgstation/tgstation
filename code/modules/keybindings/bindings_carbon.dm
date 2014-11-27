/mob/living/carbon/key_down(key, client/user)

	switch(key)
		if("soutwest", "r")
			toggle_throw_mode()
		if("northwest", "q")
			if(!get_active_hand())
				src << "<span class='warning'>You have nothing to drop in your hand!</span>"
			else
				drop_item()

		if("1")
			a_intent_change("help")
		if("2")
			a_intent_change("disarm")
		if("3")
			a_intent_change("grab")
		if("4")
			a_intent_change("harm")

	return ..()