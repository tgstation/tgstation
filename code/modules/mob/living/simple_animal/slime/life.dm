/mob/living/simple_animal/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if (notransform)
		return
	. = ..()
	if(!.)
		return

	// We get some passive bruteloss healing if we're not dead
	if(stat != DEAD && SPT_PROB(16, seconds_per_tick))
		adjustBruteLoss(-0.5 * seconds_per_tick)
	if(ismob(buckled))
		handle_feeding(seconds_per_tick, times_fired)
	if(stat != CONSCIOUS) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
		return
	handle_nutrition(seconds_per_tick, times_fired)
	if(QDELETED(src)) // Stop if the slime split during handle_nutrition()
		return
	reagents.remove_all(0.5 * REAGENTS_METABOLISM * reagents.reagent_list.len * seconds_per_tick) //Slimes are such snowflakes
	handle_targets(seconds_per_tick, times_fired)
	if(ckey)
		return
	handle_mood(seconds_per_tick, times_fired)
	handle_speech(seconds_per_tick, times_fired)


// Unlike most of the simple animals, slimes support UNCONSCIOUS. This is an ugly hack.
/mob/living/simple_animal/slime/update_stat()
	switch(stat)
		if(UNCONSCIOUS, HARD_CRIT)
			if(health > 0)
				return
	return ..()


/mob/living/simple_animal/slime/proc/AIprocess()  // the master AI process

	if(AIproc || stat || client)
		return

	var/hungry = 0
	if (nutrition < get_starve_nutrition())
		hungry = 2
	else if (nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
		hungry = 1

	AIproc = 1

	while(AIproc && stat != DEAD && (attacked || hungry || rabid || buckled))
		if(!(mobility_flags & MOBILITY_MOVE)) //also covers buckling. Not sure why buckled is in the while condition if we're going to immediately break, honestly
			break

		if(!Target || client)
			break

		if(Target.health <= -70 || Target.stat == DEAD)
			set_target(null)
			AIproc = 0
			break

		if(Target)
			if(locate(/mob/living/simple_animal/slime) in Target.buckled_mobs)
				set_target(null)
				AIproc = 0
				break
			if(!AIproc)
				break

			if(Target in view(1,src))
				if(!CanFeedon(Target)) //If they're not able to be fed upon, ignore them.
					if(!Atkcool)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

						if(Target.Adjacent(src))
							Target.attack_slime(src)
					break
				if((Target.body_position == STANDING_UP) && prob(80))

					if(Target.client && Target.health >= 20)
						if(!Atkcool)
							Atkcool = TRUE
							addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

							if(Target.Adjacent(src))
								Target.attack_slime(src)

					else
						if(!Atkcool && Target.Adjacent(src))
							Feedon(Target)

				else
					if(!Atkcool && Target.Adjacent(src))
						Feedon(Target)

			else if(Target in view(7, src))
				if(!Target.Adjacent(src))
				// Bug of the month candidate: slimes were attempting to move to target only if it was directly next to them, which caused them to target things, but not approach them
					step_to(src, Target)
			else
				set_target(null)
				AIproc = 0
				break

		var/sleeptime = cached_multiplicative_slowdown
		if(sleeptime <= 0)
			sleeptime = 1

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	AIproc = 0

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp = get_temperature(environment)
	var/divisor = 10 /// The divisor controls how fast body temperature changes, lower causes faster changes

	var/temp_delta = loc_temp - bodytemperature
	if(abs(temp_delta) > 50) // If the difference is great, reduce the divisor for faster stabilization
		divisor = 5

	if(temp_delta < 0) // It is cold here
		if(!on_fire) // Do not reduce body temp when on fire
			adjust_bodytemperature(clamp((temp_delta / divisor) * seconds_per_tick, temp_delta, 0))
	else // This is a hot place
		adjust_bodytemperature(clamp((temp_delta / divisor) * seconds_per_tick, 0, temp_delta))

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc
		if(bodytemperature <= (T0C - 40)) // stun temperature
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)
		else
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(100 * seconds_per_tick)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * seconds_per_tick)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_COLD)

	if(stat != DEAD)
		var/bz_percentage =0
		if(environment.gases[/datum/gas/bz])
			bz_percentage = environment.gases[/datum/gas/bz][MOLES] / environment.total_moles()
		var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) || force_stasis

		switch(stat)
			if(CONSCIOUS)
				if(stasis)
					to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
					set_stat(UNCONSCIOUS)
					powerlevel = 0
					rabid = FALSE
					regenerate_icons()
			if(UNCONSCIOUS, HARD_CRIT)
				if(!stasis)
					to_chat(src, span_notice("You wake up from the stasis."))
					set_stat(CONSCIOUS)
					regenerate_icons()

	updatehealth()

