#define SLIME_HUNGER_NONE 0
#define SLIME_HUNGER_HUNGRY 1
#define SLIME_HUNGER_STARVING 2

/mob/living/simple_animal/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
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

/// the master AI process
/mob/living/simple_animal/slime/proc/process_slime_ai()

	if(slime_ai_processing || stat || client)
		return

	var/hungry = SLIME_HUNGER_NONE
	if (nutrition < get_starve_nutrition())
		hungry = SLIME_HUNGER_STARVING
	else if (nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
		hungry = SLIME_HUNGER_HUNGRY

	slime_ai_processing = TRUE

	while(slime_ai_processing && stat != DEAD && (attacked_stacks || hungry || rabid || buckled))
		if(!(mobility_flags & MOBILITY_MOVE)) //also covers buckling. Not sure why buckled is in the while condition if we're going to immediately break, honestly
			break

		if(!Target || client)
			break

		if(Target.health <= -70 || Target.stat == DEAD)
			set_target(null)
			slime_ai_processing = FALSE
			break

		if(Target)
			if(locate(/mob/living/simple_animal/slime) in Target.buckled_mobs)
				set_target(null)
				slime_ai_processing = FALSE
				break
			if(!slime_ai_processing)
				break

			if(Target in view(1,src))
				if(!can_feed_on(Target)) //If they're not able to be fed upon, ignore them.
					if(!is_attack_on_cooldown)
						is_attack_on_cooldown = TRUE
						addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), 4.5 SECONDS)

						if(Target.Adjacent(src))
							Target.attack_slime(src)
					break
				if((Target.body_position == STANDING_UP) && prob(80))

					if(Target.client && Target.health >= 20)
						if(!is_attack_on_cooldown)
							is_attack_on_cooldown = TRUE
							addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), 4.5 SECONDS)

							if(Target.Adjacent(src))
								Target.attack_slime(src)

					else
						if(!is_attack_on_cooldown && Target.Adjacent(src))
							start_feeding(Target)

				else
					if(!is_attack_on_cooldown && Target.Adjacent(src))
						start_feeding(Target)

			else if(Target in view(7, src))
				if(!Target.Adjacent(src))
				// Bug of the month candidate: slimes were attempting to move to target only if it was directly next to them, which caused them to target things, but not approach them
					step_to(src, Target)
			else
				set_target(null)
				slime_ai_processing = FALSE
				break

		var/sleeptime = cached_multiplicative_slowdown
		if(sleeptime <= 0)
			sleeptime = 1

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	slime_ai_processing = FALSE

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

///Handles the slime draining the target it is attached to
/mob/living/simple_animal/slime/proc/handle_feeding(seconds_per_tick, times_fired)
	var/mob/living/prey = buckled

	if(stat)
		stop_feeding(silent = TRUE)

	if(prey.stat == DEAD) // our victim died
		if(!client)
			if(!rabid && !attacked_stacks)
				var/mob/last_to_hurt = prey.LAssailant?.resolve()
				if(last_to_hurt && last_to_hurt != prey)
					if(SPT_PROB(30, seconds_per_tick))
						add_friendship(last_to_hurt, 1)
		else
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")

		if(prey.client && ishuman(prey))
			if(SPT_PROB(61, seconds_per_tick))
				rabid = TRUE //we go rabid after finishing to feed on a human with a client.

		stop_feeding()
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
		var/need_mob_update
		need_mob_update = totaldamage += animal_victim.adjustBruteLoss(rand(2, 4) * 0.5 * seconds_per_tick, updating_health = FALSE)
		need_mob_update += totaldamage += animal_victim.adjustToxLoss(rand(1, 2) * 0.5 * seconds_per_tick, updating_health = FALSE)
		if(need_mob_update)
			animal_victim.updatehealth()

		if(totaldamage <= 0) //if we did no(or negative!) damage to it, stop
			stop_feeding(FALSE, FALSE)
			return

	else
		stop_feeding(FALSE, FALSE)
		return

	add_nutrition((rand(7, 15) * 0.5 * seconds_per_tick * CONFIG_GET(number/damage_multiplier)))

	//Heal yourself.
	adjustBruteLoss(-1.5 * seconds_per_tick)

