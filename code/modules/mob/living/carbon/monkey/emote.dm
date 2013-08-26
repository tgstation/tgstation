/mob/living/carbon/monkey/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1
	var/message

	switch(act) //Ooh ooh ah ah keep this alphabetical ooh ooh ah ah!
		if ("choke")
			message = "<B>[src]</B> chokes."
			m_type = 2

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2

		if ("dance")
			if (!src.restrained())
				message = "<B>[src]</B> dances around happily."
				m_type = 1

		if ("deathgasp")
			message = "<b>[src]</b> lets out a faint chimper as it collapses and stops moving..."
			m_type = 1

		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = 1

		if ("gasp")
			message = "<B>[src]</B> gasps."
			m_type = 2

		if ("gnarl")
			if (!muzzled)
				message = "<B>[src]</B> gnarls and shows its teeth.."
				m_type = 2

		if ("giggle")
			if (!muzzled)
				message = "<B>[src]</B> giggles happily."
				m_type = 2

		if ("jump")
			message = "<B>[src]</B> jumps!"
			m_type = 1

		if ("paw")
			if (!src.restrained())
				message = "<B>[src]</B> flails its paw."
				m_type = 1

		if ("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2

		if ("nod")
			message = "<B>[src]</B> nods its head."
			m_type = 1

		if ("roar")
			if (!muzzled)
				message = "<B>[src]</B> roars."
				m_type = 2

		if ("roll")
			if (!src.restrained())
				message = "<B>[src]</B> rolls."
				m_type = 1

		if ("scratch")
			if (!src.restrained())
				message = "<B>[src]</B> scratches."
				m_type = 1

		if ("scretch")
			if (!muzzled)
				message = "<B>[src]</B> scretches."
				m_type = 2

		if ("shake")
			message = "<B>[src]</B> shakes its head."
			m_type = 1

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2

		if ("sign")
			if (!src.restrained())
				message = text("<B>[src]</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1

		if ("sit")
			message = "<B>[src]</B> sits down."
			m_type = 1

		if ("sulk")
			message = "<B>[src]</B> sulks down sadly."
			m_type = 1

		if ("sway")
			message = "<B>[src]</B> sways around dizzily."
			m_type = 1

		if ("tail")
			message = "<B>[src]</B> waves its tail."
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("whimper")
			if (!muzzled)
				message = "<B>[src]</B> whimpers."
				m_type = 2

		if ("help") //Ooh ah ooh ooh this is an exception to alphabetical ooh ooh.
			src << "Help for monkey emotes. You can use these emotes with say \"*emote\":\nchoke, collapse, dance, deathgasp, drool, gasp, gnarl, giggle, jump, paw, moan, nod, roar, roll, scratch, scretch, \nshake, shiver, sign-#, sit, sulk, sway, tail, twitch, whimper"
		else
			src << text("Invalid Emote: []", act)
	if ((message && src.stat == 0))
		if(src.client)
			log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return
