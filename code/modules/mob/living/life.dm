/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	if(stat != DEAD)

		//Breathing, if applicable
		handle_breathing()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Blud
		handle_blood()

		//Random events (vomiting etc)
		handle_random_events()

		if(!client && !stat)
			handle_automated_movement()

			handle_automated_speech()

		. = 1

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_canmove()

	update_gravity(mob_has_gravity())

	for(var/obj/item/weapon/grab/G in src)
		G.process()

	handle_regular_status_updates() // Status updates, death etc.

	if(client)
		handle_regular_hud_updates()

	return .



/mob/living/proc/handle_breathing()

/mob/living/proc/handle_mutations_and_radiation()
	if(radiation)

		switch(radiation)
			if(0 to 50)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 75)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth()

		radiation = Clamp(radiation, 0, 100)


/mob/living/proc/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

	return

/mob/living/proc/handle_blood()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(var/datum/gas_mixture/environment)
	return

/mob/living/proc/handle_stomach()
	return

/mob/living/proc/handle_regular_status_updates()

	updatehealth()

	if(stat != DEAD)

		if(paralysis)
			AdjustParalysis(-1)
			stat = UNCONSCIOUS

		else if (status_flags & FAKEDEATH)
			stat = UNCONSCIOUS

		else
			stat = CONSCIOUS

		handle_disabilities()

		if(stunned)
			AdjustStunned(-1)
			if(!stunned)
				update_icons()

		if(weakened)
			weakened = max(weakened-1,0)
			if(!weakened)
				update_icons()

		return 1

/mob/living/proc/handle_automated_movement()
	return

/mob/living/proc/handle_automated_speech()
	return

/mob/living/proc/handle_disabilities()
	//Eyes
	if(disabilities & BLIND || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		eye_blind = max(eye_blind, 1)
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

	//Ears
	if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		setEarDamage(-1, max(ear_deaf, 1))
	else
		// deafness heals slowly over time, unless ear_damage is over 100
		if(ear_damage < 100)
			adjustEarDamage(-0.05,-1)


//this handles hud updates. Calles update_vision() and handle_hud_icons()
/mob/living/proc/handle_regular_hud_updates()
	if(!client)	return 0

	handle_vision()
	handle_hud_icons()

	return 1

/mob/living/proc/handle_vision()

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask)

	update_sight()

	if(stat != DEAD)
		if(blind)
			if(eye_blind)
				blind.layer = 18
			else
				blind.layer = 0

				if (disabilities & NEARSIGHT)
					client.screen += global_hud.vimpaired

				if (eye_blurry)
					client.screen += global_hud.blurry

				if (druggy)
					client.screen += global_hud.druggy

				if(eye_stat > 20)
					if(eye_stat > 30)
						client.screen += global_hud.darkMask
					else
						client.screen += global_hud.vimpaired

		if(machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

/mob/living/proc/update_sight()
	return

/mob/living/proc/handle_hud_icons()
	handle_hud_icons_health()
	return

/mob/living/proc/handle_hud_icons_health()
	return
