/mob/living/Life(seconds, times_fired)
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(digitalinvis)
		handle_diginvis() //AI becomes unable to see mob

	if (notransform)
		return
	if(!loc)
		if(client)
			for(var/obj/effect/landmark/error/E in GLOB.landmarks_list)
				loc = E.loc
				break
			message_admins("[key_name_admin(src)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished.")
			log_game("[key_name(src)] was found to have no .loc with an attached client.")
		else
			return
	var/datum/gas_mixture/environment = loc.return_air()

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing(times_fired)
	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()
	if(stat != DEAD)
		//Chemicals in the body
		handle_chemicals_in_body()
	if(stat != DEAD)
		//Random events (vomiting etc)
		handle_random_events()

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_gravity(mob_has_gravity())

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		handle_disabilities() // eye, ear, brain damages
	if(stat != DEAD)
		handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_diginvis()
	if(!digitaldisguise)
		src.digitaldisguise = image(loc = src)
	src.digitaldisguise.override = 1
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		AI.client.images |= src.digitaldisguise


/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
	else
		ExtinguishMob()
		return
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(!G.gases["o2"] || G.gases["o2"][MOLES] < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/proc/handle_stomach()
	return

//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(confused)
		confused = max(0, confused - 1)

/mob/living/proc/handle_disabilities()
	//Eyes
	if(eye_blind)			//blindness, heals slowly over time
		if(!stat && !(disabilities & BLIND))
			eye_blind = max(eye_blind-1,0)
			if(client && !eye_blind)
				clear_alert("blind")
				clear_fullscreen("blind")
		else
			eye_blind = max(eye_blind-1,1)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)
		if(client && !eye_blurry)
			clear_fullscreen("blurry")

/mob/living/proc/update_damage_hud()
	return


