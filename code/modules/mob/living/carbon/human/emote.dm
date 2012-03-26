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
			var/input = input("Choose an emote to display.") as text|null
			if (!input)
				return
			input = sanitize(input)
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
			if (src.client && (client.muted || client.muted_complete))
				src << "You are muted."
				return
			if (stat)
				return
			if(!(message))
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
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2

		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = 1

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if ("chuckle")
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
			src.sleeping = 1
			m_type = 1

		if ("cough")
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
			if (!muzzled)
				message = "<B>[src]</B> cries."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise. \He frowns."
				m_type = 2

		if ("sigh")
			if (!muzzled)
				message = "<B>[src]</B> sighs."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2

		if ("laugh")
			if (!muzzled)
				message = "<B>[src]</B> laughs."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("mumble")
			message = "<B>[src]</B> mumbles!"
			m_type = 2

		if ("grumble")
			if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("groan")
			if (!muzzled)
				message = "<B>[src]</B> groans!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a loud noise."
				m_type = 2

		if ("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
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

		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1

		if ("sneeze")
			if (!muzzled)
				message = "<B>[src]</B> sneezes."
				m_type = 2
			else
				message = "<B>[src]</B> makes a strange noise."
				m_type = 2

		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2

		if ("snore")
			if (!muzzled)
				message = "<B>[src]</B> snores."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("whimper")
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

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2

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
			if (!muzzled)
				message = "<B>[src]</B> screams!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a very loud noise."
				m_type = 2

		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"

		if ("fart")
			if(isAprilFools())
				var/gtext = "his"
				if(gender == FEMALE)
					gtext = "her"
				switch(rand(1, 48))
					if(1)
						message = "<B>[src]</B> lets out a girly little 'toot' from [gtext] butt."

					if(2)
						message = "<B>[src]</B> farts loudly!"

					if(3)
						message = "<B>[src]</B> lets one rip!"

					if(4)
						message = "<B>[src]</B> farts! It sounds wet and smells like rotten eggs."

					if(5)
						message = "<B>[src]</B> farts robustly!"

					if(6)
						message = "<B>[src]</B> farted! It reminds you of your grandmother's queefs."

					if(7)
						message = "<B>[src]</B> queefed out [gtext] ass!"

					if(8)
						message = "<B>[src]</B> farted! It reminds you of your grandmother's queefs."

					if(9)
						message = "<B>[src]</B> farts a ten second long fart."

					if(10)
						message = "<B>[src]</B> groans and moans, farting like the world depended on it."

					if(11)
						message = "<B>[src]</B> breaks wind!"

					if(12)
						message = "<B>[src]</B> expels intestinal gas through the anus."

					if(13)
						message = "<B>[src]</B> release an audible discharge of intestinal gas."

					if(14)
						message = "\red <B>[src]</B> is a farting motherfucker!!!"

					if(15)
						message = "\red <B>[src]</B> suffers from flatulence!"

					if(16)
						message = "<B>[src]</B> releases flatus."

					if(17)
						message = "<B>[src]</B> releases gas generated in his digestive tract, [gtext] stomach and [gtext] intestines. \red<B>It stinks way bad!</B>"

					if(18)
						message = "<B>[src]</B> farts like your mom used to!"

					if(19)
						message = "<B>[src]</B> farts. It smells like Soylent Surprise!"

					if(20)
						message = "<B>[src]</B> farts. It smells like pizza!"

					if(21)
						message = "<B>[src]</B> farts. It smells like George Melons' perfume!"

					if(22)
						message = "<B>[src]</B> farts. It smells like atmos in here now!"

					if(23)
						message = "<B>[src]</B> farts. It smells like medbay in here now!"

					if(24)
						message = "<B>[src]</B> farts. It smells like the bridge in here now!"

					if(25)
						message = "<B>[src]</B> farts like a pubby!"

					if(26)
						message = "<B>[src]</B> farts like a goone!"

					if(27)
						message = "<B>[src]</B> farts so hard poop came out with it, but dares not look."

					if(28)
						message = "<B>[src]</B> farts delicately."

					if(29)
						message = "<B>[src]</B> farts timidly."

					if(30)
						message = "<B>[src]</B> farts very, very quietly. The stench is OVERPOWERING."

					if(31)
						message = "<B>[src]</B> farts and says, \"Mmm! Delightful aroma!\""

					if(32)
						message = "<B>[src]</B> farts and says, \"Mmm! Sexy!\""

					if(33)
						message = "<B>[src]</B> farts and fondles [gtext] own buttocks."

					if(34)
						message = "<B>[src]</B> farts and fondles YOUR buttocks."

					if(35)
						message = "<B>[src]</B> fart in [gtext] own mouth. A shameful [src]."

					if(36)
						message = "<B>[src]</B> farts out pure plasma! \red<B>FUCK!</B>"

					if(37)
						message = "<B>[src]</B> farts out pure oxygen. What the fuck did he eat?"

					if(38)
						message = "<B>[src]</B> breaks wind noisily!"

					if(39)
						message = "<B>[src]</B> releases gas with the power of the gods! The very station trembles!!"

					if(40)
						message = "<B>[src] \red f \blue a \black r \red t \blue s \black !</B>"

					if(41)
						message = "<B>[src] shat [gtext] pants!</B>"

					if(42)
						message = "<B>[src] shat [gtext] pants!</B> Oh, no, that was just a really nasty fart."

					if(43)
						message = "<B>[src]</B> is a flatulent whore."

					if(44)
						message = "<B>[src]</B> likes the smell of his own farts."

					if(45)
						message = "<B>[src]</B> doesnt wipe after he poops."

					if(46)
						message = "<B>[src]</B> farts! Now [gtext] ass smells like Uhangay."

					if(47)
						message = "<B>[src]</B> farts so loud [gtext] buttocks causes a gravity well in the spacetime continuum!"

					if(48)
						message = "<B>[src]</B> laughs and [gtext] breath smells like a fart."
				playsound(src.loc, 'poo2.ogg', 50, 1)

		if("piss", "pee", "tinkle")
			if(isAprilFools())
				if(src.urine < 3)
					if(src.gender == MALE)
						message = "<B>[src]</B> unzips his pants and waves his dick around."
					else
						message = "<B>[src]</B> lowers her pants and squats near the floor."

				else
					if((locate(/obj/machinery/disposal/toilet) in src.loc) && (src.buckled != null) && (src.poo >= 3))
						for(var/obj/machinery/disposal/toilet/T in src.loc)
							if(src.gender == MALE)
								message = "\blue <B>[src]</B> unzips his pants and urinates in the toilet."
							else
								message = "\blue <B>[src]</B> lowers her pants, sits on the toilet and urinates."
							src.urine -= 3
					else
						var/shat_on_other = 0
						for(var/mob/living/M in src.loc)
							if(M == src)
								continue
							message = "\red <B>[src]</B> pisses all over [M]!"
							shat_on_other = 1
							break
						if(!shat_on_other)
							message = pick("<B>[src]</B> pisses on the floor.", "<B>[src]</B> pisses all over the floor!", "<B>[src]</B> unzips their pants and pisses all over the floor.")
						src.urine -= 3
						src.loc.add_piss_floor(src)

		if("poo", "poop", "shit", "crap")
			if(isAprilFools())
				if(src.poo < 3)
					message = "<B>[src]</B> grunts for a moment. Nothing happens."
				else
					if((locate(/obj/machinery/disposal/toilet) in src.loc) && (src.buckled != null) && (src.poo >= 3))
						for(var/obj/machinery/disposal/toilet/T in src.loc)
							message = pick("<B>[src]</B> unzips their pants and poops in the toilet.", "<B>[src]</B> farts out a steamer.", "\blue THHBBBBBBBBBBBBBT!")
							playsound(src.loc, 'poo2.ogg', 50, 1)
							src.poo -= 3
					else if(istype(src.wear_suit, /obj/item/clothing/suit))
						message = pick("<B>[src]</B> shits in their pants!", "<B>[src]</B> poos in their suit!", "\blue THHHHHHBBBBBBBBT!")
						playsound(src.loc, 'poo2.ogg', 50, 1)
						src.poo -= 3
					else if(istype(src.w_uniform, /obj/item/clothing/under))
						message = pick("<B>[src]</B> shits in their pants!", "<B>[src]</B> poos in their suit!", "\blue THHHHHHBBBBBBBBT!")
						playsound(src.loc, 'poo2.ogg', 50, 1)
						src.poo -= 3
					else
						var/shat_on_other = 0
						for(var/mob/living/M in src.loc)
							if(M == src)
								continue
							message = "\red <B>[src]</B> shits all over [M]!"
							shat_on_other = 1
							break
						if(!shat_on_other)
							message = pick("<B>[src]</B> shits on the floor.", "<B>[src]</B> poops all over the floor!", "<B>[src]</B> squeezes out a turd.")
						src.poo -= 3
						src.loc.add_poo_floor(src)
						playsound(src.loc, 'poo2.ogg', 50, 1)

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if (message)
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)
	else
		src << "\blue Unusable emote '[act]'. Say *help for a list."
