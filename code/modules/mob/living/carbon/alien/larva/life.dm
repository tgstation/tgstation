//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/larva
	var/temperature_alert = 0


/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return

	..()
	var/datum/gas_mixture/enviroment = loc.return_air()
	if (stat != DEAD) //still breathing

		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

		//First, resolve location and get a breath
		if(SSair.times_fired%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.

	//Handle temperature/pressure differences between body and environment
	handle_environment(enviroment)

	//stuff in the stomach
	//handle_stomach()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	//some kind of bug in canmove() isn't properly calling update_icons, so this is here as a placeholder
	update_icons()

	if(client)
		handle_regular_hud_updates()

/mob/living/carbon/alien/larva/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		eye_blind = max(1, eye_blind)
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(health < -25 || !getorgan(/obj/item/organ/brain))
			death()
			eye_blind = max(1, eye_blind)
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (config.health_threshold_crit >= health) )
			//if( health <= 20 && prob(1) )
			//	spawn(0)
			//		emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)
			Paralyse(3)

		if(paralysis)
			AdjustParalysis(-2)
			eye_blind = max(eye_blind, 1)
			stat = UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			eye_blind = max(eye_blind, 1)
			stat = UNCONSCIOUS
			if( prob(10) && health )
				spawn(0)
					emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		//Eyes
		if(disabilities & BLIND)	//disabled-blind, doesn't get better on its own
			eye_blind = max(eye_blind, 1)
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			setEarDamage(-1, max(ear_deaf, 1))
		else
			adjustEarDamage(-1, (ear_damage < 25 ? -0.05 : 0))
			//deafness, heals slowly over time
			//ear damage heals slowly under this threshold. otherwise you'll need earmuffs

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1


/mob/living/carbon/alien/larva/proc/handle_regular_hud_updates()

	if (stat == 2)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		if(nightvision)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if(!nightvision)
			see_in_dark = 4
			see_invisible = 45
		if(see_override)
			see_invisible = see_override

	if (healths)
		if (stat != 2)
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(19 to 25)
					healths.icon_state = "health1"
				if(13 to 19)
					healths.icon_state = "health2"
				if(7 to 13)
					healths.icon_state = "health3"
				if(0 to 7)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	if(pullin)
		if(pulling)
			pullin.icon_state = "pull"
		else
			pullin.icon_state = "pull0"

	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.


	client.screen.Remove(global_hud.blurry,global_hud.druggy,global_hud.vimpaired)

	if ((blind && stat != 2))
		if ((eye_blind))
			blind.layer = 18
		else
			blind.layer = 0

			if (disabilities & NEARSIGHT)
				client.screen += global_hud.vimpaired

			if (eye_blurry)
				client.screen += global_hud.blurry

			if (druggy)
				client.screen += global_hud.druggy

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/alien/larva/proc/handle_random_events()
	return

