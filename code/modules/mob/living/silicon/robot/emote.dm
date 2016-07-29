<<<<<<< HEAD
/mob/living/silicon/emote(act,m_type=1,message = null)
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	switch(act)//01000001011011000111000001101000011000010110001001100101011101000110100101111010011001010110010000100001 (Seriously please keep it that way.)
		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings ANGRILY!"
				m_type = 2
			m_type = 1

		if("beep","beeps")
			var/M = null
			if(param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = 2

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

		if ("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = 2

		if ("buzz2")
			message = "<B>[src]</B> buzzes twice."
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
			m_type = 2

		if ("boop","boops")
			message = "<B>[src]</B> boops."
			m_type = 2

		if ("chime","chimes") //You have mail!
			message = "<B>[src]</B> chimes."
			playsound(loc, 'sound/machines/chime.ogg', 50, 0)
			m_type = 2

		if ("clap","claps")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2

		if ("custom")
			if(jobban_isbanned(src, "emote"))
				src << "You cannot send custom emotes (banned)"
				return
			if(src.client)
				if(client.prefs.muted & MUTE_IC)
					src << "You cannot send IC messages (muted)."
					return
			var/input = copytext(sanitize(input("Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"

		if ("deathgasp","deathgasps")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = 1

		if ("flap","flaps")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings."
				m_type = 2

		if ("glare","glares")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("honk","honks") //Honk!
			message = "<B>[src]</B> honks!"
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			m_type = 2

		if ("look","looks")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."

		if ("me")
			if(jobban_isbanned(src, "emote"))
				src << "You cannot send custom emotes (banned)"
				return
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					src << "You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				message = "<B>[src]</B> [message]"

		if ("nod","nods")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("ping","pings")
			var/M = null
			if(param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null
			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			m_type = 2

		if ("sad") //When words cannot express...
			message = "<B>[src]</B> plays a sad trombone."
			playsound(loc, 'sound/misc/sadtrombone.ogg', 50, 0)
			m_type = 2

		if ("salute","salutes")
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
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."

		if ("stare","stares")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."
			m_type = 1

		if ("twitch","twitches")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("warn") //HUMAN HARM DETECTED. PLEASE DIE IN AN ORDERLY FASHION.
			message = "<B>[src]</B> blares an alarm!"
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 0)
			m_type = 2

		if ("help")
			src << "Help for cyborg emotes. You can use these emotes with say \"*emote\":\n\naflap, beep-(none)/mob, bow-(none)/mob, buzz-(none)/mob,buzz2,chime, clap, custom, deathgasp, flap, glare-(none)/mob, honk, look-(none)/mob, me, nod, ping-(none)/mob, sad, \nsalute-(none)/mob, twitch, twitch_s, warn,"

		else
			src << "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>"

	if (message && src.stat == CONSCIOUS)
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			visible_message(message)
		else
			audible_message(message)
	return

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(!cell || !cell.charge)
		visible_message("The power warning light on <span class='name'>[src]</span> flashes urgently.",\
						 "You announce you are operating in low power mode.")
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
	else
		src << "<span class='warning'>You can only use this emote when you're out of charge.</span>"
=======
/mob/living/silicon/robot/emote(var/act,var/m_type=1,var/message = null, var/auto)
	if(timestopped) return //under effects of time magick
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "You cannot send IC messages (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)

		if ("salute")
			if (!src.locked_to)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = VISIBLE
		if ("bow")
			if (!src.locked_to)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = VISIBLE

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = HEARABLE
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = HEARABLE

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = HEARABLE

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = VISIBLE

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = VISIBLE

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = VISIBLE

		if ("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = VISIBLE

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = VISIBLE

		if("beep")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 0)
			m_type = VISIBLE

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)
			m_type = VISIBLE

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = VISIBLE

		if("law")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(get_turf(src), 'sound/voice/biamthelaw.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not THE LAW, pal.")

		if("halt")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(get_turf(src), 'sound/voice/halt.ogg', 50, 0)
				m_type = HEARABLE
			else
				to_chat(src, "You are not security.")

		/*
		if ("fart")
			var/list/robotfarts = list("makes a farting noise","vents excess methane","shakes violently, then vents methane.")
			var/robofart = pick(robotfarts)
			message = "<B>[src]</B> [robofart]."
			m_type = VISIBLE

		*/

		if ("help")
			to_chat(src, "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitch_s, nod, deathgasp, glare-(none)/mob, stare-(none)/mob, look, beep, ping, \nbuzz, law, halt")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