/mob/living/simple_animal/slime/proc/handle_feeding(seconds_per_tick, times_fired)
	var/mob/living/prey = buckled

	if(stat)
		Feedstop(silent = TRUE)

	if(prey.stat == DEAD) // our victim died
		if(!client)
			if(!rabid && !attacked)
				var/mob/last_to_hurt = prey.LAssailant?.resolve()
				if(last_to_hurt && last_to_hurt != prey)
					if(SPT_PROB(30, seconds_per_tick))
						add_friendship(last_to_hurt, 1)
		else
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")

		if(prey.client && ishuman(prey))
			if(SPT_PROB(61, seconds_per_tick))
				rabid = 1 //we go rabid after finishing to feed on a human with a client.

		Feedstop()
		return

	if(iscarbon(prey))
		prey.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick)
		prey.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick)

		if(SPT_PROB(5, seconds_per_tick) && prey.client)
			to_chat(prey, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
			"You feel like you're about to die!", \
			"You feel every part of your body screaming in agony!", \
			"A low, rolling pain passes through your body!", \
			"Your body feels as if it's falling apart!", \
			"You feel extremely weak!", \
			"A sharp, deep pain bathes every inch of your body!")]</span>")

	else if(isanimal_or_basicmob(prey))
		var/mob/living/animal_victim = prey

		var/totaldamage = 0 //total damage done to this unfortunate animal
		totaldamage += animal_victim.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick)
		totaldamage += animal_victim.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick)

		if(totaldamage <= 0) //if we did no(or negative!) damage to it, stop
			Feedstop(0, 0)
			return

	else
		Feedstop(0, 0)
		return

	add_nutrition((rand(7, 15) * 0.5 * seconds_per_tick * CONFIG_GET(number/damage_multiplier)))

	//Heal yourself.
	adjustBruteLoss(-1.5 * seconds_per_tick)

/mob/living/simple_animal/slime/proc/handle_nutrition(seconds_per_tick, times_fired)

	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(SPT_PROB(7.5, seconds_per_tick))
		adjust_nutrition(-0.5 * (1 + is_adult) * seconds_per_tick)

	if(nutrition <= 0)
		set_nutrition(0)
		if(SPT_PROB(50, seconds_per_tick))
			adjustBruteLoss(rand(0,5))

	else if (nutrition >= get_grow_nutrition() && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-10 * seconds_per_tick)
		amount_grown++
		update_mob_action_buttons()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(is_adult && loc.AllowDrop())
			Reproduce()
		else
			Evolve()

/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if(nutrition >= get_grow_nutrition())
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel++
	else if(nutrition >= get_hunger_nutrition() + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel++




/mob/living/simple_animal/slime/proc/handle_targets(seconds_per_tick, times_fired)
	if(attacked > 50)
		attacked = 50

	if(attacked > 0)
		attacked--

	if(Discipline > 0)

		if(Discipline >= 5 && rabid)
			if(SPT_PROB(37, seconds_per_tick))
				rabid = 0

		if(SPT_PROB(5, seconds_per_tick))
			Discipline--

	if(!client)
		if(!(mobility_flags & MOBILITY_MOVE))
			return

		if(buckled)
			return // if it's eating someone already, continue eating!

		if(Target)
			--target_patience
			if (target_patience <= 0 || SStun > world.time || Discipline || attacked || docile) // Tired of chasing or something draws out attention
				target_patience = 0
				set_target(null)

		if(AIproc && SStun > world.time)
			return

		var/hungry = 0 // determines if the slime is hungry

		if (nutrition < get_starve_nutrition())
			hungry = 2
		else if (nutrition < get_grow_nutrition() && SPT_PROB(13, seconds_per_tick) || nutrition < get_hunger_nutrition())
			hungry = 1

		if(hungry == 2 && !client) // if a slime is starving, it starts losing its friends
			if(Friends.len > 0 && SPT_PROB(0.5, seconds_per_tick))
				var/mob/nofriend = pick(Friends)
				add_friendship(nofriend, -1)

		if(!Target)
			if(will_hunt() && hungry || attacked || rabid) // Only add to the list if we need to
				var/list/targets = list()

				for(var/mob/living/L in view(7,src))

					if(isslime(L) || L.stat == DEAD) // Ignore other slimes and dead mobs
						continue

					if(L in Friends) // No eating friends!
						continue

					var/ally = FALSE
					for(var/F in faction)
						if(F == FACTION_NEUTRAL) //slimes are neutral so other mobs not target them, but they can target neutral mobs
							continue
						if(F in L.faction)
							ally = TRUE
							break
					if(ally)
						continue

					if(issilicon(L) && (rabid || attacked)) // They can't eat silicons, but they can glomp them in defence
						targets += L // Possible target found!

					if(locate(/mob/living/simple_animal/slime) in L.buckled_mobs) // Only one slime can latch on at a time.
						continue

					targets += L // Possible target found!

				if(targets.len > 0)
					if(attacked || rabid || hungry == 2)
						set_target(targets[1]) // I am attacked and am fighting back or so hungry I don't even care
					else
						for(var/mob/living/carbon/C in targets)
							if(!Discipline && SPT_PROB(2.5, seconds_per_tick))
								if(ishuman(C) || isalienadult(C))
									set_target(C)
									break

							if(islarva(C) || ismonkey(C))
								set_target(C)
								break

			if (Target)
				target_patience = rand(5, 7)
				if (is_adult)
					target_patience += 3

		if(!Target) // If we have no target, we are wandering or following orders
			if (Leader)
				if(holding_still)
					holding_still = max(holding_still - (0.5 * seconds_per_tick), 0)
				else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc))
					step_to(src, Leader)

			else if(hungry)
				if (holding_still)
					holding_still = max(holding_still - (0.5 * hungry * seconds_per_tick), 0)
				else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc) && prob(50))
					step(src, pick(GLOB.cardinals))

			else
				if(holding_still)
					holding_still = max(holding_still - (0.5 * seconds_per_tick), 0)
				else if (docile && pulledby)
					holding_still = 10
				else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc) && prob(33))
					step(src, pick(GLOB.cardinals))
		else if(!AIproc)
			INVOKE_ASYNC(src, PROC_REF(AIprocess))

