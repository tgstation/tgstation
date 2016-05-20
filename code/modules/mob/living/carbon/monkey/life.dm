//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/monkey
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0

	var/temperature_alert = 0


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	//set background = 1
	if(timestopped) return 0 //under effects of time magick

	if (monkeyizing)	return
	if (update_muts)
		update_muts=0
		domutcheck(src,null,MUTCHK_FORCED)
	..()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	if (stat != DEAD) //still breathing
		//Is not a Diona Nymph or Rock - Snowflake Code
		if(!istype(src,/mob/living/carbon/monkey/diona) && !istype(src,/mob/living/carbon/monkey/rock))
			//First, resolve location and get a breath
			if(air_master.current_cycle%4==2)
				//Only try to take a breath every 4 seconds, unless suffocating
				breathe()
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

		//Virus updates, duh
		handle_virus_updates()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	handle_body_temperature()

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()

	update_canmove()

	if(client)
		handle_regular_hud_updates()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(!client && stat == CONSCIOUS)

		if(prob(33) && canmove && isturf(loc) && !pulledby) //won't move if being pulled

			step(src, pick(cardinal))

		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey/calculate_affecting_pressure(var/pressure)
	..()
	return pressure

/mob/living/carbon/monkey

/mob/living/carbon/monkey/proc/handle_disabilities()


	if (disabilities & EPILEPSY)
		if ((prob(1) && paralysis < 10))
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
	if (disabilities & COUGHING)
		if ((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES)
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if (disabilities & NERVOUS)
		if (prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/monkey/proc/handle_mutations_and_radiation()
	if(flags & INVULNERABLE)
		return

	if(getFireLoss())
		if((M_RESIST_HEAT in mutations) || prob(50))
			switch(getFireLoss())
				if(1 to 50)
					adjustFireLoss(-1)
				if(51 to 100)
					adjustFireLoss(-5)

	if ((M_HULK in mutations) && health <= 25)
		mutations.Remove(M_HULK)
		to_chat(src, "<span class='warning'>You suddenly feel very weak.</span>")
		Weaken(3)
		emote("collapse")
		if(reagents.has_reagent("creatine"))
			var/datum/reagent/creatine/C = reagents.get_reagent("creatine")
			C.dehulk(src)

	if (radiation)

		if(istype(src,/mob/living/carbon/monkey/diona)) //Filthy check. Dionaea don't take rad damage.
			var/rads = radiation/25
			radiation -= rads
			nutrition += rads
			heal_overall_damage(rads,rads)
			adjustOxyLoss(-(rads))
			adjustToxLoss(-(rads))
			updatehealth()
			return

		if (radiation > 100)
			radiation = 100
			Weaken(10)
			to_chat(src, "<span class='warning'>You feel weak.</span>")
			emote("collapse")

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					Weaken(3)
					to_chat(src, "<span class='warning'>You feel weak.</span>")
					emote("collapse")
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				if(prob(1))
					to_chat(src, "<span class='warning'>You mutate!</span>")
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")
				updatehealth()

// separate proc so we can jump out of it when we've succeeded in spreading disease.
/mob/living/carbon/monkey/proc/findAirborneVirii()
	if(blood_virus_spreading_disabled)
		return 0
	for(var/obj/effect/decal/cleanable/blood/B in get_turf(src))
		if(B.virus2.len)
			for (var/ID in B.virus2)
				var/datum/disease2/disease/V = B.virus2[ID]
				if (infect_virus2(src,V, notes="(Airborne from blood)"))
					return 1

	for(var/obj/effect/decal/cleanable/mucus/M in get_turf(src))
		if(M.virus2.len)
			for (var/ID in M.virus2)
				var/datum/disease2/disease/V = M.virus2[ID]
				if (infect_virus2(src,V, notes="(Airborne from mucus)"))
					return 1
	return 0

/mob/living/carbon/monkey/proc/handle_virus_updates()
	if(status_flags & GODMODE)	return 0	//godmode
	if(bodytemperature > 406)
		for(var/datum/disease/D in viruses)
			D.cure()
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	src.findAirborneVirii()

	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
			CRASH("virus2 nulled before calling activate()")
		else
			V.activate(src)
		// activate may have deleted the virus
		if(!V) continue

		// check if we're immune
		if(V.antigen & src.antibodies)
			V.dead = 1

	return

/mob/living/carbon/monkey/proc/breathe()
	if(flags & INVULNERABLE)
		return

	if(reagents)
		if(reagents.has_reagent("lexorin")) return

	if(!loc) return //probably ought to make a proper fix for this, but :effort: --NeoFite

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	if(health < 0)
		losebreath++
	if(losebreath>0) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				var/breath_moles = environment.total_moles()*BREATH_PERCENTAGE
				breath = loc.remove_air(breath_moles)

				// Handle chem smoke effect  -- Doohl
				var/block = 0
				if(wear_mask)
					if(istype(wear_mask, /obj/item/clothing/mask/gas))
						block = 1

				if(!block)
					for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
							break // If they breathe in the nasty stuff once, no need to continue checking


		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)
	if(breath)
		loc.assume_air(breath)


/mob/living/carbon/monkey/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags|MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return null

/mob/living/carbon/monkey/proc/handle_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return

	if(!breath || (breath.total_moles == 0))
		adjustOxyLoss(7)

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.5
	var/safe_toxins_mask = 5
	var/SA_para_min = 0.5
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	//Partial pressure of the O2 in our breath
	var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
	// Same, but for the toxins
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure

	if(O2_pp < safe_oxygen_min) 			// Too little oxygen
		if(prob(20))
			spawn(0) emote("gasp")
		if (O2_pp == 0)
			O2_pp = 0.01
		var/ratio = safe_oxygen_min/O2_pp
		adjustOxyLoss(min(5*ratio, 7)) // Don't fuck them up too fast (space only does 7 after all!)
		oxygen_used = breath.oxygen*ratio/6
		oxygen_alert = max(oxygen_alert, 1)
	/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
		spawn(0) emote("cough")
		var/ratio = O2_pp/safe_oxygen_max
		oxyloss += 5*ratio
		oxygen_used = breath.oxygen*ratio/6
		oxygen_alert = max(oxygen_alert, 1)*/
	else 									// We're in safe limits
		adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		oxygen_alert = 0

	breath.oxygen -= oxygen_used
	breath.carbon_dioxide += oxygen_used

	if(CO2_pp > safe_co2_max)
		if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			emote("cough")

	else
		co2overloadtime = 0

	if(Toxins_pp > safe_toxins_max) // Too much toxins
		var/ratio = (breath.toxins/safe_toxins_max) * 10
		//adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(wear_mask)
			if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
				if(breath.toxins > safe_toxins_mask)
					ratio = (breath.toxins/safe_toxins_mask) * 10
				else
					ratio = 0
		if(ratio)
			if(reagents)
				reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
			toxins_alert = max(toxins_alert, 1)
	else
		toxins_alert = 0

	if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
				Paralyse(3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
					sleeping = max(sleeping+2, 10)
			else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					spawn(0) emote(pick("giggle", "laugh"))


	if(breath.temperature > (T0C+66)) // Hot air hurts :(
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel a searing heat in your lungs!</span>")
		fire_alert = max(fire_alert, 2)
	else
		fire_alert = 0


	//Temporary fixes to the alerts.

	return 1

/mob/living/carbon/monkey/get_thermal_protection_flags()
	var/thermal_protection_flags = 0
	if(hat)
		thermal_protection_flags |= hat.body_parts_covered
	if(wear_mask)
		thermal_protection_flags |= wear_mask.body_parts_covered
	if(uniform)
		thermal_protection_flags |= uniform.body_parts_covered
	return thermal_protection_flags

/mob/living/carbon/monkey/get_cold_protection()

	var/thermal_protection = 0.0

	if(hat)
		thermal_protection += hat.return_thermal_protection()
	if(wear_mask)
		thermal_protection += wear_mask.return_thermal_protection()
	if(uniform)
		thermal_protection += uniform.return_thermal_protection()

	var/max_protection = get_thermal_protection(get_thermal_protection_flags())
	return min(thermal_protection,max_protection)

/mob/living/carbon/monkey/get_heat_protection_flags(temperature)
	var/thermal_protection_flags = 0
	if(hat && hat.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= hat.body_parts_covered
	if(wear_mask && wear_mask.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= wear_mask.body_parts_covered
	if(uniform && uniform.max_heat_protection_temperature >= temperature)
		thermal_protection_flags |= uniform.body_parts_covered
	return thermal_protection_flags


/mob/living/carbon/monkey/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment || (flags & INVULNERABLE))
		return
	var/spaceproof = 0
	if(hat && istype(hat, /obj/item/clothing/head/helmet/space) && uniform && istype(uniform, /obj/item/clothing/monkeyclothes/space))
		spaceproof = 1	//quick and dirt cheap. no need for the Life() of monkeys to become as complicated as the Life() of humans. man that's deep.
	var/loc_temp = get_loc_temp(environment)
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < get_skin_temperature())
			var/thermal_loss = get_thermal_loss(environment)
			bodytemperature -= thermal_loss
		else
			var/thermal_protection = get_thermal_protection(get_heat_protection_flags(loc_temp)) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1 - thermal_protection) * ((loc_temp - get_skin_temperature()) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	if(stat==DEAD)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			if(!spaceproof)
				pressure_alert = -1
		else
			if(!spaceproof)
				if( !(M_RESIST_COLD in mutations) )
					adjustBruteLoss( LOW_PRESSURE_DAMAGE )
					pressure_alert = -2
				else
					pressure_alert = -1

	return

/mob/living/carbon/monkey/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return
	var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
	//adjustFireLoss(2.5*discomfort)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0*discomfort)

	else
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/monkey/proc/handle_chemicals_in_body()


	if(alien) //Diona nymphs are the only alien monkey currently.
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			if(T.dynamic_lighting)
				light_amount = T.get_lumcount(0.5)
			else
				light_amount = 5
		nutrition += light_amount
		traumatic_shock -= light_amount

		if(nutrition > 500)
			nutrition = 500
		if(light_amount > 2) //if there's enough light, heal
			adjustBruteLoss(-1)
			adjustToxLoss(-1)
			adjustOxyLoss(-1)
	burn_calories(HUNGER_FACTOR,1)
	if(reagents) reagents.metabolize(src,alien)

	if (drowsyness > 0)
		drowsyness = max(0, drowsyness - 1)
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping += 1
			Paralyse(5)

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	updatehealth()
	return //TODO: DEFERRED

/mob/living/carbon/monkey/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()
		if(health < config.health_threshold_dead || !has_brain())
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (config.health_threshold_crit > health) )
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)
			Paralyse(3)
		if(halloss > 100)
			to_chat(src, "<span class='notice'>You're in too much pain to keep going...</span>")
			for(var/mob/O in oviewers(src, null))
				O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			handle_dreams()
			adjustHalLoss(-3)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health && !hal_crit )
				spawn(0)
					emote("snore")
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)
		//CONSCIOUS
		else if(undergoing_hypothermia() >= SEVERE_HYPOTHERMIA)
			stat = UNCONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)			//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1


