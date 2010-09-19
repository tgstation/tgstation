/mob/living/carbon/alien/humanoid
	var
		oxygen_alert = 0
		toxins_alert = 0
		fire_alert = 0

		temperature_alert = 0


/mob/living/carbon/alien/humanoid/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	if (src.stat != 2) //still breathing

		//First, resolve location and get a breath

		if(air_master.current_cycle%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()

	//Handle temperature/pressure differences between body and environment
	handle_environment()

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()

	//stuff in the stomach
	handle_stomach()

	//Disabilities
	handle_disabilities()

	//Status updates, death etc.
	handle_regular_status_updates()

	// Update clothing
	update_clothing()

	if(client)
		handle_regular_hud_updates()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()


/mob/living/carbon/alien/humanoid
	proc
		clamp_values()

			stunned = max(min(stunned, 20),0)
			paralysis = max(min(paralysis, 20), 0)
			weakened = max(min(weakened, 20), 0)
			sleeping = max(min(sleeping, 20), 0)
			bruteloss = max(bruteloss, 0)
			toxloss = max(toxloss, 0)
			oxyloss = max(oxyloss, 0)
			fireloss = max(fireloss, 0)


		handle_disabilities()

			if (src.disabilities & 2)
				if ((prob(1) && src.paralysis < 10 && src.r_epil < 1))
					src << "\red You have a seizure!"
					src.paralysis = max(10, src.paralysis)
			if (src.disabilities & 4)
				if ((prob(5) && src.paralysis <= 1 && src.r_ch_cou < 1))
					src.drop_item()
					spawn( 0 )
						emote("cough")
						return
			if (src.disabilities & 8)
				if ((prob(10) && src.paralysis <= 1 && src.r_Tourette < 1))
					src.stunned = max(10, src.stunned)
					spawn( 0 )
						emote("twitch")
						return
			if (src.disabilities & 16)
				if (prob(10))
					src.stuttering = max(10, src.stuttering)

		handle_mutations_and_radiation()

			if(src.fireloss)
				if(src.mutations & 2 || prob(50))
					switch(src.fireloss)
						if(1 to 50)
							src.fireloss--
						if(51 to 100)
							src.fireloss -= 5

			if (src.mutations & 8 && src.health <= 25)
				src.mutations &= ~8
				src << "\red You suddenly feel very weak."
				src.weakened = 3
				emote("collapse")

			if (src.radiation)
				if (src.radiation > 100)
					src.radiation = 100
					src.weakened = 10
					src << "\red You feel weak."
					emote("collapse")

				if (src.radiation < 0)
					src.radiation = 0

				switch(src.radiation)
					if(1 to 49)
						src.radiation--
						if(prob(25))
							src.toxloss++
							src.updatehealth()

					if(50 to 74)
						src.radiation -= 2
						src.toxloss++
						if(prob(5))
							src.radiation -= 5
							src.weakened = 3
							src << "\red You feel weak."
							emote("collapse")
						src.updatehealth()

					if(75 to 100)
						src.radiation -= 3
						src.toxloss += 3
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						src.updatehealth()


		breathe()

			if(src.reagents.has_reagent("lexorin")) return
			if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

			var/datum/gas_mixture/environment = loc.return_air()
			var/datum/air_group/breath
			// HACK NEED CHANGING LATER
			if(src.health < 0)
				src.losebreath++

			if(losebreath>0) //Suffocating so do not take a breath
				src.losebreath--
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
						var/breath_moles = 0
						/*if(environment.return_pressure() > ONE_ATMOSPHERE)
							// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
							breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
						else*/
							// Not enough air around, take a percentage of what's there to model this properly
						breath_moles = environment.total_moles()*BREATH_PERCENTAGE

						breath = loc.remove_air(breath_moles)

				else //Still give containing object the chance to interact
					if(istype(loc, /obj/))
						var/obj/location_as_object = loc
						location_as_object.handle_internal_lifeform(src, 0)

			handle_breath(breath)

			if(breath)
				loc.assume_air(breath)


		get_breath_from_internal(volume_needed)
			if(internal)
				if (!contents.Find(src.internal))
					internal = null
				if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
					internal = null
				if(internal)
					if (src.internals)
						src.internals.icon_state = "internal1"
					return internal.remove_air_volume(volume_needed)
				else
					if (src.internals)
						src.internals.icon_state = "internal0"
			return null

		update_canmove()
			if(paralysis || stunned || weakened || buckled) canmove = 0
			else canmove = 1

		handle_breath(datum/gas_mixture/breath)
			if(src.nodamage)
				return

			if(!breath || (breath.total_moles() == 0))
				//Aliens breathe in vaccuum
				return 0

			var/toxins_used = 0
			var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

			//Partial pressure of the toxins in our breath
			var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure

			if(Toxins_pp) // Detect toxins in air

				toxloss += breath.toxins*250
				toxins_alert = max(toxins_alert, 1)

				toxins_used = breath.toxins

			else
				toxins_alert = 0

			//Breathe in toxins and out oxygen
			breath.toxins -= toxins_used
			breath.oxygen += toxins_used

			if(breath.temperature > (T0C+66) && !(src.mutations & 2)) // Hot air hurts :(
				if(prob(20))
					src << "\red You feel a searing heat in your lungs!"
				fire_alert = max(fire_alert, 1)
			else
				fire_alert = 0

			//Temporary fixes to the alerts.

			return 1

		handle_environment()

			//If there are alien weeds on the ground then heal if needed or give some toxins
			if(locate(/obj/alien/weeds) in loc)
				if(health >= 100)
					toxloss += 5
					if(toxloss > max_plasma)
						toxloss = max_plasma

				else
					bruteloss -= 5
					fireloss -= 5



		adjust_body_temperature(current, loc_temp, boost)
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

		get_thermal_protection()
			var/thermal_protection = 1.0
			//Handle normal clothing
			if(head && (head.body_parts_covered & HEAD))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & LEGS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & ARMS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & HANDS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.flags & SUITSPACE))
				thermal_protection += 3
			if(src.mutations & 2)
				thermal_protection += 5

			return thermal_protection

		add_fire_protection(var/temp)
			var/fire_prot = 0
			if(head)
				if(head.protective_temperature > temp)
					fire_prot += (head.protective_temperature/10)
			if(wear_mask)
				if(wear_mask.protective_temperature > temp)
					fire_prot += (wear_mask.protective_temperature/10)
			if(wear_suit)
				if(wear_suit.protective_temperature > temp)
					fire_prot += (wear_suit.protective_temperature/10)


			return fire_prot

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

			if(src.nutrition > 400 && !(src.mutations & 32))
				if(prob(5 + round((src.nutrition - 200) / 2)))
					src << "\red You suddenly feel blubbery!"
					src.mutations |= 32
