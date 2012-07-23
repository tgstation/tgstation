/mob/living/simple_animal
	name = "animal"
	var/icon_living = ""
	var/icon_dead = ""
	maxHealth = 20
	var/list/speak = list()
	var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_chance = 0
	var/list/emote_hear = list()	//EHearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	health = 20
	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 1
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.

	//Interaction
	var/response_help   = "You try to help"
	var/response_disarm = "You try to disarm"
	var/response_harm   = "You try to hurt"
	var/harm_intent_damage = 3

	//Temperature effect
	var/minbodytemp = 270
	var/maxbodytemp = 370
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above


	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/wall_smash = 0 //if they can smash walls

	var/speed = 0 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	var/obj/item/device/radio/headset/ears = null
/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = null
	..()

/mob/living/simple_animal/Life()

	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			stat = CONSCIOUS
			density = 1
		return


	if(health < 1)
		Die()

	if(health > maxHealth)
		health = maxHealth

/*
	// Stun/Weaken

	if (paralysis || stunned || weakened) //Stunned etc.
		if (stunned > 0)
			AdjustStunned(-1)
			stat = 0
		if (weakened > 0)
			AdjustWeakened(-1)
			lying = 1
			stat = 0
		if (paralysis > 0)
			AdjustParalysis(-1)
			blinded = 1
			lying = 1
			stat = 1
		var/h = hand
		hand = 0
		drop_item()
		hand = 1
		drop_item()
		hand = h

	else	//Not stunned.
		lying = 0
		stat = 0

	if(paralysis || stunned || weakened || buckled)
		canmove = 0
	else
		canmove = 1
*/
	//Movement
	if(!ckey && !stop_automated_movement)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(cardinal)))
				turns_since_move = 0







	//Speaking
	if(speak_chance)
		if(prob(speak_chance))
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)


	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = T.temperature
		if( abs(areatemp - bodytemperature) > 50 )
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			//world << "changed from [bodytemperature] by [diff] to [bodytemperature + diff]"
			bodytemperature += diff

		if(istype(T,/turf/simulated))
			var/turf/simulated/ST = T
			if(ST.air)
				var/tox = ST.air.toxins
				var/oxy = ST.air.oxygen
				var/n2  = ST.air.nitrogen
				var/co2 = ST.air.carbon_dioxide

				if(min_oxy)
					if(oxy < min_oxy)
						atmos_suitable = 0
				if(max_oxy)
					if(oxy > max_oxy)
						atmos_suitable = 0
				if(min_tox)
					if(tox < min_tox)
						atmos_suitable = 0
				if(max_tox)
					if(tox > max_tox)
						atmos_suitable = 0
				if(min_n2)
					if(n2 < min_n2)
						atmos_suitable = 0
				if(max_n2)
					if(n2 > max_n2)
						atmos_suitable = 0
				if(min_co2)
					if(co2 < min_co2)
						atmos_suitable = 0
				if(max_co2)
					if(co2 > max_co2)
						atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		health -= cold_damage_per_tick
	else if(bodytemperature > maxbodytemp)
		health -= heat_damage_per_tick

	if(!atmos_suitable)
		health -= unsuitable_atoms_damage

/mob/living/simple_animal/Bumped(AM as mob|obj)
	if(!AM) return

	if(resting || buckled)
		return

	if(isturf(src.loc))
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
			return "[emote], \"[text]\""
	return "says, \"[text]\"";

/mob/living/simple_animal/emote(var/act)
	if(act)
		if(act == "scream")	act = "makes a loud and pained whimper" //ugly hack to stop animals screaming when crushed :P
		for (var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> [act].")


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
			G.affecting = src
			M.put_in_active_hand(G)

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
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	return tally

/mob/living/simple_animal/Stat()
	..()

	statpanel("Status")
	stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/proc/Die()
	icon_state = icon_dead
	stat = DEAD
	density = 0
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

/mob/living/simple_animal/adjustBruteLoss(damage)
	health -= damage