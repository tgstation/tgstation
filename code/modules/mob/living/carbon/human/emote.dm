/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	//var/m_type = 1

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(src.stat == 2.0 && (act != "deathgasp"))
		return
	switch(act)
		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = 1

		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
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

		if ("custom")
			var/input = copytext(sanitize(input("Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
			if (!input)
				return
			if(copytext(input,1,5) == "says")
				src << "\red Invalid emote."
				return
			else if(copytext(input,1,9) == "exclaims")
				src << "\red Invalid emote."
				return
			else if(copytext(input,1,5) == "asks")
				src << "\red Invalid emote."
				return
			else
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					if (src.miming)
						return
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
				message = "<B>[src]</B> [input]"

		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.muted & MUTE_IC)
					src << "\red You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			if(copytext(message,1,5) == "says")
				src << "\red Invalid emote."
				return
			else if(copytext(message,1,9) == "exclaims")
				src << "\red Invalid emote."
				return
			else if(copytext(message,1,5) == "asks")
				src << "\red Invalid emote."
				return
			else
				message = "<B>[src]</B> [message]"

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

		if ("choke")
			if(miming)
				message = "<B>[src]</B> clutches his throat desperately!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> chokes!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
				if(miming)
					m_type = 1
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2
				if(miming)
					m_type = 1

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2
				if(miming)
					m_type = 1

		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = 1

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if ("chuckle")
			if(miming)
				message = "<B>[src]</B> appears to chuckle."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> chuckles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("faint")
			message = "<B>[src]</B> faints."
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		if ("cough")
			if(miming)
				message = "<B>[src]</B> appears to cough!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> coughs!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if ("frown")
			message = "<B>[src]</B> frowns."
			m_type = 1

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("blush")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if ("wave")
			message = "<B>[src]</B> waves."
			m_type = 1

		if ("gasp")
			if(miming)
				message = "<B>[src]</B> appears to be gasping!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> gasps!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = 1

		if ("giggle")
			if(miming)
				message = "<B>[src]</B> giggles silently!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> giggles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

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
			m_type = 1

		if ("grin")
			message = "<B>[src]</B> grins."
			m_type = 1

		if ("cry")
			if(miming)
				message = "<B>[src]</B> cries."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> cries."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise. \He frowns."
					m_type = 2

		if ("sigh")
			if(miming)
				message = "<B>[src]</B> sighs."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> sighs."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("laugh")
			if(miming)
				message = "<B>[src]</B> acts out a laugh."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> laughs."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("mumble")
			message = "<B>[src]</B> mumbles!"
			m_type = 2
			if(miming)
				m_type = 1

		if ("grumble")
			if(miming)
				message = "<B>[src]</B> grumbles!"
				m_type = 1
			if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("groan")
			if(miming)
				message = "<B>[src]</B> appears to groan!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> groans!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a loud noise."
					m_type = 2

		if ("moan")
			if(miming)
				message = "<B>[src]</B> appears to moan!"
				m_type = 1
			else
				message = "<B>[src]</B> moans!"
				m_type = 2

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if(miming)
					message = "<B>[src]</B> takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = 1
				else
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
					m_type = 2

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					M.point()

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("raise")
			if (!src.restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1

		if("shake")
			message = "<B>[src]</B> shakes \his head."
			m_type = 1

		if ("shrug")
			message = "<B>[src]</B> shrugs."
			m_type = 1

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile")
			message = "<B>[src]</B> smiles."
			m_type = 1

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2
			if(miming)
				m_type = 1

		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1

		if ("sneeze")
			if (miming)
				message = "<B>[src]</B> sneezes."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> sneezes."
					m_type = 2
				else
					message = "<B>[src]</B> makes a strange noise."
					m_type = 2

		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2
			if(miming)
				m_type = 1

		if ("snore")
			if (miming)
				message = "<B>[src]</B> sleeps soundly."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> snores."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("whimper")
			if (miming)
				message = "<B>[src]</B> appears hurt."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> whimpers."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("wink")
			message = "<B>[src]</B> winks."
			m_type = 1

		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2
				if(miming)
					m_type = 1

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs \himself."

		if ("handshake")
			m_type = 1
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out \his hand to [M]."

		if("daps")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if ("scream")
			if (miming)
				message = "<B>[src]</B> acts out a scream!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> screams!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a very loud noise."
					m_type = 2

		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."





	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if (!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == 2 && M.client.ghost_sight && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)

