/mob/living/carbon/brain/handle_emote_special(act, param)
	switch(act)
		if ("alarm")
			src << "You sound an alarm."
			message = "<B>[src]</B> sounds an alarm."
			m_type = VOCAL

		if ("alert")
			src << "You let out a distressed noise."
			message = "<B>[src]</B> lets out a distressed noise."
			m_type = VOCAL

		if ("beep")
			src << "You beep."
			message = "<B>[src]</B> beeps."
			m_type = VOCAL

		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = VISIBLE

		if ("boop")
			src << "You boop."
			message = "<B>[src]</B> boops."
			m_type = VOCAL

		if ("flash")
			message = "The lights on <B>[src]</B> flash quickly."
			m_type = VISIBLE

		if ("notice")
			src << "You play a loud tone."
			message = "<B>[src]</B> plays a loud tone."
			m_type = VOCAL

		if ("whistle")
			src << "You whistle."
			message = "<B>[src]</B> whistles."
			m_type = VOCAL

		if ("help")
			src << "Help for MMI emotes. You can use these emotes with say \"*emote\":\nalarm, alert, beep, blink, boop, flash, notice, whistle"

		else
			src << "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>"

		if(!message_alt)
			message_alt = message

		if(message && m_type)
			return list(m_type, message, message_alt)
