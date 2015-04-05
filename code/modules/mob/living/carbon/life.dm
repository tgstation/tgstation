/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return

	if(..())
		//Updates the number of stored chemicals for powers
		handle_changeling()
		//Heart Attacks, etc.
		handle_heart()

		. = 1

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing()
	if(SSmob.times_fired%4==2 || failed_last_breath)
		breathe() //Breathe per 4 ticks, unless suffocating
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= config.health_threshold_crit)
		losebreath++

	//Suffocate
	if(losebreath > 0)
		losebreath--
		if(prob(10))
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(!breath)

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

				//Harmful gasses
				if(!has_smoke_protection())
					for(var/obj/effect/effect/chem_smoke/smoke in view(1,src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src,INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10)
							break

		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	return 0


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE))
		return

	//CRIT
	if(!breath || (breath.total_moles() == 0))
		if(reagents.has_reagent("epinephrine"))
			return
		adjustOxyLoss(1)
		failed_last_breath = 1
		throw_alert("oxy")

		return 0

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/O2_partialpressure = (breath.oxygen/breath.total_moles())*breath_pressure
	var/Toxins_partialpressure = (breath.toxins/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath.carbon_dioxide/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			spawn(0)
				emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = safe_oxy_min/O2_partialpressure
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = breath.oxygen*ratio/6
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("oxy")

	else //Enough oxygen
		failed_last_breath = 0
		adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		clear_alert("oxy")

	breath.oxygen -= oxygen_used
	breath.carbon_dioxide += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			spawn(0) emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.toxins/safe_tox_max) * 10
		if(reagents)
			reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		throw_alert("tox_in_air")
	else
		clear_alert("tox_in_air")

	//TRACE GASES
	if(breath.trace_gases.len)
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_partialpressure = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_partialpressure > SA_para_min)
				Paralyse(3)
				if(SA_partialpressure > SA_sleep_min)
					sleeping = max(sleeping+2, 10)
			else if(SA_partialpressure > 0.01)
				if(prob(20))
					spawn(0) emote(pick("giggle","laugh"))

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return


/mob/living/carbon/proc/handle_changeling()
	return

/mob/living/carbon/handle_mutations_and_radiation()
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


/mob/living/carbon/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

/mob/living/carbon/handle_blood()
	return

/mob/living/carbon/handle_random_events()
	return

/mob/living/carbon/proc/handle_heart()
	return
/mob/living/carbon/handle_environment(var/datum/gas_mixture/environment)	return