///Handles the slime's nutirion level
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

///Adds nutrition to the slime's nutrition level. Has a chance to increase its electric levels.
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

///Handles selecting targets
/mob/living/simple_animal/slime/proc/handle_targets(seconds_per_tick, times_fired)
	if(attacked_stacks > 50)
		attacked_stacks = 50

	if(attacked_stacks > 0)
		attacked_stacks--

	if(discipline_stacks > 0)

		if(discipline_stacks >= 5 && rabid)
			if(SPT_PROB(37, seconds_per_tick))
				rabid = FALSE

		if(SPT_PROB(5, seconds_per_tick))
			discipline_stacks--

	if(client) //player controlled slimes can decide for themselves
		return

	if(!(mobility_flags & MOBILITY_MOVE))
		return

	if(buckled)
		return // if it's eating someone already, continue eating!

	if(Target)
		--target_patience
		if (target_patience <= 0 || stunned_until > world.time || discipline_stacks || attacked_stacks || docile) // Tired of chasing or something draws out attention
			target_patience = 0
			set_target(null)

	if(slime_ai_processing && stunned_until > world.time)
		return

	var/hungry = SLIME_HUNGER_NONE // determines if the slime is hungry

	if (nutrition < get_starve_nutrition())
		hungry = SLIME_HUNGER_STARVING
	else if (nutrition < get_grow_nutrition() && SPT_PROB(13, seconds_per_tick) || nutrition < get_hunger_nutrition())
		hungry = SLIME_HUNGER_HUNGRY

	if(hungry == SLIME_HUNGER_STARVING && !client) // if a slime is starving, it starts losing its friends
		if(Friends.len > 0 && SPT_PROB(0.5, seconds_per_tick))
			var/mob/nofriend = pick(Friends)
			add_friendship(nofriend, -1)

	if(!Target) //If we have no target, try to add a target
		if(will_hunt() && hungry || attacked_stacks || rabid) // Only add to the list if we need to
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

				if(issilicon(L) && (rabid || attacked_stacks)) // They can't eat silicons, but they can glomp them in defence
					targets += L // Possible target found!

				if(locate(/mob/living/simple_animal/slime) in L.buckled_mobs) // Only one slime can latch on at a time.
					continue

				targets += L // Possible target found!

			if(targets.len > 0)
				if(attacked_stacks || rabid || hungry == SLIME_HUNGER_STARVING)
					set_target(targets[1]) // I am attacked and am fighting back or so hungry I don't even care
				else
					for(var/mob/living/carbon/C in targets)
						if(!discipline_stacks && SPT_PROB(2.5, seconds_per_tick))
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
	else if(!slime_ai_processing)
		INVOKE_ASYNC(src, PROC_REF(process_slime_ai))

/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()

///Handles slime mood
/mob/living/simple_animal/slime/proc/handle_mood(seconds_per_tick, times_fired)
	#define SLIME_MOOD_NONE ""
	#define SLIME_MOOD_ANGRY "angry"
	#define SLIME_MOOD_MISCHIEVOUS "mischievous"
	#define SLIME_MOOD_POUT "pout"
	#define SLIME_MOOD_SAD "sad"
	#define SLIME_MOOD_SMILE ":3"

	var/newmood = SLIME_MOOD_NONE
	if (rabid || attacked_stacks)
		newmood = SLIME_MOOD_ANGRY
	else if (docile)
		newmood = SLIME_MOOD_SMILE
	else if (Target)
		newmood = SLIME_MOOD_MISCHIEVOUS

	if (!newmood)
		if (discipline_stacks && SPT_PROB(13, seconds_per_tick))
			newmood = SLIME_MOOD_POUT
		else if (SPT_PROB(0.5, seconds_per_tick))
			newmood = pick(SLIME_MOOD_SAD, ":3", SLIME_MOOD_POUT)

	if ((current_mood == SLIME_MOOD_SAD || current_mood == SLIME_MOOD_SMILE || current_mood == SLIME_MOOD_POUT) && !newmood)
		if(SPT_PROB(50, seconds_per_tick))
			newmood = current_mood

	if (newmood != current_mood) // This is so we don't redraw them every time
		current_mood = newmood
		regenerate_icons()

	#undef SLIME_MOOD_NONE
	#undef SLIME_MOOD_ANGRY
	#undef SLIME_MOOD_MISCHIEVOUS
	#undef SLIME_MOOD_POUT
	#undef SLIME_MOOD_SAD
	#undef SLIME_MOOD_SMILE

