/mob/living/carbon/slime/emote(var/act)


	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/m_type = 1
	var/message

	switch(act) //Alphabetical please
		if("bounce")
			message = "<B>The [src.name]</B> bounces in place."
			m_type = 1

		if("jiggle")
			message = "<B>The [src.name]</B> jiggles!"
			m_type = 1

		if("light")
			message = "<B>The [src.name]</B> lights up for a bit, then stops."
			m_type = 1

		if("moan")
			message = "<B>The [src.name]</B> moans."
			m_type = 2

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