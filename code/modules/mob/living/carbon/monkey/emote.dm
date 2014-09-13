/mob/living/carbon/monkey/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = is_muzzled()
	var/m_type = 1
	var/message

	switch(act) //Ooh ooh ah ah keep this alphabetical ooh ooh ah ah!
		if ("deathgasp")
			message = "<b>[src]</b> lets out a faint chimper as it collapses and stops moving..."
			m_type = 1

		if ("gnarl")
			if (!muzzled)
				message = "<B>[src]</B> gnarls and shows its teeth.."
				m_type = 2

		if ("paw")
			if (!src.restrained())
				message = "<B>[src]</B> flails its paw."
				m_type = 1

		if ("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2

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

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2

		if ("sign")
			if (!src.restrained())
				message = text("<B>[src]</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1

		if ("tail")
			message = "<B>[src]</B> waves its tail."
			m_type = 1

		if ("help") //Ooh ah ooh ooh this is an exception to alphabetical ooh ooh.
			src << "Help for monkey emotes. You can use these emotes with say \"*emote\":\n\naflap, airguitar, blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough, dance, deathgasp, drool, flap, frown, gasp, gnarl, giggle, glare-(none)/mob, grin, jump, laugh, look, me, moan, nod, paw, point-(atom), roar, roll, scream, scratch, scretch, shake, shiver, sigh, sign-#, sit, smile, sneeze, sniff, snore, stare-(none)/mob, sulk, sway, tail, tremble, twitch, twitch_s, wave whimper, wink, yawn"

		else
			..(act)

	if ((message && src.stat == 0))
		if(src.client)
			log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return