//					update_body()
			if (src.nutrition < 100 && src.mutations & 32)
				if(prob(round((50 - src.nutrition) / 100)))
					src << "\blue You feel fit again!"
					src.mutations &= ~32
//					update_body()
			if (src.nutrition > 0)
				src.nutrition--

			if (src.drowsyness)
				src.drowsyness--
				src.eye_blurry = max(2, src.eye_blurry)
				if (prob(5))
					src.sleeping = 1
					src.paralysis = 5

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 5)
				jitteriness = max(0, jitteriness - 5)
			else
				dizziness = max(0, dizziness - 1)
				jitteriness = max(0, jitteriness - 1)

			src.updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

			health = 100 - (oxyloss + fireloss + bruteloss)

			if(oxyloss > 50) paralysis = max(paralysis, 3)

			if(src.sleeping)
				src.paralysis = max(src.paralysis, 3)
				if (prob(10) && health) spawn(0) emote("snore")
				src.sleeping--

			if(src.resting)
				src.weakened = max(src.weakened, 5)

			if(health < -100 || src.brain_op_stage == 4.0)
				death()
			else if(src.health < 0)
				if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!src.rejuv) src.oxyloss++
				if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

				if(src.stat != 2)	src.stat = 1
				src.paralysis = max(src.paralysis, 5)

			if (src.stat != 2) //Alive.

				if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
					if (src.stunned > 0)
						src.stunned--
						src.stat = 0
					if (src.weakened > 0)
						src.weakened--
						src.lying = 1
						src.stat = 0
					if (src.paralysis > 0)
						src.paralysis--
						src.blinded = 1
						src.lying = 1
						src.stat = 1
					var/h = src.hand
					src.hand = 0
					drop_item()
					src.hand = 1
					drop_item()
					src.hand = h

				else	//Not stunned.
					src.lying = 0
					src.stat = 0

			else //Dead.
				src.lying = 1
				src.blinded = 1
				src.stat = 2

			if (src.stuttering) src.stuttering--

			if (src.eye_blind)
				src.eye_blind--
				src.blinded = 1

			if (src.ear_deaf > 0) src.ear_deaf--
			if (src.ear_damage < 25)
				src.ear_damage -= 0.05
				src.ear_damage = max(src.ear_damage, 0)

			src.density = !( src.lying )

			if ((src.sdisabilities & 1))
				src.blinded = 1
			if ((src.sdisabilities & 4))
				src.ear_deaf = 1

			if (src.eye_blurry > 0)
				src.eye_blurry--
				src.eye_blurry = max(0, src.eye_blurry)

			if (src.druggy > 0)
				src.druggy--
				src.druggy = max(0, src.druggy)

			return 1

		handle_regular_hud_updates()

			if (src.stat == 2 || src.mutations & 4)
				src.sight |= SEE_TURFS
				src.sight |= SEE_MOBS
				src.sight |= SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = 2
			else if (src.stat != 2)
				src.sight |= SEE_MOBS
				src.sight &= ~SEE_TURFS
				src.sight &= ~SEE_OBJS
				src.see_in_dark = 4
				src.see_invisible = 2

			if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
			if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

			if (src.healths)
				if (src.stat != 2)
					switch(health)
						if(100 to INFINITY)
							src.healths.icon_state = "health0"
						if(75 to 100)
							src.healths.icon_state = "health1"
						if(50 to 75)
							src.healths.icon_state = "health2"
						if(25 to 50)
							src.healths.icon_state = "health3"
						if(0 to 25)
							src.healths.icon_state = "health4"
						else
							src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"

			if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


			if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
			if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
			if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.

			src.client.screen -= src.hud_used.blurry
			src.client.screen -= src.hud_used.druggy
			src.client.screen -= src.hud_used.vimpaired

			if ((src.blind && src.stat != 2))
				if ((src.blinded))
					src.blind.layer = 18
				else
					src.blind.layer = 0

					if (src.disabilities & 1)
						src.client.screen += src.hud_used.vimpaired

					if (src.eye_blurry)
						src.client.screen += src.hud_used.blurry

					if (src.druggy)
						src.client.screen += src.hud_used.druggy

			if (src.stat != 2)
				if (src.machine)
					if (!( src.machine.check_eye(src) ))
						src.reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1

		handle_virus_updates()
			if(src.bodytemperature > 406)
				src.resistances += src.virus
				src.virus = null

			if(!src.virus)
				if(prob(40))
					for(var/mob/living/carbon/M in oviewers(4, src))
						if(M.virus && M.virus.spread == "Airborne")
							if(M.virus.affected_species.Find("Alien"))
								if(src.resistances.Find(M.virus.type))
									continue
								var/datum/disease/D = new M.virus.type //Making sure strain_data is preserved
								D.strain_data = M.virus.strain_data
								src.contract_disease(D)

					for(var/obj/decal/cleanable/blood/B in view(4, src))
						if(B.virus && B.virus.spread == "Airborne")
							if(B.virus.affected_species.Find("Alien"))
								if(src.resistances.Find(B.virus.type))
									continue
								var/datum/disease/D = new B.virus.type
								D.strain_data = B.virus.strain_data
								src.contract_disease(D)

					for(var/obj/decal/cleanable/xenoblood/X in view(4, src))
						if(X.virus && X.virus.spread == "Airborne")
							if(X.virus.affected_species.Find("Alien"))
								if(src.resistances.Find(X.virus.type))
									continue
								var/datum/disease/D = new X.virus.type
								D.strain_data = X.virus.strain_data
								src.contract_disease(D)
			else
				src.virus.stage_act()

		check_if_buckled()
			if (src.buckled)
				src.lying = (istype(src.buckled, /obj/stool/bed) ? 1 : 0)
				if(src.lying)
					src.drop_item()
				src.density = 1
			else
				src.density = !src.lying

		handle_stomach()
			spawn(0)
				for(var/mob/M in stomach_contents)
					if(M.loc != src)
						stomach_contents.Remove(M)
						continue
					if(istype(M, /mob/living/carbon) && src.stat != 2)
						if(M.stat == 2)
							M.death(1)
							stomach_contents.Remove(M)
							if(M.client)
								var/mob/dead/observer/newmob = new(M)
								M:client:mob = newmob
								M.mind.transfer_to(newmob)
								newmob.reset_view(null)
							del(M)
							continue
						if(air_master.current_cycle%3==1)
							if(!M.nodamage)
								M.bruteloss += 5
							src.nutrition += 10
