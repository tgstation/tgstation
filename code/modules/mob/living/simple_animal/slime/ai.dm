#define SLIME_CARES_ABOUT(to_check) (to_check && (to_check == Target || to_check == Leader || (to_check in Friends)))
#define SLIME_HUNGER_NONE 0
#define SLIME_HUNGER_HUNGRY 1
#define SLIME_HUNGER_STARVING 2

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
		if (nutrition < hunger_nutrition)
			speech_chance += 10
		if (nutrition < starve_nutrition)
			speech_chance += 10
		if (SPT_PROB(1, seconds_per_tick) && prob(speech_chance))
			var/phrases = list()
			if (Target)
				phrases += "[Target]... look yummy..."
			if (nutrition < starve_nutrition)
				phrases += "So... hungry..."
				phrases += "Very... hungry..."
				phrases += "Need... food..."
				phrases += "Must... eat..."
			else if (nutrition < hunger_nutrition)
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
				if (nutrition < hunger_nutrition)
					phrases += "[friend]... feed me..."
			if(!stat)
				say (pick(phrases))

///Sets the slime's current attack target
/mob/living/simple_animal/slime/proc/set_target(new_target)
	var/old_target = Target
	Target = new_target
	if(old_target && !SLIME_CARES_ABOUT(old_target))
		UnregisterSignal(old_target, COMSIG_QDELETING)
	if(Target)
		RegisterSignal(Target, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Sets the person the slime is following around
/mob/living/simple_animal/slime/proc/set_leader(new_leader)
	var/old_leader = Leader
	Leader = new_leader
	if(old_leader && !SLIME_CARES_ABOUT(old_leader))
		UnregisterSignal(old_leader, COMSIG_QDELETING)
	if(Leader)
		RegisterSignal(Leader, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Alters the friendship value of the target
/mob/living/simple_animal/slime/proc/add_friendship(new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Sets the friendship value of the target
/mob/living/simple_animal/slime/proc/set_friendship(new_friend, amount = 1)
	Friends[new_friend] = amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Removes someone from the friendlist
/mob/living/simple_animal/slime/proc/remove_friend(friend)
	Friends -= friend
	if(friend && !SLIME_CARES_ABOUT(friend))
		UnregisterSignal(friend, COMSIG_QDELETING)

///Adds someone to the friend list
/mob/living/simple_animal/slime/proc/set_friends(new_buds)
	clear_friends()
	for(var/mob/friend as anything in new_buds)
		set_friendship(friend, new_buds[friend])

///Removes everyone from the friend list
/mob/living/simple_animal/slime/proc/clear_friends()
	for(var/mob/friend as anything in Friends)
		remove_friend(friend)

///The passed source will be no longer be the slime's target, leader, or one of its friends
/mob/living/simple_animal/slime/proc/clear_memories_of(datum/source)
	SIGNAL_HANDLER
	if(source == Target)
		set_target(null)
	if(source == Leader)
		set_leader(null)
	remove_friend(source)

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

	if (nutrition < starve_nutrition)
		hungry = SLIME_HUNGER_STARVING
	else if (nutrition < grow_nutrition && SPT_PROB(13, seconds_per_tick) || nutrition < hunger_nutrition)
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
			if (life_stage == SLIME_LIFE_STAGE_ADULT)
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

/// the master AI process
/mob/living/simple_animal/slime/proc/process_slime_ai()

	if(slime_ai_processing || stat || client)
		return

	var/hungry = SLIME_HUNGER_NONE
	if (nutrition < starve_nutrition)
		hungry = SLIME_HUNGER_STARVING
	else if (nutrition < grow_nutrition && prob(25) || nutrition < hunger_nutrition)
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
							Target.attack_animal(src)
					break
				if((Target.body_position == STANDING_UP) && prob(80))

					if(Target.client && Target.health >= 20)
						if(!is_attack_on_cooldown)
							is_attack_on_cooldown = TRUE
							addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), 4.5 SECONDS)

							if(Target.Adjacent(src))
								Target.attack_animal(src)

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

#undef SLIME_CARES_ABOUT

#undef SLIME_HUNGER_NONE
#undef SLIME_HUNGER_HUNGRY
#undef SLIME_HUNGER_STARVING
