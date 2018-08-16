// Process the predator's effects upon the contents of its belly (i.e digestion/transformation etc)
/obj/belly/proc/process_belly(var/times_fired,var/wait) //Passed by controller
	if((times_fired < next_process) || !contents.len)
		recent_sound = FALSE
		return SSBELLIES_IGNORED

	if(loc != owner)
		if(istype(owner))
			loc = owner
		else
			qdel(src)
			return SSBELLIES_PROCESSED

	next_process = times_fired + (6 SECONDS/wait) //Set up our next process time.

/////////////////////////// Auto-Emotes ///////////////////////////
	if(contents.len && next_emote <= times_fired)
		next_emote = times_fired + round(emote_time/wait,1)
		var/list/EL = emote_lists[digest_mode]
		for(var/mob/living/M in contents)
			if(M.digestable || !(digest_mode == DM_DIGEST)) // don't give digesty messages to indigestible people
				to_chat(M,"<span class='notice'>[pick(EL)]</span>")

/////////////////////////// Exit Early ////////////////////////////
	var/list/touchable_items = contents - items_preserved
	if(!length(touchable_items))
		return SSBELLIES_PROCESSED

//////////////////////// Absorbed Handling ////////////////////////
	for(var/mob/living/M in contents)
		if(M.absorbed)
			M.Stun(5)

////////////////////////// Sound vars /////////////////////////////
	var/sound/prey_digest = sound(get_sfx("digest_prey"))
	var/sound/prey_death = sound(get_sfx("death_prey"))


///////////////////////////// DM_HOLD /////////////////////////////
	if(digest_mode == DM_HOLD)
		return SSBELLIES_PROCESSED

//////////////////////////// DM_DIGEST ////////////////////////////
	else if(digest_mode == DM_DIGEST)
		for (var/mob/living/M in contents)
			if(prob(25))
				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"digest_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_DIGEST)
				M.playsound_local(get_turf(M), prey_digest, 45)

			//Pref protection!
			if (!M.digestable || M.absorbed)
				continue

			//Person just died in guts!
			if(M.stat == DEAD)
				var/digest_alert_owner = pick(digest_messages_owner)
				var/digest_alert_prey = pick(digest_messages_prey)

				//Replace placeholder vars
				digest_alert_owner = replacetext(digest_alert_owner,"%pred",owner)
				digest_alert_owner = replacetext(digest_alert_owner,"%prey",M)
				digest_alert_owner = replacetext(digest_alert_owner,"%belly",lowertext(name))

				digest_alert_prey = replacetext(digest_alert_prey,"%pred",owner)
				digest_alert_prey = replacetext(digest_alert_prey,"%prey",M)
				digest_alert_prey = replacetext(digest_alert_prey,"%belly",lowertext(name))

				//Send messages
				to_chat(owner, "<span class='warning'>[digest_alert_owner]</span>")
				to_chat(M, "<span class='warning'>[digest_alert_prey]</span>")
				M.visible_message("<span class='notice'>You watch as [owner]'s form loses its additions.</span>")

				owner.nutrition += 400 // so eating dead mobs gives you *something*.
				M.stop_sound_channel(DIGESTION_NOISES)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"death_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(DIGESTION_NOISES)
				M.stop_sound_channel(CHANNEL_PREYLOOP)
				M.playsound_local(get_turf(M), prey_death, 65)
				digestion_death(M)
				owner.update_icons()
				continue


			// Deal digestion damage (and feed the pred)
			if(!(M.status_flags & GODMODE))
				M.adjustFireLoss(digest_burn)
				owner.nutrition += 1

		//Contaminate or gurgle items
		var/obj/item/T = pick(touchable_items)
		if(istype(T))
			if(istype(T,/obj/item/reagent_containers/food) || istype(T,/obj/item/organ))
				digest_item(T)

		owner.updateVRPanel()

///////////////////////////// DM_HEAL /////////////////////////////
	if(digest_mode == DM_HEAL)
		for (var/mob/living/M in contents)
			if(prob(25))
				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"digest_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_DIGEST)
				M.playsound_local(get_turf(M), prey_digest, 65)

			if(M.stat != DEAD)
				if(owner.nutrition >= NUTRITION_LEVEL_STARVING && (M.health < M.maxHealth))
					M.adjustBruteLoss(-3)
					M.adjustFireLoss(-3)
					owner.nutrition -= 5
		return

