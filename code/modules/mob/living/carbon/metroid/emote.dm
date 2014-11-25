/mob/living/carbon/slime/emote(var/act,var/m_type=1,var/message = null)


	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					src << "\red You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)
		if("bounce")
			message = "<B>The [src.name]</B> bounces in place."
			m_type = VISIBLE

		if("jiggle")
			message = "<B>The [src.name]</B> jiggles!"
			m_type = VISIBLE

		if("light")
			message = "<B>The [src.name]</B> lights up for a bit, then stops."
			m_type = VISIBLE

		if("moan")
			message = "<B>The [src.name]</B> moans."
			m_type = HEARABLE

		if("shiver")
			message = "<B>The [src.name]</B> shivers."
			m_type = HEARABLE

		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = VISIBLE

		if("twitch")
			message = "<B>The [src.name]</B> twitches."
			m_type = VISIBLE

		if("vibrate")
			message = "<B>The [src.name]</B> vibrates!"
			m_type = VISIBLE

		if ("help") //This is an exception
			src << "Help for slime emotes. You can use these emotes with say \"*emote\":\n\nbounce, jiggle, light, moan, shiver, sway, twitch, vibrate"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."
	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return