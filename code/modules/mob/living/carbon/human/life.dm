//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!


#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

#define HUMAN_MAX_OXYLOSS 3 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.

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

	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.
	tinttotal = tintcheck() //here as both hud updates and status updates call it

	if(..())
		if(dna)
			for(var/datum/mutation/human/HM in dna.mutations)
				HM.on_life(src)
		if(SSmob.times_fired%4==2 || failed_last_breath) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)


		//Stuff jammed in your limbs hurts
		handle_embedded_objects()
	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	if(dna)
		dna.species.spec_life(src) // for mutantraces


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


/mob/living/carbon/human/handle_disabilities()
	if (getBrainLoss() >= 60 && stat != 2)
		if (prob(3))
			switch(pick(1,2,3))
				if(1)
					say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
				if(2)
					say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom", "PACKETS!!!"))
				if(3)
					emote("drool")


/mob/living/carbon/human/handle_mutations_and_radiation()
	if(dna)
		dna.species.handle_mutations_and_radiation(src)

/mob/living/carbon/human/proc/breathe()
	if(dna)
		dna.species.breathe(src)

	return

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(dna)
		dna.species.handle_environment(environment, src)

	return

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(dna)
		dna.species.handle_fire(src)
	if(..())
		return
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		return
	if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT)
		bodytemperature += 11
		return
	else
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
			bodytemperature += max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(260.15 to 360.15)
			var/body_temperature_difference = 310.15 - bodytemperature
			bodytemperature += body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR
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

	if(dna.check_mutation(COLDRES))
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

/mob/living/carbon/human/handle_chemicals_in_body()
	if(dna)
		dna.species.handle_chemicals_in_body(src)

	return //TODO: DEFERRED

/mob/living/carbon/human/handle_regular_status_updates()
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()	//TODO
		if(health <= config.health_threshold_dead || !getorgan(/obj/item/organ/brain))
			death()
			silent = 0
			return 1


		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit >= health) )
			Paralyse(3)

		if(hallucination)
			spawn handle_hallucinations()

			if(hallucination<=2)
				hallucination = 0
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				qdel(a)

		if(paralysis)
			AdjustParalysis(-1)
			stat = UNCONSCIOUS
		else if(sleeping)
			handle_dreams()
			adjustStaminaLoss(-10)
			sleeping = max(sleeping-1, 0)
			stat = UNCONSCIOUS
			if( prob(10) && health && !hal_crit )
				spawn(0)
					emote("snore")
		else if (status_flags & FAKEDEATH)
			stat = UNCONSCIOUS
		//CONSCIOUS
		else
			stat = CONSCIOUS

		//Eyes
		if(disabilities & BLIND || stat)	//disabled-blind, doesn't get better on its own
			eye_blind = max(eye_blind, 1)
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
		else if(tinttotal >= TINT_BLIND)		//covering your eyes heals blurry eyes faster
			eye_blurry = max(eye_blurry-3, 0)
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(disabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			setEarDamage(-1, max(ear_deaf, 1))
		else if (ear_damage < 100) // deafness heals slowly over time, unless ear_damage is over 100
			if(istype(ears, /obj/item/clothing/ears/earmuffs)) // earmuffs rest your ears, healing 3x faster, but keeping you deaf.
				setEarDamage(max(ear_damage-0.15, 0), max(ear_deaf - 1, 1))
			else
				adjustEarDamage(-0.05, -1)

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
			do_jitter_animation(jitteriness)
			jitteriness = max(jitteriness-1, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(slurring)
			slurring = max(slurring-1,0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)

		CheckStamina()

	if(dna)
		dna.species.handle_vision(src)

	return 1

/mob/living/carbon/human/handle_regular_hud_updates()
	if(!client)	return 0

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
		dna.species.handle_hud_icons(src)

	return 1

/mob/living/carbon/human/handle_random_events()
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


/mob/living/carbon/human/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()


/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			if(prob(I.embedded_pain_chance))
				L.take_damage(I.w_class*2)
				src << "<span class='userdanger'>\the [I] embedded in your [L.getDisplayName()] hurts!</span>"

			if(prob(I.embedded_fall_chance))
				L.take_damage(I.w_class*5)
				L.embedded_objects -= I
				I.loc = get_turf(src)
				visible_message("<span class='danger'>\the [I] falls out of [name]'s [L.getDisplayName()]!</span>","<span class='userdanger'>\the [I] falls out of your [L.getDisplayName()]!</span>")

#undef HUMAN_MAX_OXYLOSS
