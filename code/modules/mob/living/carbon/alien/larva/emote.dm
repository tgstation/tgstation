<<<<<<< HEAD
/mob/living/carbon/alien/larva/emote(act,m_type=1,message = null)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()

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
		if ("deathgasp","deathgasps")
			message = "<span class='name'>[src]</span> lets out a sickly hiss of air and falls limply to the floor..."
			m_type = 2
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
		if ("me")
			..()
			return
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
			src << "Help for larva emotes. You can use these emotes with say \"*emote\":\n\nburp, choke, collapse, dance, deathgasp, drool, gasp, gnarl, hiss, jump, me, moan, nod, roll, roar, scratch, screech, shake, shiver, sign-#, sulk, sway, tail, twitch, whimper"

		else
			src << "<span class='info'>Unusable emote '[act]'. Say *help for a list.</span>"

	if ((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return
=======
/mob/living/carbon/alien/larva/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped) return //under effects of time magick
	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)
		if("me")
			if(silent)
				return
			if(src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if(src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if("custom")
			return custom_emote(m_type, message)
		if("sign")
			if(!src.restrained())
				message = text("<B>\The [src]</B> signs[(text2num(param) ? text(" the number []", text2num(param)) : null)].")
				m_type = VISIBLE
		if("burp")
			if(!muzzled)
				message = "<B>\The [src]</B> burps."
				m_type = HEARABLE
		if("scratch")
			if(!src.restrained())
				message = "<B>\The [src]</B> scratches."
				m_type = VISIBLE
		if("whimper")
			if(!muzzled)
				message = "<B>\The [src]</B> whimpers."
				m_type = HEARABLE
		if("tail")
			message = "<B>\The [src]</B> waves its tail."
			m_type = VISIBLE
		if("gasp")
			message = "<B>\The [src]</B> gasps."
			m_type = HEARABLE
		if("shiver")
			message = "<B>\The [src]</B> shivers."
			m_type = HEARABLE
		if("drool")
			message = "<B>\The [src]</B> drools."
			m_type = VISIBLE
		if("scretch")
			if(!muzzled)
				message = "<B>\The [src]</B> scretches."
				m_type = HEARABLE
		if("choke")
			message = "<B>\The [src]</B> chokes."
			m_type = HEARABLE
		if("moan")
			message = "<B>\The [src]</B> moans!"
			m_type = HEARABLE
		if("nod")
			message = "<B>\The [src]</B> nods its head."
			m_type = VISIBLE
		if("sway")
			message = "<B>\The [src]</B> sways around dizzily."
			m_type = VISIBLE
		if("sulk")
			message = "<B>\The [src]</B> sulks down sadly."
			m_type = VISIBLE
		if("twitch")
			message = "<B>\The [src]</B> twitches violently."
			m_type = VISIBLE
		if("dance")
			if(!src.restrained())
				message = "<B>\The [src]</B> dances around happily."
				m_type = VISIBLE
		if("roll")
			if(!src.restrained())
				message = "<B>\The [src]</B> rolls."
				m_type = VISIBLE
		if("shake")
			message = "<B>\The [src]</B> shakes its head."
			m_type = VISIBLE
		if("gnarl")
			if(!muzzled)
				message = "<B>\The [src]</B> gnarls and shows its teeth.."
				m_type = HEARABLE
		if("jump")
			message = "<B>\The [src]</B> jumps!"
			m_type = VISIBLE
		if("hiss_")
			message = "<B>\The [src]</B> hisses softly."
			m_type = VISIBLE
		if("collapse")
			Paralyse(2)
			message = text("<B>\The [src]</B> collapses!")
			m_type = HEARABLE
		if("help")
			to_chat(src, "burp, choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roll, scratch,\nscretch, shake, sign-#, sulk, sway, tail, twitch, whimper")
		else
//			to_chat(custom_emote(VISIBLE, act) src, text("Invalid Emote: [act]"))
	if((message && src.stat == 0))
		log_emote("[name]/[key] (@[x],[y],[z]): [message]")
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
