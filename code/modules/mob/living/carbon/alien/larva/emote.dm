/mob/living/carbon/alien/larva/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()
	var/m_type = 1
	var/message

	switch(act) //Alphabetically sorted please.
		if ("burp","burps")
			if (!muzzled)
				message = "<span class='name'>[src]</span> burps."
				m_type = 2
		if ("choke","chokes")
			message = "<span class='name'>[src]</span> chokes."
			m_type = 2
		if ("collapse","collapses")
			Paralyse(2)
			message = "<span class='name'>[src]</span> collapses!"
			m_type = 2
		if ("dance","dances")
			if (!src.restrained())
				message = "<span class='name'>[src]</span> dances around happily."
				m_type = 1
		if ("drool","drools")
			message = "<span class='name'>[src]</span> drools."
			m_type = 1
		if ("gasp","gasps")
			message = "<span class='name'>[src]</span> gasps."
			m_type = 2
		if ("gnarl","gnarls")
			if (!muzzled)
				message = "<span class='name'>[src]</span> gnarls and shows its teeth.."
				m_type = 2
		if ("hiss","hisses")
			message = "<span class='name'>[src]</span> hisses softly."
			m_type = 1
		if ("jump","jumps")
			message = "<span class='name'>[src]</span> jumps!"
			m_type = 1
		if ("moan","moans")
			message = "<span class='name'>[src]</span> moans!"
			m_type = 2
		if ("nod","nods")
			message = "<span class='name'>[src]</span> nods its head."
			m_type = 1
		if ("roar","roars")
			if (!muzzled)
				message = "<span class='name'>[src]</span> softly roars."
				m_type = 2
		if ("roll","rolls")
			if (!src.restrained())
				message = "<span class='name'>[src]</span> rolls."
				m_type = 1
		if ("scratch","scratches")
			if (!src.restrained())
				message = "<span class='name'>[src]</span> scratches."
				m_type = 1
		if ("screech","screeches") //This orignally was called scretch, changing it. -Sum99
			if (!muzzled)
				message = "<span class='name'>[src]</span> screeches."
				m_type = 2
		if ("shake","shakes")
			message = "<span class='name'>[src]</span> shakes its head."
			m_type = 1
		if ("shiver","shivers")
			message = "<span class='name'>[src]</span> shivers."
			m_type = 2
		if ("sign","signs")
			if (!src.restrained())
				message = text("<span class='name'>[src]</span> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1
		if ("snore","snores")
			message = "<B>[src]</B> snores."
			m_type = 2
		if ("sulk","sulks")
			message = "<span class='name'>[src]</span> sulks down sadly."
			m_type = 1
		if ("sway","sways")
			message = "<span class='name'>[src]</span> sways around dizzily."
			m_type = 1
		if ("tail")
			message = "<span class='name'>[src]</span> waves its tail."
			m_type = 1
		if ("twitch")
			message = "<span class='name'>[src]</span> twitches violently."
			m_type = 1
		if ("whimper","whimpers")
			if (!muzzled)
				message = "<span class='name'>[src]</span> whimpers."
				m_type = 2

		if ("help") //"The exception"
			src << "Help for larva emotes. You can use these emotes with say \"*emote\":\n\nburp, choke, collapse, dance, drool, gasp, gnarl, hiss, jump, moan, nod, roll, roar, scratch, screech, shake, shiver, sign-#, sulk, sway, tail, twitch, whimper"

		else
			src << "<span class='info'>Unusable emote '[act]'. Say *help for a list.</span>"

	if ((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return