/mob/living/carbon/brain/emote(var/act,var/m_type=1,var/message = null)
	if(!(container && istype(container, /obj/item/device/mmi)))//No MMI, no emotes
		return

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		act = copytext(act, 1, t1)

	if(src.stat == DEAD)
		return
	switch(act)
		if ("alarm")
			src << "You sound an alarm."
			message = "<B>[src]</B> sounds an alarm."
			m_type = 2
		if ("alert")
			src << "You let out a distressed noise."
			message = "<B>[src]</B> lets out a distressed noise."
			m_type = 2
		if ("notice")
			src << "You play a loud tone."
			message = "<B>[src]</B> plays a loud tone."
			m_type = 2
		if ("flash")
			message = "The lights on <B>[src]</B> flash quickly."
			m_type = 1
		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = 1
		if ("whistle")
			src << "You whistle."
			message = "<B>[src]</B> whistles."
			m_type = 2
		if ("beep")
			src << "You beep."
			message = "<B>[src]</B> beeps."
			m_type = 2
		if ("boop")
			src << "You boop."
			message = "<B>[src]</B> boops."
			m_type = 2
		if ("help")
			src << "alarm,alert,notice,flash,blink,whistle,beep,boop"
		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if (message)
		log_emote("[name]/[key] : [message]")

		for(var/mob/M in dead_mob_list)
			if (!M.client)
				continue //skip monkeys and leavers
			if(M.stat == 2 && M.client.ghost_sight && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)