////////////////////////// DM_NOISY /////////////////////////////////
//for when you just want people to squelch around
	if(digest_mode == DM_NOISY)
		for (var/mob/living/M in contents)
			if(prob(35))
				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"digest_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_PRED)
				M.playsound_local(get_turf(M), prey_digest, 65)


//////////////////////////// DM_ABSORB ////////////////////////////
	else if(digest_mode == DM_ABSORB)

		for (var/mob/living/M in contents)

			if(prob(10)) //Less often than gurgles. People might leave this on forever.
				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"digest_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_PRED)
				M.playsound_local(get_turf(M), prey_digest, 65)

			if(M.absorbed)
				continue

			if(M.nutrition >= 100) //Drain them until there's no nutrients left. Slowly "absorb" them.
				var/oldnutrition = (M.nutrition * 0.05)
				M.nutrition = (M.nutrition * 0.95)
				owner.nutrition += oldnutrition
			else if(M.nutrition < 100) //When they're finally drained.
				absorb_living(M)

//////////////////////////// DM_UNABSORB ////////////////////////////
	else if(digest_mode == DM_UNABSORB)

		for (var/mob/living/M in contents)
			if(M.absorbed && owner.nutrition >= 100)
				M.absorbed = 0
				to_chat(M,"<span class='notice'>You suddenly feel solid again </span>")
				to_chat(owner,"<span class='notice'>You feel like a part of you is missing.</span>")
				owner.nutrition -= 100

//////////////////////////DM_DRAGON /////////////////////////////////////
//because dragons need snowflake guts
	if(digest_mode == DM_DRAGON)
		for (var/mob/living/M in contents)
			if(prob(25))
				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"digest_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_DIGEST)
				M.playsound_local(get_turf(M), prey_digest, 65)

		//No digestion protection for megafauna.

		//Person just died in guts!
			if(M.stat == DEAD)
				var/digest_alert_owner = pick(digest_messages_owner)
				var/digest_alert_prey = pick(digest_messages_prey)

				//Replace placeholder vars
				digest_alert_owner = replacetext(digest_alert_owner,"%pred",owner)
				digest_alert_owner = replacetext(digest_alert_owner,"%prey",M)
				digest_alert_owner = replacetext(digest_alert_owner,"%belly",lowertext(name))

				digest_alert_prey = replacetext(digest_alert_prey,"%pred",owner)
				digest_alert_prey = replacetext(digest_alert_prey,"%prey",M)
				digest_alert_prey = replacetext(digest_alert_prey,"%belly",lowertext(name))

				//Send messages
				to_chat(owner, "<span class='warning'>[digest_alert_owner]</span>")
				to_chat(M, "<span class='warning'>[digest_alert_prey]</span>")
				M.visible_message("<span class='notice'>You watch as [owner]'s guts loudly rumble as it finishes off a meal.</span>")

				M.stop_sound_channel(CHANNEL_DIGEST)
				for(var/mob/H in get_hearers_in_view(5, get_turf(owner)))
					if(H.client && H.client.prefs.cit_toggles & DIGESTION_NOISES)
						playsound(get_turf(owner),"death_pred",50,0,-5,0,ignore_walls = FALSE,channel=CHANNEL_DIGEST)
				M.stop_sound_channel(CHANNEL_DIGEST)
				M.playsound_local(get_turf(M), prey_death, 65)
				M.spill_organs(FALSE,TRUE,TRUE)
				M.stop_sound_channel(CHANNEL_PREYLOOP)
				digestion_death(M)
				owner.update_icons()
				continue


			// Deal digestion damage (and feed the pred)
			if(!(M.status_flags & GODMODE))
				M.adjustFireLoss(digest_burn)
				M.adjustToxLoss(2) // something something plasma based acids
				M.adjustCloneLoss(1) // eventually this'll kill you if you're healing everything else, you nerds.
			//Contaminate or gurgle items
		var/obj/item/T = pick(touchable_items)
		if(istype(T))
			if(istype(T,/obj/item/reagent_containers/food) || istype(T,/obj/item/organ))
				digest_item(T)

		owner.updateVRPanel()