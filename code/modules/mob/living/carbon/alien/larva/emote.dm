/mob/living/carbon/alien/larva/emote(var/act,var/m_type=1,var/message = null)

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
					src << "<span class='warning'>You cannot send IC messages (muted).</span>"
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
			src << "burp, choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roll, scratch,\nscretch, shake, sign-#, sulk, sway, tail, twitch, whimper"
		else
			src << text("Invalid Emote: [act]")
	if((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return