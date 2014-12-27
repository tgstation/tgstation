#define VISIBLE 1
#define VOCAL 2
//This only assumes that the mob has a body and face with at least one mouth.
//Things like airguitar can be done without arms, and the flap thing makes so little sense it's a keeper.
//Intended to be called by a higher up emote proc if the requested emote isn't in the custom emotes.

/mob/living/emote_special(inputtext)
	var/param = null
	if(findtext(inputtext, "-", 1, null))
		var/t1 = findtext(inputtext, "-", 1, null)
		param = copytext(inputtext, t1 + 1, length(inputtext) + 1)
		inputtext = copytext(inputtext, 1, t1)

	if(findtext(inputtext,"s",-1) && !findtext(inputtext,"_",-2)) //Removes ending s's unless they are prefixed with a '_'
		inputtext = copytext(inputtext,1,length(inputtext))

	var/list/emotelist = handle_emote_special(inputtext, param)

	send_emote_special(emotelist[1], emotelist[2], emotelist[3])

/mob/living/proc/send_emote_special(m_type, message, message_alt)
	if(message)
		if(m_type & 1)
			visible_message(message)
		else if(m_type & 2)
			if(is_muzzled())
				message = alt_message
			var/turf/T = get_turf(src)
			T.audible_message(message)

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && (get_dist(src, M) > 7))
				M.show_message(message)

		log_emote("[name]/[key] : [message]")