///Handles the slime understanding commends spoken to it
/mob/living/simple_animal/slime/proc/handle_speech(seconds_per_tick, times_fired)
	//Speech understanding starts here
	var/to_say
	if (speech_buffer.len > 0)
		var/who = speech_buffer[1] // Who said it?
		var/phrase = speech_buffer[2] // What did they say?
		if ((findtext(phrase, num2text(slime_id)) || findtext(phrase, "slimes"))) // Talking to us
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
						stop_feeding()
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
					process_slime_ai() //Wake up the slime's Target AI, needed otherwise this doesn't work
					to_say = "ATTACK!?!?"
				else if (Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
					for (var/mob/living/possible_target in view(7,src)-list(src,who))
						if (findtext(phrase, lowertext(possible_target.name)))
							if (isslime(possible_target))
								to_say = "NO... [possible_target] slime friend"
								add_friendship(who, -1) //Don't ask a slime to attack its friend
							else if(!Friends[possible_target] || Friends[possible_target] < 1)
								set_target(possible_target)
								process_slime_ai()//Wake up the slime's Target AI, needed otherwise this doesn't work
								to_say = "Ok... I attack [Target]"
							else
								to_say = "No... like [possible_target] ..."
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
		var/speech_chance = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		var/friends_near = list()
		for (var/mob/living/seen_mob in view(7,src))
			if(isslime(seen_mob) && seen_mob != src)
				++slimes_near
				if (seen_mob.stat == DEAD)
					++dead_slimes
			if (seen_mob in Friends)
				speech_chance += 20
				friends_near += seen_mob
		if (nutrition < get_hunger_nutrition())
			speech_chance += 10
		if (nutrition < get_starve_nutrition())
			speech_chance += 10
		if (SPT_PROB(1, seconds_per_tick) && prob(speech_chance))
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
			if (rabid || attacked_stacks)
				phrases += "Hrr..."
				phrases += "Nhuu..."
				phrases += "Unn..."
			if (current_mood == ":3")
				phrases += "Purr..."
			if (attacked_stacks)
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
			for (var/friend in friends_near)
				phrases += "[friend]... friend..."
				if (nutrition < get_hunger_nutrition())
					phrases += "[friend]... feed me..."
			if(!stat)
				say (pick(phrases))

/// Can't go above it
/mob/living/simple_animal/slime/proc/get_max_nutrition()
	if (is_adult)
		return 1200
	else
		return 1000

/// Above it we grow, below it we can eat
/mob/living/simple_animal/slime/proc/get_grow_nutrition()
	if (is_adult)
		return 1000
	else
		return 800

/// Below it we will always eat
/mob/living/simple_animal/slime/proc/get_hunger_nutrition()
	if (is_adult)
		return 600
	else
		return 500

/// Below it we will eat before everything else
/mob/living/simple_animal/slime/proc/get_starve_nutrition()
	if(is_adult)
		return 300
	else
		return 200
/// Check for being stopped from feeding and chasing
/mob/living/simple_animal/slime/proc/will_hunt(hunger = -1)
	if (docile)
		return FALSE
	if (hunger == SLIME_HUNGER_STARVING || rabid || attacked_stacks)
		return TRUE
	if (Leader)
		return FALSE
	if (holding_still)
		return FALSE
	return TRUE

#undef SLIME_HUNGER_NONE
#undef SLIME_HUNGER_HUNGRY
#undef SLIME_HUNGER_STARVING
