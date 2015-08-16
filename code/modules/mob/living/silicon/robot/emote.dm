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

		if ("chime","chimes") //You have mail!
			message = "<B>[src]</B> chimes."
			playsound(loc, 'sound/machines/chime.ogg', 50, 0)
			m_type = 2

		if ("clap","claps")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2

		if ("custom")
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
