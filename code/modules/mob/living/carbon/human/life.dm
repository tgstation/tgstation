//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!


#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

#define HUMAN_MAX_OXYLOSS 3 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define HUMAN_CRIT_MAX_OXYLOSS ( (last_tick_duration) /3) //The amount of damage you'll get when in critical condition. We want this to be a 5 minute deal = 300s. There are 100HP to get through, so (1/3)*last_tick_duration per second. Breaths however only happen every 4 ticks.

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 3 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0
	var/tinttotal = 0				// Total level of visualy impairing items



/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE

	..()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.
	tinttotal = tintcheck() //here as both hud updates and status updates call it

	//TODO: seperate this out
	var/datum/gas_mixture/environment = loc.return_air()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD)
		if(air_master.current_cycle%4==2 || failed_last_breath) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Random events (vomiting etc)
		handle_random_events()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//Check if we're on fire
	handle_fire()

	//stuff in the stomach
	handle_stomach()

	//Status updates, death etc.
	handle_regular_status_updates()		//TODO: optimise ~Carn
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	handle_regular_hud_updates()

	if(dna)
		dna.species.spec_life(src) // for mutantraces

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()


/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	..()
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	var/pressure_adjustment_coefficient = 1	//Determins how much the clothing you are wearing protects you in percent.
	if(wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_SUIT_REDUCTION_COEFFICIENT
	if(head && (head.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_HEAD_REDUCTION_COEFFICIENT
	pressure_adjustment_coefficient = max(pressure_adjustment_coefficient,0) //So it isn't less than 0
	pressure_difference = pressure_difference * pressure_adjustment_coefficient
	if(pressure > ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE + pressure_difference
	else
		return ONE_ATMOSPHERE - pressure_difference


/mob/living/carbon/human/proc/handle_disabilities()
	if (disabilities & EPILEPSY)
		if ((prob(1) && paralysis < 1))
			src << "<span class='danger'>You have a seizure!</span>"
			for(var/mob/O in viewers(src, null))
				if(O == src)
					continue
				O.show_message(text("<span class='userdanger'>[src] starts having a seizure!</span>"), 1)
			Paralyse(10)
			Jitter(1000)
	if (disabilities & COUGHING)
		if ((prob(5) && paralysis <= 1))
			drop_item()
			emote("cough")
	if (disabilities & TOURETTES)
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			switch(rand(1, 3))
				if(1)
					emote("twitch")
				if(2 to 3)
					say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
			var/x_offset = pixel_x + rand(-2,2) //Should probably be moved into the twitch emote at some point.
			var/y_offset = pixel_y + rand(-1,1)
			animate(src, pixel_x = pixel_x + x_offset, pixel_y = pixel_y + y_offset, time = 1)
			animate(pixel_x = pixel_x - x_offset, pixel_y = pixel_y - y_offset, time = 1)
	if (disabilities & NERVOUS)
		if (prob(10))
			stuttering = max(10, stuttering)
	if (getBrainLoss() >= 60 && stat != 2)
		if (prob(3))
			switch(pick(1,2,3))
				if(1)
					say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
				if(2)
					say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom", "PACKETS!!!"))
				if(3)
					emote("drool")


/mob/living/carbon/human/proc/handle_mutations_and_radiation()
	if(dna)
		dna.species.handle_mutations_and_radiation(src)

/mob/living/carbon/human/proc/breathe()
	if(dna)
		dna.species.breathe(src)

	return


/mob/living/carbon/human/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			return internal.remove_air_volume(volume_needed)
		else if(internals)
			internals.icon_state = "internal0"
	return null


	/*proc/handle_breath(datum/gas_mixture/breath)
		if((status_flags & GODMODE))
			return

		if(dna)
			dna.species.handle_breath(breath)

		return 1*/

/mob/living/carbon/human/proc/handle_environment(datum/gas_mixture/environment)
	if(dna)
		dna.species.handle_environment(environment, src)

	return

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(dna)
		dna.species.handle_fire(src)

	if(..())
		return
	var/thermal_protection = get_heat_protection(30000) //If you don't have fire suit level protection, you get a temperature increase
	if((1 - thermal_protection) > 0.0001)
		bodytemperature += BODYTEMP_HEATING_MAX
	return

/mob/living/carbon/human/IgniteMob()
	if(dna)
		dna.species.IgniteMob(src)
	else
		..()

/mob/living/carbon/human/ExtinguishMob()
	if(dna)
		dna.species.ExtinguishMob(src)
	else
		..()

//END FIRE CODE

	/*
/mob/living/carbon/human/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments*boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change
*/

/mob/living/carbon/human/proc/stabilize_temperature_from_calories()
	switch(bodytemperature)
		if(-INFINITY to 260.15) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
			if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
				nutrition -= 2
			var/body_temperature_difference = 310.15 - bodytemperature
			bodytemperature += max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(260.15 to 360.15)
			var/body_temperature_difference = 310.15 - bodytemperature
			bodytemperature += body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
		if(360.15 to INFINITY) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
			//We totally need a sweat system cause it totally makes sense...~
			var/body_temperature_difference = 310.15 - bodytemperature
			bodytemperature += min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers

//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, CHEST, GROIN, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


	return min(1,thermal_protection)

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_cold_protection(temperature)

	if(COLD_RESISTANCE in mutations)
		return 1 //Fully protected from the cold.

	if(dna && COLDRES in dna.species.specflags)
		return 1

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1,thermal_protection)

/*
/mob/living/carbon/human/proc/add_fire_protection(var/temp)
	var/fire_prot = 0
	if(head)
		if(head.protective_temperature > temp)
			fire_prot += (head.protective_temperature/10)
	if(wear_mask)
		if(wear_mask.protective_temperature > temp)
			fire_prot += (wear_mask.protective_temperature/10)
	if(glasses)
		if(glasses.protective_temperature > temp)
			fire_prot += (glasses.protective_temperature/10)
	if(ears)
		if(ears.protective_temperature > temp)
			fire_prot += (ears.protective_temperature/10)
	if(wear_suit)
		if(wear_suit.protective_temperature > temp)
			fire_prot += (wear_suit.protective_temperature/10)
	if(w_uniform)
		if(w_uniform.protective_temperature > temp)
			fire_prot += (w_uniform.protective_temperature/10)
	if(gloves)
		if(gloves.protective_temperature > temp)
			fire_prot += (gloves.protective_temperature/10)
	if(shoes)
		if(shoes.protective_temperature > temp)
			fire_prot += (shoes.protective_temperature/10)

	return fire_prot

/mob/living/carbon/human/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(nodamage)
		return
	//world <<"body_part = [body_part], exposed_temperature = [exposed_temperature], exposed_intensity = [exposed_intensity]"
	var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		discomfort *= 4

	if(mutantrace == "plant")
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT * 2 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
	else
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT //Dangercon 2011 - now with less magic numbers!
	//world <<"[discomfort]"

	switch(body_part)
		if(HEAD)
			apply_damage(2.5*discomfort, BURN, "head")
		if(CHEST)
			apply_damage(2.5*discomfort, BURN, "chest")
		if(LEGS)
			apply_damage(0.6*discomfort, BURN, "l_leg")
			apply_damage(0.6*discomfort, BURN, "r_leg")
		if(ARMS)
			apply_damage(0.4*discomfort, BURN, "l_arm")
			apply_damage(0.4*discomfort, BURN, "r_arm")
*/

/mob/living/carbon/human/proc/handle_chemicals_in_body()
	if(dna)
		dna.species.handle_chemicals_in_body(src)

	return //TODO: DEFERRED

/mob/living/carbon/human/proc/handle_regular_status_updates()
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()	//TODO
		if(health <= config.health_threshold_dead || !getorgan(/obj/item/organ/brain))
			death()
			blinded = 1
			silent = 0
			return 1


		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit >= health) )
			Paralyse(3)

			/* Done by handle_breath()
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)*/

		if(hallucination)
			if(hallucination >= 20)
				if(prob(3))
					fake_attack(src)
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!

			if(hallucination<=2)
				hallucination = 0
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				qdel(a)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			handle_dreams()
			adjustStaminaLoss(-10)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health && !hal_crit )
				spawn(0)
					emote("snore")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(tinttotal >= TINT_BLIND)		//covering your eyes heals blurry eyes faster
			eye_blurry = max(eye_blurry-3, 0)
		//	blinded = 1				//now handled under /handle_regular_hud_updates()
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(istype(ears, /obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster, and slowly heals deafness
			ear_damage = max(ear_damage-0.15, 0)
			ear_deaf = max(ear_deaf-1, 1)
		else if(ear_deaf) //deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Dizziness
		if(dizziness)
			var/client/C = client
			var/pixel_x_diff = 0
			var/pixel_y_diff = 0
			var/temp
			var/saved_dizz = dizziness
			dizziness = max(dizziness-1, 0)
			if(C)
				var/oldsrc = src
				var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70 // This shit is annoying at high strength
				src = null
				spawn(0)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
						sleep(3)
						if(C)
							temp = amplitude * sin(0.008 * saved_dizz * world.time)
							pixel_x_diff += temp
							C.pixel_x += temp
							temp = amplitude * cos(0.008 * saved_dizz * world.time)
							pixel_y_diff += temp
							C.pixel_y += temp
						sleep(3)
						if(C)
							C.pixel_x -= pixel_x_diff
							C.pixel_y -= pixel_y_diff
				src = oldsrc

		//Jitteryness
		if(jitteriness)
			var/amplitude = min(4, (jitteriness/100) + 1)
			var/pixel_x_diff = rand(-amplitude, amplitude)
			var/pixel_y_diff = rand(-amplitude/3, amplitude/3)

			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
			animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 2)
			jitteriness = max(jitteriness-1, 0)

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

		CheckStamina()

	return 1

/mob/living/carbon/human/proc/handle_regular_hud_updates()
	if(!client)	return 0

	regular_hud_updates() //For MED/SEC HUD icon deletion

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask)

	update_action_buttons()

	if(damageoverlay.overlays)
		damageoverlay.overlays = list()

	if(stat == UNCONSCIOUS)
		//Critical damage passage overlay
		if(health <= config.health_threshold_crit)
			var/image/I = image("icon" = 'icons/mob/screen_full.dmi', "icon_state" = "passage0")
			I.blend_mode = BLEND_OVERLAY //damageoverlay is BLEND_MULTIPLY
			switch(health)
				if(-20 to -10)
					I.icon_state = "passage1"
				if(-30 to -20)
					I.icon_state = "passage2"
				if(-40 to -30)
					I.icon_state = "passage3"
				if(-50 to -40)
					I.icon_state = "passage4"
				if(-60 to -50)
					I.icon_state = "passage5"
				if(-70 to -60)
					I.icon_state = "passage6"
				if(-80 to -70)
					I.icon_state = "passage7"
				if(-90 to -80)
					I.icon_state = "passage8"
				if(-95 to -90)
					I.icon_state = "passage9"
				if(-INFINITY to -95)
					I.icon_state = "passage10"
			damageoverlay.overlays += I
	else
		//Oxygen damage overlay
		if(oxyloss)
			var/image/I = image("icon" = 'icons/mob/screen_full.dmi', "icon_state" = "oxydamageoverlay0")
			switch(oxyloss)
				if(10 to 20)
					I.icon_state = "oxydamageoverlay1"
				if(20 to 25)
					I.icon_state = "oxydamageoverlay2"
				if(25 to 30)
					I.icon_state = "oxydamageoverlay3"
				if(30 to 35)
					I.icon_state = "oxydamageoverlay4"
				if(35 to 40)
					I.icon_state = "oxydamageoverlay5"
				if(40 to 45)
					I.icon_state = "oxydamageoverlay6"
				if(45 to INFINITY)
					I.icon_state = "oxydamageoverlay7"
			damageoverlay.overlays += I

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/image/I = image("icon" = 'icons/mob/screen_full.dmi', "icon_state" = "brutedamageoverlay0")
			I.blend_mode = BLEND_ADD
			switch(hurtdamage)
				if(5 to 15)
					I.icon_state = "brutedamageoverlay1"
				if(15 to 30)
					I.icon_state = "brutedamageoverlay2"
				if(30 to 45)
					I.icon_state = "brutedamageoverlay3"
				if(45 to 70)
					I.icon_state = "brutedamageoverlay4"
				if(70 to 85)
					I.icon_state = "brutedamageoverlay5"
				if(85 to INFINITY)
					I.icon_state = "brutedamageoverlay6"
			var/image/black = image(I.icon, I.icon_state) //BLEND_ADD doesn't let us darken, so this is just to blacken the edge of the screen
			black.color = "#170000"
			damageoverlay.overlays += I
			damageoverlay.overlays += black

		if(machine)
			if(!machine.check_eye(src))		reset_view(null)
		else
			if(!client.adminobs)			reset_view(null)

	if(dna)
		dna.species.handle_vision(src)
		dna.species.handle_hud_icons(src)

	return 1

/mob/living/carbon/human/proc/handle_random_events()
	// Puke if toxloss is too high
	if(!stat)
		if (getToxLoss() >= 45 && nutrition > 20)
			lastpuke ++
			if(lastpuke >= 25) // about 25 second delay I guess
				Stun(5)

				visible_message("<span class='danger'>[src] throws up!</span>", \
						"<span class='userdanger'>[src] throws up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				nutrition -= 20
				adjustToxLoss(-3)

				// make it so you can only puke so fast
				lastpuke = 0

/mob/living/carbon/human/proc/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living/carbon) && stat != 2)
				if(M.stat == 2)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(air_master.current_cycle%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

/mob/living/carbon/human/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS
