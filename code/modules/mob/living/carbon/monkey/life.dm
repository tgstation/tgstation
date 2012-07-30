//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/monkey
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0

	var/temperature_alert = 0


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	set background = 1
	if (monkeyizing)	return
	..()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	if (stat != DEAD) //still breathing
		//First, resolve location and get a breath
		if(air_master.current_cycle%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			breathe()
		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		//Disease Check
		handle_virus_updates()

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	//Flashlights and such
	UpdateLuminosity()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(!client && !stat)
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey/calculate_affecting_pressure(var/pressure)
	..()
	return pressure

/mob/living/carbon/monkey

	proc/handle_disabilities()

		if (disabilities & EPILEPSY)
			if ((prob(1) && paralysis < 10))
				src << "\red You have a seizure!"
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

	proc/update_mind()
		if(!mind && client)
			mind = new
			mind.current = src
			mind.key = key

	proc/handle_mutations_and_radiation()

		if(getFireLoss())
			if((COLD_RESISTANCE in mutations) || prob(50))
				switch(getFireLoss())
					if(1 to 50)
						adjustFireLoss(-1)
					if(51 to 100)
						adjustFireLoss(-5)

		if ((HULK in mutations) && health <= 25)
			mutations.Remove(HULK)
			src << "\red You suddenly feel very weak."
			Weaken(3)
			emote("collapse")

		if (radiation)
			if (radiation > 100)
				radiation = 100
				Weaken(10)
				src << "\red You feel weak."
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
						src << "\red You feel weak."
						emote("collapse")
					updatehealth()

				if(75 to 100)
					radiation -= 3
					adjustToxLoss(3)
					if(prob(1))
						src << "\red You mutate!"
						randmutb(src)
						domutcheck(src,null)
						emote("gasp")
					updatehealth()


	proc/breathe()
		if(reagents)

			if(reagents.has_reagent("lexorin")) return

		if(!loc) return //probably ought to make a proper fix for this, but :effort: --NeoFite

		var/datum/gas_mixture/environment = loc.return_air()
		var/datum/air_group/breath

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

						for(var/obj/effect/effect/chem_smoke/smoke in view(1, src))
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


	proc/get_breath_from_internal(volume_needed)
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

	proc/handle_breath(datum/gas_mixture/breath)
		if(nodamage)
			return

		if(!breath || (breath.total_moles() == 0))
			adjustOxyLoss(7)

			oxygen_alert = max(oxygen_alert, 1)

			return 0

		var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
		//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
		var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
		var/safe_toxins_max = 0.5
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
				spawn(0) emote("cough")

		else
			co2overloadtime = 0

		if(Toxins_pp > safe_toxins_max) // Too much toxins
			var/ratio = breath.toxins/safe_toxins_max
			adjustToxLoss(min(ratio, 10))	//Limit amount of damage toxin exposure can do per second
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
				src << "\red You feel a searing heat in your lungs!"
			fire_alert = max(fire_alert, 1)
		else
			fire_alert = 0


		//Temporary fixes to the alerts.

		return 1

	proc/handle_environment(datum/gas_mixture/environment)
		if(!environment)
			return
		var/environment_heat_capacity = environment.heat_capacity()
		if(istype(get_turf(src), /turf/space))
			var/turf/heat_turf = get_turf(src)
			environment_heat_capacity = heat_turf.heat_capacity

		if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
			var/transfer_coefficient

			transfer_coefficient = 1
			if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
				transfer_coefficient *= wear_mask.heat_transfer_coefficient

			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

		if(stat==2)
			bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

		//Account for massive pressure differences
		var/pressure = environment.return_pressure()
		if(pressure > HAZARD_HIGH_PRESSURE)
			var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
			if(adjusted_pressure > HAZARD_HIGH_PRESSURE)
				adjustBruteLoss( min( (adjusted_pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT , MAX_PRESSURE_DAMAGE) )

		return //TODO: DEFERRED

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
		if(nodamage) return
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)

		if(exposed_temperature > bodytemperature)
			adjustFireLoss(20.0*discomfort)

		else
			adjustFireLoss(5.0*discomfort)

	proc/handle_chemicals_in_body()

		if(reagents) reagents.metabolize(src)

		if (drowsyness)
			drowsyness--
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

	proc/handle_regular_status_updates()
		updatehealth()

		if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
			blinded = 1
			silent = 0
		else				//ALIVE. LIGHTS ARE ON
			if(health < config.health_threshold_dead || brain_op_stage == 4.0)
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

			if(paralysis)
				AdjustParalysis(-1)
				blinded = 1
				stat = UNCONSCIOUS
			else if(sleeping)
				sleeping = max(sleeping-1, 0)
				blinded = 1
				stat = UNCONSCIOUS
				if( prob(10) && health )
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


	proc/handle_regular_hud_updates()

		if (stat == 2 || (XRAY in mutations))
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

		if (sleep) sleep.icon_state = text("sleep[]", sleeping)
		if (rest) rest.icon_state = text("rest[]", resting)

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

		if (pressure)
			var/datum/gas_mixture/environment = loc.return_air()
			if(environment)
				switch(environment.return_pressure())

					if(HAZARD_HIGH_PRESSURE to INFINITY)
						pressure.icon_state = "pressure2"
					if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
						pressure.icon_state = "pressure1"
					if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
						pressure.icon_state = "pressure0"
					if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
						pressure.icon_state = "pressure-1"
					else
						pressure.icon_state = "pressure-2"

		if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


		if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
		if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
		if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
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

		client.screen -= hud_used.blurry
		client.screen -= hud_used.druggy
		client.screen -= hud_used.vimpaired

		if ((blind && stat != 2))
			if ((blinded))
				blind.layer = 18
			else
				blind.layer = 0

				if (disabilities & NEARSIGHTED)
					client.screen += hud_used.vimpaired

				if (eye_blurry)
					client.screen += hud_used.blurry

				if (druggy)
					client.screen += hud_used.druggy

		if (stat != 2)
			if (machine)
				if (!( machine.check_eye(src) ))
					reset_view(null)
			else
				if(!client.adminobs)
					reset_view(null)

		return 1

	proc/handle_random_events()
		if (prob(1) && prob(2))
			spawn(0)
				emote("scratch")
				return

	proc/handle_virus_updates()
		if(bodytemperature > 406)
			for(var/datum/disease/D in viruses)
				D.cure()
		return

	proc/handle_changeling()
		if (mind)
			if (mind.special_role == "Changeling" && changeling)
				changeling.chem_charges = between(0, ((max((0.9 - (changeling.chem_charges / 50)), 0.1)*changeling.chem_recharge_multiplier) + changeling.chem_charges), changeling.chem_storage)
				if ((changeling.geneticdamage > 0))
					changeling.geneticdamage = changeling.geneticdamage-1
