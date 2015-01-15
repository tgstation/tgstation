/mob/living/carbon/alien/humanoid/emote(var/act)

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

	switch(act) //Alphabetical please
		if ("deathgasp")
			message = "<span class='name'>[src]</span> lets out a waning guttural screech, green blood bubbling from its maw..."
			m_type = 2

		if ("gnarl")
			if (!muzzled)
				message = "<span class='name'>[src]</span> gnarls and shows its teeth.."
				m_type = 2

		if ("hiss")
			if(!muzzled)
				message = "<span class='name'>[src]</span> hisses."
				m_type = 2

		if ("moan")
			message = "<span class='name'>[src]</span> moans!"
			m_type = 2

		if ("roar")
			if (!muzzled)
				message = "<span class='name'>[src]</span> roars."
				m_type = 2

		if ("roll")
			if (!src.restrained())
				message = "<span class='name'>[src]</span> rolls."
				m_type = 1

		if ("scratch")
			if (!src.restrained())
				message = "<span class='name'>[src]</span> scratches."
				m_type = 1

		if ("scretch")
			if (!muzzled)
				message = "<span class='name'>[src]</span> scretches."
				m_type = 2

		if ("shiver")
			message = "<span class='name'>[src]</span> shivers."
			m_type = 2

		if ("sign")
			if (!src.restrained())
				message = text("<span class='name'>[src]</span> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1

		if ("tail")
			message = "<span class='name'>[src]</span> waves its tail."
			m_type = 1

		if ("help") //This is an exception
			src << "Help for xenomorph emotes. You can use these emotes with say \"*emote\":\n\naflap, airguitar, blink, blink_r, blush, bow, burp, choke, chucke, clap, collapse, cough, dance, deathgasp, drool, flap, frown, gasp, giggle, glare-(none)/mob, gnarl, hiss, jump, laugh, look-atom, me, moan, nod, point-atom, roar, roll, scream, scratch, scretch, shake, shiver, sign-#, sit, smile, sneeze, sniff, snore, stare-(none)/mob, sulk, sway, tail, tremble, twitch, twitch_s, wave, whimper, wink, yawn"

		else
			..(act)

	if ((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if (act == "roar")
			playsound(src.loc, 'sound/voice/hiss5.ogg', 40, 1, 1)

		if (act == "deathgasp")
			playsound(src.loc, 'sound/voice/hiss6.ogg', 80, 1, 1)

		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return