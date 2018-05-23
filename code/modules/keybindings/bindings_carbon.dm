/mob/living/carbon/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_TOGGLETHROW)
			toggle_throw_mode()
			return
		if(ACTION_INTENTHELP)
			a_intent_change("help")
			return
		if(ACTION_INTENTDISARM)
			a_intent_change("disarm")
			return
		if(ACTION_INTENTGRAB)
			a_intent_change("grab")
			return
		if(ACTION_INTENTHARM)
			a_intent_change("harm")
			return

	return ..()