/mob/living/carbon/monkey/proc/handle_regular_hud_updates()


	if(!canWearHats && m_hatbg)
		if(m_hatbg.icon_state != "blank")
			m_hatbg.icon_state = "blank"

	if(!canWearClothes && m_suitclothesbg)
		if(m_suitclothesbg.icon_state != "blank")
			m_suitclothesbg.icon_state = "blank"

	if(!canWearGlasses && m_glassesbg)
		if(m_glassesbg.icon_state != "blank")
			m_glassesbg.icon_state = "blank"


	if (stat == 2 || (M_XRAY in mutations))
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING

	if (healths)
		if (stat != 2)
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


	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 2 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	if(bodytemp)
		switch(bodytemperature) //310.055 optimal body temp
			if(345 to INFINITY)
				bodytemp.icon_state = "temp4"
			if(335 to 345)
				bodytemp.icon_state = "temp3"
			if(327 to 335)
				bodytemp.icon_state = "temp2"
			if(316 to 327)
				bodytemp.icon_state = "temp1"
			if(300 to 316)
				bodytemp.icon_state = "temp0"
			if(295 to 300)
				bodytemp.icon_state = "temp-1"
			if(280 to 295)
				bodytemp.icon_state = "temp-2"
			if(260 to 280)
				bodytemp.icon_state = "temp-3"
			else
				bodytemp.icon_state = "temp-4"

	if(stat != DEAD)
		if(src.eye_blind || blinded)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
		if (src.disabilities & NEARSIGHTED)
			overlay_fullscreen("impaired", /obj/screen/fullscreen/impaired, 2)
		else
			clear_fullscreen("impaired")
		if (src.eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")
		if (src.druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
		else
			clear_fullscreen("high")

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs && !isTeleViewing(client.eye))
				reset_view(null)

	return 1

/mob/living/carbon/monkey/proc/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return


/mob/living/carbon/monkey/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

///FIRE CODE
/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return
//END FIRE CODE