/mob/living/carbon/handle_stomach()
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
				if(SSmob.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

//This updates the health and status of the mob (conscious, unconscious, dead)
/mob/living/carbon/handle_regular_status_updates()

	if(..()) //alive

		if(!getorgan(/obj/item/organ/brain))
			death()
			return
		if(getBrainLoss() >= 100 && stat != DEAD)
			Weaken(20)
			losebreath += 10
			silent += 2
		if(getBrainLoss() >= 120 && stat != DEAD)
			visible_message("<span class='danger'><B>[src]</B> goes limp, their facial expression utterly blank.</span>")
			death()
		if(sleeping)
			stat = UNCONSCIOUS

		CheckStamina()
		return 1

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()

	if(sleeping)
		handle_dreams()
		adjustStaminaLoss(-10)
		sleeping = max(sleeping-1, 0)
		if( prob(10) && health && !hal_crit )
			spawn(0)
				emote("snore")

	var/restingpwr = 1 + 4 * resting

	//Dizziness
	if(dizziness)
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
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
		dizziness = max(dizziness - restingpwr, 0)

	if(drowsyness)
		drowsyness = max(drowsyness - restingpwr, 0)
		eye_blurry = max(2, eye_blurry)
		if(prob(5))
			sleeping += 1
			Paralyse(5)

	if(confused)
		confused = max(0, confused - 1)

	//Jitteryness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - restingpwr, 0)

	if(stuttering)
		stuttering = max(stuttering-1, 0)

	if(slurring)
		slurring = max(slurring-1,0)

	if(silent)
		silent = max(silent-1, 0)

	if(druggy)
		druggy = max(druggy-1, 0)

	if(hallucination)
		spawn handle_hallucinations()

		if(hallucination<=2)
			hallucination = 0
		else
			hallucination -= 2

	else
		for(var/atom/a in hallucinations)
			qdel(a)

//this handles hud updates. Calls update_vision() and handle_hud_icons()
/mob/living/carbon/handle_regular_hud_updates()
	if(!client)	return 0

	update_action_buttons()

	if(damageoverlay)
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

	..()

	return 1

/mob/living/carbon/update_sight()

	if(stat == DEAD)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		if(!(SEE_TURFS & permanent_sight_flags))
			sight &= ~SEE_TURFS
		if(!(SEE_MOBS & permanent_sight_flags))
			sight &= ~SEE_MOBS
		if(!(SEE_OBJS & permanent_sight_flags))
			sight &= ~SEE_OBJS

		see_in_dark = (sight == SEE_TURFS|SEE_MOBS|SEE_OBJS) ? 8 : 2  //Xray flag combo
		see_invisible = SEE_INVISIBLE_LIVING
		if(see_override)
			see_invisible = see_override


/mob/living/carbon/handle_hud_icons()
	return

/mob/living/carbon/handle_hud_icons_health()
	if(healths)
		if (stat != DEAD)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

/mob/living/carbon/handle_crit()
	var/paralyse_amount = 0
	var/losebreath_amount = 0
	var/cardiac_arrest_chance = 0
	var/brain_damage_from_crit = 0
	if(!is_incrit(src))
		if(was_incrit)
			losebreath -= 5
			adjustOxyLoss(-1)
			if(losebreath < 0)
				losebreath = 0
			if(!losebreath && !getOxyLoss())
				was_incrit = 0
		return
	else
		was_incrit = 1
		switch(health)
			if(-9 to 0)
				paralyse_amount = 1
				losebreath_amount = 1
				cardiac_arrest_chance = 0
				brain_damage_from_crit = 0
				world << "stage1"
			if(-19 to -10)
				paralyse_amount = 1
				losebreath_amount = 2
				cardiac_arrest_chance = 0
				brain_damage_from_crit = 0
				world << "stage2"
			if(-29 to -20)
				paralyse_amount = 1
				losebreath_amount = 5
				cardiac_arrest_chance = 5
				brain_damage_from_crit = 0
				world << "stage3"
			if(-39 to -30)
				paralyse_amount = 1
				losebreath_amount = 8
				cardiac_arrest_chance = 10
				brain_damage_from_crit = 0
				world << "stage4"
			if(-49 to -40)
				paralyse_amount = 1
				losebreath_amount = 8
				cardiac_arrest_chance = 15
				brain_damage_from_crit = 0
				world << "stage5"
			if(-59 to -50)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 20
				brain_damage_from_crit = 1
				world << "stage6"
			if(-69 to -60)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 25
				brain_damage_from_crit = 1
				world << "stage7"
			if(-79 to -70)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 30
				brain_damage_from_crit = 1
				world << "stage8"
			if(-89 to -80)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 35
				brain_damage_from_crit = 2
				world << "stage9"
			if(-94 to -90)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 40
				brain_damage_from_crit = 2
				world << "stage10"
			if(-INFINITY to -95)
				paralyse_amount = 2
				losebreath_amount = 8
				cardiac_arrest_chance = 45
				brain_damage_from_crit = 2
				world << "stage11"
		var/picked_effect = rand(1,4)
		switch(picked_effect)
			if(1)
				Paralyse(paralyse_amount)
			if(2)
				losebreath += losebreath_amount
				adjustBrainLoss(brain_damage_from_crit)
			if(3)
				if(prob(cardiac_arrest_chance))
					if(!heart_attack)
						src << "<span class = 'userdanger'>Your heart stops!</span>"
						heart_attack = 1
					else
						losebreath += losebreath_amount
			if(4)
				Paralyse(paralyse_amount)
		if(!reagents.has_reagent("epinephrine"))
			adjustBrainLoss(brain_damage_from_crit)
			world << "dealing [brain_damage_from_crit] of brain loss"
		stuttering += 5
		if(!reagents.has_reagent("epinephrine"))
			adjustOxyLoss(2)
		var/deathprob = (getBrainLoss()/4)
		if(prob(deathprob) && health <= -100)
			world << "CRITDEATH [deathprob]"
			death()
	return
