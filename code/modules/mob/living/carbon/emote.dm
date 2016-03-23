//This only assumes that the mob has a body and face with at least one eye, and one mouth.
//Things like airguitar can be done without arms, and the flap thing makes so little sense it's a keeper.
//Intended to be called by a higher up emote proc if the requested emote isn't in the custom emotes.

/mob/living/carbon/emote(act,m_type=1,message = null)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()
	//var/m_type = 1

	switch(act)//Even carbon organisms want it alphabetically ordered..
		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings ANGRILY!"
				m_type = 2

		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if ("blink","blinks")
			message = "<B>[src]</B> blinks."
			m_type = 1

		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1

		if ("blush","blushes")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if ("bow","bows")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = 1

		if ("burp","burps")
			if (!muzzled)
				..(act)

		if ("choke","chokes")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2

		if ("chuckle","chuckles")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("clap","claps")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2

		if ("cough","coughs")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2

		if ("deathgasp","deathgasps")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = 1

		if ("flap","flaps")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings."
				m_type = 2

		if ("gasp","gasps")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2

		if ("giggle","giggles")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("laugh","laughs")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a noise."

		if ("me")
			if(!silent)
				..()
			return

		if ("nod","nods")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("scream","screams")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a very loud noise."
				m_type = 2

		if ("shake","shakes")
			message = "<B>[src]</B> shakes \his head."
			m_type = 1

		if ("sneeze","sneezes")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a strange noise."
				m_type = 2

		if ("sigh","sighs")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> sighs."
				m_type = 2

		if ("sniff","sniffs")
			message = "<B>[src]</B> sniffs."
			m_type = 2

		if ("snore","snores")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("whimper","whimpers")
			if (!muzzled)
				..(act)
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2

		if ("wink","winks")
			message = "<B>[src]</B> winks."
			m_type = 1

		if ("yawn","yawns")
			if (!muzzled)
				..(act)

		if ("help")
			src << "Help for emotes. You can use these emotes with say \"*emote\":\n\naflap, airguitar, blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough, dance, deathgasp, drool, flap, frown, gasp, giggle, glare-(none)/mob, grin, jump, laugh, look, me, nod, point-atom, scream, shake, sigh, sit, smile, sneeze, sniff, snore, stare-(none)/mob, sulk, sway, tremble, twitch, twitch_s, wave, whimper, wink, yawn"

		else
			..(act)





	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			visible_message(message)
		else if (m_type & 2)
			audible_message(message)
