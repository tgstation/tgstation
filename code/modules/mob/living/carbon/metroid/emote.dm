/mob/living/carbon/alien/larva/emote(var/act)


	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/m_type = 1
	var/message

	switch(act)
		if ("burp")
			message = "<B>The [src]</B> burps."
			m_type = 2
		if("scratch")
			if (!src.restrained())
				message = "<B>The [src.name]</B> scratches."
				m_type = 1
		if("whimper")
			message = "<B>The [src.name]</B> whimpers."
			m_type = 2
//		if("roar")
//			if (!muzzled)
//				message = "<B>The [src.name]</B> roars." Commenting out since larva shouldn't roar /N
//				m_type = 2
		if("gasp")
			message = "<B>The [src.name]</B> gasps."
			m_type = 2
		if("shiver")
			message = "<B>The [src.name]</B> shivers."
			m_type = 2
		if("drool")
			message = "<B>The [src.name]</B> drools."
			m_type = 1
		if("scretch")
			message = "<B>The [src.name]</B> scretches."
			m_type = 2
		if("choke")
			message = "<B>The [src.name]</B> chokes."
			m_type = 2
		if("moan")
			message = "<B>The [src.name]</B> moans!"
			m_type = 2
		if("nod")
			message = "<B>The [src.name]</B> nods its head."
			m_type = 1
		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = 1
		if("sulk")
			message = "<B>The [src.name]</B> sulks down sadly."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> twitches violently."
			m_type = 1
		if("shake")
			message = "<B>The [src.name]</B> shakes its head."
			m_type = 1
		if("jump")
			message = "<B>The [src.name]</B> jumps!"
			m_type = 1
		else
			src << text("Invalid Emote: []", act)
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