/mob/living/proc/handle_emote_special(act, param)
	var/m_type
	var/message
	var/message_alt

	switch(act)//Hello, how would you like to order? Alphabetically! //not copypasted for each mob seperately, please.
		if ("aflap")
			if (!restrained())
				message = "<span class='name'>[src]</span> flaps its wings ANGRILY!"
				m_type = VISIBLE

		if ("airguitar")
			if (!restrained())
				message = "<span class='name'>[src]</span> is strumming the air and headbanging like a safari chimp."
				m_type = VISIBLE

		if ("blush")
			message = "<span class='name'>[src]</span> blushes."
			m_type = VISIBLE

		if ("bow")
			if (!buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(7, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<span class='name'>[src]</span> bows to [param]."
				else
					message = "<span class='name'>[src]</span> bows."
			m_type = VISIBLE

		if ("burp")
			message = "<span class='name'>[src]</span> burps."
			message_alt = "<B>[src]</B> makes a strong noise."
			m_type = VOCAL

		if ("choke")
			message = "<span class='name'>[src]</span> chokes!"
			m_type = VOCAL

		if ("chuckle")
			message = "<span class='name'>[src]</span> chuckles."
			message = "<B>[src]</B> makes a noise."
			m_type = VOCAL

		if ("collapse")
			Paralyse(2)
			message = "<span class='name'>[src]</span> collapses!"
			m_type = VOCAL

		if ("cough")
			message = "<span class='name'>[src]</span> coughs!"
			m_type = VOCAL

		if ("dance")
			if (!restrained())
				message = "<span class='name'>[src]</span> dances around happily."
				m_type = VISIBLE

		if ("deathgasp")
			message = "<span class='name'>[src]</span> seizes up and falls limp, its eyes dead and lifeless..."
			m_type = VISIBLE

		if ("drool")
			message = "<span class='name'>[src]</span> drools."
			m_type = VISIBLE

		if ("faint")
			message = "<span class='name'>[src]</span> faints."
			if(sleeping)
				return //Can't faint while asleep
			sleeping += 10 //Short-short nap
			m_type = VISIBLE

		if ("flap")
			if (!restrained())
				message = "<span class='name'>[src]</span> flaps its wings."
				m_type = VISIBLE

		if ("frown")
			message = "<span class='name'>[src]</span> frowns."
			m_type = VISIBLE

		if ("gasp")
			message = "<span class='name'>[src]</span> gasps!"
			message_alt = "<B>[src]</B> makes a weak noise."
			m_type = VOCAL

		if ("giggle")
			message = "<span class='name'>[src]</span> giggles."
			message_alt = "<B>[src]</B> makes a noise."
			m_type = VOCAL

		if ("glare")
			m_type = VISIBLE
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<span class='name'>[src]</span> glares at [param]."
			else
				message = "<span class='name'>[src]</span> glares."

		if ("grin")
			message = "<span class='name'>[src]</span> grins."
			m_type = VISIBLE

		if ("jump")
			message = "<span class='name'>[src]</span> jumps!"
			m_type = VISIBLE

		if ("laugh")
			message = "<span class='name'>[src]</span> laughs."
			message_alt = "<B>[src]</B> makes a noise."
			m_type = VOCAL

		if ("look")
			m_type = VISIBLE
			var/M = null
			if (param)
				for (var/mob/A in view(7, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<span class='name'>[src]</span> looks at [param]."
			else
				message = "<span class='name'>[src]</span> looks."

		if ("me")
			if(src.client)
				if(client.prefs.muted & MUTE_IC)
					src << "You cannot send IC messages (muted)."
					return 0
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return 0
			me_verb(param)
			return 0

		if ("nod")
			message = "<span class='name'>[src]</span> nods."
			m_type = VISIBLE

		if ("point")
			if (!restrained())
				var/atom/M = null
				if (param)
					for (var/atom/A as mob|obj|turf in view())
						if (param == A.name)
							M = A
							break
				if (!M)
					message = "<span class='name'>[src]</span> points."
				else
					pointed(M)
			m_type = VISIBLE

		if ("scream")
			message = "<span class='name'>[src]</span> screams!"
			message_alt = "<span class='name'>[src]</span> lets out a muffled scream!"
			m_type = VOCAL

		if ("shake")
			message = "<span class='name'>[src]</span> shakes its head."
			m_type = VISIBLE

		if ("sigh")
			message = "<span class='name'>[src]</span> sighs."
			m_type = VOCAL

		if ("sit")
			message = "<span class='name'>[src]</span> sits down."
			m_type = VISIBLE

		if ("smile")
			message = "<span class='name'>[src]</span> smiles."
			m_type = VISIBLE

		if ("sneeze")
			message = "<span class='name'>[src]</span> sneezes."
			message_alt = "<B>[src]</B> makes a weak noise."
			m_type = VOCAL

		if ("sniff")
			message = "<span class='name'>[src]</span> sniffs."
			m_type = VOCAL

		if ("snore")
			message = "<span class='name'>[src]</span> snores."
			m_type = VOCAL

		if ("stare")
			m_type = VISIBLE
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<span class='name'>[src]</span> stares at [param]."
			else
				message = "<span class='name'>[src]</span> stares."

		if ("sulk")
			message = "<span class='name'>[src]</span> sulks down sadly."
			m_type = VISIBLE

		if ("sway")
			message = "<span class='name'>[src]</span> sways around dizzily."
			m_type = VISIBLE

		if ("tremble")
			message = "<span class='name'>[src]</span> trembles in fear!"
			m_type = VISIBLE

		if ("twitch")
			message = "<span class='name'>[src]</span> twitches violently."
			m_type = VISIBLE

		if ("twitch_s")
			message = "<span class='name'>[src]</span> twitches."
			m_type = VISIBLE

		if ("wave")
			message = "<span class='name'>[src]</span> waves."
			m_type = VISIBLE

		if ("whimper")
			message = "<span class='name'>[src]</span> whimpers."
			message_alt = "<B>[src]</B> makes a weak noise."
			m_type = VOCAL

		if ("wink")
			message = "<B>[src]</B> winks."
			m_type = VISIBLE

		if ("yawn")
			message = "<span class='name'>[src]</span> yawns."
			message_alt = "<B>[src]</B> makes a weak noise."
			m_type = VOCAL

		if ("help")
			src << "Help for emotes. You can use these emotes with say \"*emote\":\n\naflap, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough, dance, deathgasp, drool, flap, frown, gasp, giggle, glare-(none)/mob, grin, jump, laugh, look, me, nod, point-atom, scream, shake, sigh, sit, smile, sneeze, sniff, snore, stare-(none)/mob, sulk, sway, tremble, twitch, twitch_s, wave, whimper, yawn"

		else
			src << "<span class='notice'>Unusable emote: '[act]'. Say *help for a list.</span>"

		if(!message_alt)
			message_alt = message

		if(message && m_type)
			return list(m_type, message, message_alt)