/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()

/mob/living/simple_animal/slime/proc/handle_mood(seconds_per_tick, times_fired)
	var/newmood = ""
	if (rabid || attacked)
		newmood = "angry"
	else if (docile)
		newmood = ":3"
	else if (Target)
		newmood = "mischievous"

	if (!newmood)
		if (Discipline && SPT_PROB(13, seconds_per_tick))
			newmood = "pout"
		else if (SPT_PROB(0.5, seconds_per_tick))
			newmood = pick("sad", ":3", "pout")

	if ((current_mood == "sad" || current_mood == ":3" || current_mood == "pout") && !newmood)
		if(SPT_PROB(50, seconds_per_tick))
			newmood = current_mood

	if (newmood != current_mood) // This is so we don't redraw them every time
		current_mood = newmood
		regenerate_icons()

/mob/living/simple_animal/slime/proc/handle_speech(seconds_per_tick, times_fired)
	//Speech understanding starts here
	var/to_say
	if (speech_buffer.len > 0)
		var/who = speech_buffer[1] // Who said it?
		var/phrase = speech_buffer[2] // What did they say?
		if ((findtext(phrase, num2text(number)) || findtext(phrase, "slimes"))) // Talking to us
			if (findtext(phrase, "hello") || findtext(phrase, "hi"))
				to_say = pick("Hello...", "Hi...")
			else if (findtext(phrase, "follow"))
				if (Leader)
					if (Leader == who) // Already following him
						to_say = pick("Yes...", "Lead...", "Follow...")
					else if (Friends[who] > Friends[Leader]) // VIVA
						set_leader(who)
						to_say = "Yes... I follow [who]..."
					else
						to_say = "No... I follow [Leader]..."
				else
					if (Friends[who] >= SLIME_FRIENDSHIP_FOLLOW)
						set_leader(who)
						to_say = "I follow..."
					else // Not friendly enough
						to_say = pick("No...", "I no follow...")
			else if (findtext(phrase, "stop"))
				if (buckled) // We are asked to stop feeding
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPEAT)
						Feedstop()
						set_target(null)
						if (Friends[who] < SLIME_FRIENDSHIP_STOPEAT_NOANGRY)
							add_friendship(who, -1)
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Target) // We are asked to stop chasing
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPCHASE)
						set_target(null)
						if (Friends[who] < SLIME_FRIENDSHIP_STOPCHASE_NOANGRY)
							add_friendship(who, -1)
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Leader) // We are asked to stop following
					if (Leader == who)
						to_say = "Yes... I stay..."
						set_leader(null)
					else
						if (Friends[who] > Friends[Leader])
							set_leader(null)
							to_say = "Yes... I stop..."
						else
							to_say = "No... keep follow..."
			else if (findtext(phrase, "stay"))
				if (Leader)
					if (Leader == who)
						holding_still = Friends[who] * 10
						to_say = "Yes... stay..."
					else if (Friends[who] > Friends[Leader])
						holding_still = (Friends[who] - Friends[Leader]) * 10
						to_say = "Yes... stay..."
					else
						to_say = "No... keep follow..."
				else
					if (Friends[who] >= SLIME_FRIENDSHIP_STAY)
						holding_still = Friends[who] * 10
						to_say = "Yes... stay..."
					else
						to_say = "No... won't stay..."
			else if (findtext(phrase, "attack"))
				if (rabid && prob(20))
					set_target(who)
					AIprocess() //Wake up the slime's Target AI, needed otherwise this doesn't work
					to_say = "ATTACK!?!?"
				else if (Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
					for (var/mob/living/L in view(7,src)-list(src,who))
						if (findtext(phrase, lowertext(L.name)))
							if (isslime(L))
								to_say = "NO... [L] slime friend"
								add_friendship(who, -1) //Don't ask a slime to attack its friend
							else if(!Friends[L] || Friends[L] < 1)
								set_target(L)
								AIprocess()//Wake up the slime's Target AI, needed otherwise this doesn't work
								to_say = "Ok... I attack [Target]"
							else
								to_say = "No... like [L] ..."
								add_friendship(who, -1) //Don't ask a slime to attack its friend
							break
				else
					to_say = "No... no listen"

		speech_buffer = list()

	//Speech starts here
	if (to_say)
		say (to_say)
	else if(SPT_PROB(0.5, seconds_per_tick))
		emote(pick("bounce","sway","light","vibrate","jiggle"))
	else
		var/t = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		var/friends_near = list()
		for (var/mob/living/L in view(7,src))
			if(isslime(L) && L != src)
				++slimes_near
				if (L.stat == DEAD)
					++dead_slimes
			if (L in Friends)
				t += 20
				friends_near += L
		if (nutrition < get_hunger_nutrition())
			t += 10
		if (nutrition < get_starve_nutrition())
			t += 10
		if (SPT_PROB(1, seconds_per_tick) && prob(t))
			var/phrases = list()
			if (Target)
				phrases += "[Target]... look yummy..."
			if (nutrition < get_starve_nutrition())
				phrases += "So... hungry..."
				phrases += "Very... hungry..."
				phrases += "Need... food..."
				phrases += "Must... eat..."
			else if (nutrition < get_hunger_nutrition())
				phrases += "Hungry..."
				phrases += "Where food?"
				phrases += "I want to eat..."
			phrases += "Rawr..."
			phrases += "Blop..."
			phrases += "Blorble..."
			if (rabid || attacked)
				phrases += "Hrr..."
				phrases += "Nhuu..."
				phrases += "Unn..."
			if (current_mood == ":3")
				phrases += "Purr..."
			if (attacked)
				phrases += "Grrr..."
			if (bodytemperature < T0C)
				phrases += "Cold..."
			if (bodytemperature < T0C - 30)
				phrases += "So... cold..."
				phrases += "Very... cold..."
			if (bodytemperature < T0C - 50)
				phrases += "..."
				phrases += "C... c..."
			if (buckled)
				phrases += "Nom..."
				phrases += "Yummy..."
			if (powerlevel > 3)
				phrases += "Bzzz..."
			if (powerlevel > 5)
				phrases += "Zap..."
			if (powerlevel > 8)
				phrases += "Zap... Bzz..."
			if (current_mood == "sad")
				phrases += "Bored..."
			if (slimes_near)
				phrases += "Slime friend..."
			if (slimes_near > 1)
				phrases += "Slime friends..."
			if (dead_slimes)
				phrases += "What happened?"
			if (!slimes_near)
				phrases += "Lonely..."
			for (var/M in friends_near)
				phrases += "[M]... friend..."
				if (nutrition < get_hunger_nutrition())
					phrases += "[M]... feed me..."
			if(!stat)
				say (pick(phrases))

/mob/living/simple_animal/slime/proc/get_max_nutrition() // Can't go above it
	if (is_adult)
		return 1200
	else
		return 1000

/mob/living/simple_animal/slime/proc/get_grow_nutrition() // Above it we grow, below it we can eat
	if (is_adult)
		return 1000
	else
		return 800

/mob/living/simple_animal/slime/proc/get_hunger_nutrition() // Below it we will always eat
	if (is_adult)
		return 600
	else
		return 500

/mob/living/simple_animal/slime/proc/get_starve_nutrition() // Below it we will eat before everything else
	if(is_adult)
		return 300
	else
		return 200

/mob/living/simple_animal/slime/proc/will_hunt(hunger = -1) // Check for being stopped from feeding and chasing
	if (docile)
		return FALSE
	if (hunger == 2 || rabid || attacked)
		return TRUE
	if (Leader)
		return FALSE
	if (holding_still)
		return FALSE
	return TRUE
