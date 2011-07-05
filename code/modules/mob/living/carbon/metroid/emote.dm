/mob/living/carbon/metroid/emote(var/act)


	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/m_type = 1
	var/message

	switch(act)
		if("moan")
			message = "<B>The [src.name]</B> moans."
			m_type = 2
//		if("roar")
//			if (!muzzled)
//				message = "<B>The [src.name]</B> roars." Commenting out since larva shouldn't roar /N
//				m_type = 2

		if("shiver")
			message = "<B>The [src.name]</B> shivers."
			m_type = 2
		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> twitches."
			m_type = 1
		if("vibrate")
			message = "<B>The [src.name]</B> vibrates!"
			m_type = 1
		if("light")
			message = "<B>The [src.name]</B> lights up for a bit, then stops."
			m_type = 1
		if("click")
			message = "<B>The [src.name]</B> makes a clicking noise!"
			m_type = 1
		if("chatter")
			message = "<B>The [src.name]</B> makes a noisy chattering sound!"
			m_type = 1
		if("growl")
			message = "<B>The [src.name]</B> growls!"
			m_type = 1
		if("shriek")
			message = "<B>The [src.name]</B> makes a high-pitched shriek!"
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