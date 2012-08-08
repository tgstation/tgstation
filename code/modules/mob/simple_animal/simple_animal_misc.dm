
/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = null
	..()

/mob/living/simple_animal/Bumped(AM as mob|obj)
	if(!AM) return
	if(isturf(src.loc) && !resting && !buckled)
		if(ismob(AM))
			var/newamloc = src.loc
			src.loc = AM:loc
			AM:loc = newamloc
		else
			..()

/mob/living/simple_animal/gib()
	if(meat_amount && meat_type)
		for(var/i = 0; i < meat_amount; i++)
			new meat_type(src.loc)
	..()

/mob/living/simple_animal/say_quote(var/text)
	if(speak_emote && speak_emote.len)
		var/emote = pick(speak_emote)
		if(emote)
			return "<b>[src]</b> [emote], \"[text]\""
	return "says, \"[text]\"";

//when talking, simple_animals can only understand each other
/mob/living/simple_animal/say(var/message)
	for(var/mob/M in view(src,7))
		if(istype(M, src.type) || M.universal_speak)
			M << say_quote(message)
		else
			M << "<b>[src]</b> [pick("makes some strange noises.","makes some strange noises.","makes some strange noises.","makes a small commotion.","kicks up a fuss about something.")]"
	return

//when talking, simple_animals can only understand each other
/mob/living/simple_animal/proc/say_auto(var/message)
	for(var/mob/M in view(src,7))
		M << "<b>[src]</b> [pick(speak_emote)], \"[message]\""

/mob/living/simple_animal/emote(var/message = null, var/m_type=1, var/act = "auto")
	switch(act)
		if ("scream")
			message = "<B>[src]</B> makes a loud and pained whimper"
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
		if("auto")
			message = "<B>[src]</B> [message]"
		/*else
			if(!message)
				src << "Invalid Emote: [act]"*/
	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return


/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		health -= damage

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	src.health -= Proj.damage
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if ("help")
			if (health > 0)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\blue [M] [response_help] [src]")

		if ("grab")
			if (M == src)
				return
			if (nopush)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("hurt")
			health -= harm_intent_damage
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\red [M] [response_harm] [src]")

		if ("disarm")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\blue [M] [response_disarm] [src]")

	return

/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					health = min(maxHealth, health + MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						del(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("\blue [user] applies the [MED] on [src]")
		else
			user << "\blue this [src] is dead, medical items won't bring it back to life."
	else
		if(O.force)
			health -= O.force
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with the [O]. ")


/mob/living/simple_animal/movement_delay()
	return speed

/mob/living/simple_animal/Stat()
	..()

	statpanel("Status")
	stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/proc/Die()
	icon_state = icon_dead
	stat = DEAD
	density = 0
	src << "\red You have died!"
	verbs -= /mob/living/simple_animal/say
	return

/mob/living/simple_animal/ex_act(severity)
	flick("flash", flash)
	switch (severity)
		if (1.0)
			health -= 500
			gib()
			return

		if (2.0)
			health -= 60


		if(3.0)
			health -= 30

/proc/issimpleanimal(var/mob/AM)
	return istype(AM,/mob/living/simple_animal)
