/mob/living/silicon/robot/emote(var/act,var/m_type=1,var/message = null)
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	switch(act)
		if ("salute")
			if (!src.buckled)
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
			m_type = 1
		if ("bow")
			if (!src.buckled)
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
			m_type = 1

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
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

		if ("me")
			if(silent)
				return
			if (src.client && (client.muted || client.muted_complete))
				src << "You are muted."
				return
			if (stat)
				return
			if(!(message))
				return
			else
				if(cmptext(copytext(message, 1, 3), "v "))
					message = "<B>[src]</B> [copytext(message, 3)]"
					m_type = 1
				else if(cmptext(copytext(message, 1, 3), "h "))
					message = "<B>[src]</B> [copytext(message, 3)]"
					m_type = 2
				else
					message = "<B>[src]</B> [message]"
		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = 1

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
			m_type = 1

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
			m_type = 1

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
			m_type = 1

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
			playsound(src.loc, 'twobeep.ogg', 50, 0)
			m_type = 2

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
			playsound(src.loc, 'ping.ogg', 50, 0)
			m_type = 2

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
			playsound(src.loc, 'buzz-sigh.ogg', 50, 0)
			m_type = 2

		if("law")
			message = "<B>[src]</B> shows its legal authorization barcode."

			playsound(src.loc, 'biamthelaw.ogg', 50, 0)
			m_type = 2



		if("help")
			src << "beep-(none)/mob, ping-(none)/mob, buzz-(none)/mob, look-(none)/mob, stare-(none)/mob, glare-(none)/mob, twitch, twitch_s, law"

		else
			src << text("Invalid Emote: []", act)
	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return