/mob/living/carbon/monkey/emote(act,m_type=1,message = null)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()

	switch(act) //Ooh ooh ah ah keep this alphabetical ooh ooh ah ah!
		if ("deathgasp","deathgasps")
			message = "<b>[src]</b> lets out a faint chimper as it collapses and stops moving..."
			m_type = 1

		if ("gnarl","gnarls")
			if (!muzzled)
				message = "<B>[src]</B> gnarls and shows its teeth.."
				m_type = 2

		if ("me")
			..()
			return

		if ("moan","moans")
			message = "<B>[src]</B> moans!"
			m_type = 2

		if ("paw")
			if (!src.restrained())
				message = "<B>[src]</B> flails its paw."
				m_type = 1

		if ("roar","roars")
			if (!muzzled)
				message = "<B>[src]</B> roars."
				m_type = 2

		if ("roll","rolls")
			if (!src.restrained())
				message = "<B>[src]</B> rolls."
				m_type = 1

		if ("scratch","scratches")
			if (!src.restrained())
				message = "<B>[src]</B> scratches."
				m_type = 1

		if ("screech","screeches")
			if (!muzzled)
				message = "<B>[src]</B> screeches."
				m_type = 2

		if ("shiver","shivers")
			message = "<B>[src]</B> shivers."
			m_type = 2

		if ("sign","signs")
			if (!src.restrained())
				message = text("<B>[src]</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1

		if ("tail")
			message = "<B>[src]</B> waves its tail."
			m_type = 1

		if ("help") //Ooh ah ooh ooh this is an exception to alphabetical ooh ooh.
			src << "Help for monkey emotes. You can use these emotes with say \"*emote\":\n\naflap, airguitar, blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough, dance, deathgasp, drool, flap, frown, gasp, gnarl, giggle, glare-(none)/mob, grin, jump, laugh, look, me, moan, nod, paw, point-(atom), roar, roll, scream, scratch, screech, shake, shiver, sigh, sign-#, sit, smile, sneeze, sniff, snore, stare-(none)/mob, sulk, sway, tail, tremble, twitch, twitch_s, wave whimper, wink, yawn"

		else
			..()

	if ((message && src.stat == 0))
		if(src.client)
			log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return
