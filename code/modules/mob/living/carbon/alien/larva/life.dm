/mob/living/carbon/alien/larva
	var
		oxygen_alert = 0
		toxins_alert = 0
		fire_alert = 0

		temperature_alert = 0


/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	set background = 1

	if (monkeyizing)
		return

	..()

	if (stat != 2) //still breathing

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
	blinded = null

	//Mind update
	update_mind()

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


/mob/living/carbon/alien/larva
	proc
		clamp_values()

			SetStunned(min(stunned, 20))
			SetParalysis(min(paralysis, 20))
			SetWeakened(min(weakened, 20))
			sleeping = max(min(sleeping, 20), 0)

		handle_mutations_and_radiation()

			if(amount_grown == 200)
				src << "\green You are growing into a beautiful alien! It is time to choose a caste."
				src << "\green There are three to choose from:"
				src << "\green <B>Hunters</B> are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves."
				src << "\green <B>Sentinels</B> are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters."
				src << "\green <B>Drones</B> are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen."
				var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")

				var/mob/living/carbon/alien/humanoid/new_xeno
				switch(alien_caste)
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter (loc)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel (loc)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone (loc)

				new_xeno.mind_initialize(src, alien_caste)
				new_xeno.key = key

				del(src)
				return
			//grow!! but not if metroid or dead
			if(health>-100)
				amount_grown++

			if (radiation)
				if (radiation > 100)
					radiation = 100
					Weaken(10)
					src << "\red You feel weak."
					emote("collapse")

				if (radiation < 0)
					radiation = 0

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
						updatehealth()

		update_mind()
			if(!mind && client)
				mind = new
				mind.current = src
				mind.assigned_role = "Larva"
				mind.key = key

		breathe()

			if(reagents.has_reagent("lexorin")) return
			if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

			var/datum/gas_mixture/environment = loc.return_air()
			var/datum/air_group/breath
			// HACK NEED CHANGING LATER
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
						var/breath_moles = 0
						/*if(environment.return_pressure() > ONE_ATMOSPHERE)
							// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
							breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
						else*/
							// Not enough air around, take a percentage of what's there to model this properly
						breath_moles = environment.total_moles()*BREATH_PERCENTAGE

						breath = loc.remove_air(breath_moles)

						// Handle chem smoke effect  -- Doohl
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


		get_breath_from_internal(volume_needed)
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
			return null

		update_canmove()
			if(paralysis || stunned || weakened || buckled) canmove = 0
			else canmove = 1

		handle_breath(datum/gas_mixture/breath)
			if(nodamage)
				return

			if(!breath || (breath.total_moles() == 0))
				//Aliens breathe in vaccuum
				return 0

			var/toxins_used = 0
			var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

			//Partial pressure of the toxins in our breath
			var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure

			if(Toxins_pp) // Detect toxins in air

				adjustToxLoss(breath.toxins*250)
				toxins_alert = max(toxins_alert, 1)

				toxins_used = breath.toxins

			else
				toxins_alert = 0

			//Breathe in toxins and out oxygen
			breath.toxins -= toxins_used
			breath.oxygen += toxins_used

			if(breath.temperature > (T0C+66) && !(mutations & COLD_RESISTANCE)) // Hot air hurts :(
				if(prob(20))
					src << "\red You feel a searing heat in your lungs!"
				fire_alert = max(fire_alert, 1)
			else
				fire_alert = 0

			//Temporary fixes to the alerts.

			return 1

		handle_environment()

			//If there are alien weeds on the ground then heal if needed or give some toxins
			if(locate(/obj/effect/alien/weeds) in loc)
				if(health >= 25)
					adjustToxLoss(5)
				else
					adjustBruteLoss(-5)
					adjustFireLoss(-5)

			return


		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

			if(nutrition > 500 && !(mutations & FAT))
				if(prob(5 + round((nutrition - 200) / 2)))
					src << "\red You suddenly feel blubbery!"
					mutations |= FAT
//					update_body()
			if (nutrition < 100 && mutations & FAT)
				if(prob(round((50 - nutrition) / 100)))
					src << "\blue You feel fit again!"
					mutations &= ~FAT
//					update_body()
			if (nutrition > 0)
				nutrition-= HUNGER_FACTOR

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
				jitteriness = max(0, jitteriness - 5)
			else
				dizziness = max(0, dizziness - 1)
				jitteriness = max(0, jitteriness - 1)

			updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

			health = 25 - (getOxyLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

			if(getOxyLoss() > 50) Paralyse(3)

			if(sleeping)
				Paralyse(3)
				if (prob(10) && health) spawn(0) emote("snore")
				sleeping--

			if(resting)
				Weaken(5)

			if(move_delay_add > 0)
				move_delay_add = max(0, move_delay_add - rand(1, 2))

			if(health < config.health_threshold_dead || brain_op_stage == 4.0)
				death()
			else if(health < config.health_threshold_crit)
				if(health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!rejuv) oxyloss++
				if(!reagents.has_reagent("inaprovaline")) adjustOxyLoss(1)

				if(stat != 2)	stat = 1
				Paralyse(5)

			if (stat != 2) //Alive.

				if (paralysis || stunned || weakened) //Stunned etc.
					if (stunned > 0)
						AdjustStunned(-1)
						stat = 0
					if (weakened > 0)
						AdjustWeakened(-1)
						lying = 1
						stat = 0
					if (paralysis > 0)
						AdjustParalysis(-1)
						blinded = 1
						lying = 1
						stat = 1
					var/h = hand
					hand = 0
					drop_item()
					hand = 1
					drop_item()
					hand = h

				else	//Not stunned.
					lying = 0
					stat = 0

			else //Dead.
				lying = 1
				blinded = 1
				stat = 2

			if (stuttering) stuttering--

			if (eye_blind)
				eye_blind--
				blinded = 1

			if (ear_deaf > 0) ear_deaf--
			if (ear_damage < 25)
				ear_damage -= 0.05
				ear_damage = max(ear_damage, 0)

			density = !( lying )

			if ((sdisabilities & 1))
				blinded = 1
			if ((sdisabilities & 4))
				ear_deaf = 1

			if (eye_blurry > 0)
				eye_blurry--
				eye_blurry = max(0, eye_blurry)

			if (druggy > 0)
				druggy--
				druggy = max(0, druggy)

			return 1

		handle_regular_hud_updates()

			if (stat == 2 || mutations & XRAY)
				sight |= SEE_TURFS
				sight |= SEE_MOBS
				sight |= SEE_OBJS
				see_in_dark = 8
				see_invisible = 2
			else if (stat != 2)
				sight |= SEE_MOBS
				sight &= ~SEE_TURFS
				sight &= ~SEE_OBJS
				see_in_dark = 4
				see_invisible = 2

			if (sleep) sleep.icon_state = text("sleep[]", sleeping)
			if (rest) rest.icon_state = text("rest[]", resting)

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

			if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


			if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
			if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
			if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.


			client.screen -= hud_used.blurry
			client.screen -= hud_used.druggy
			client.screen -= hud_used.vimpaired

			if ((blind && stat != 2))
				if ((blinded))
					blind.layer = 18
				else
					blind.layer = 0

					if (disabilities & 1)
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

		handle_random_events()
			return

		handle_virus_updates()
			if(bodytemperature > 406)
				for(var/datum/disease/D in viruses)
					D.cure()
			return

		handle_stomach()
			spawn(0)
				for(var/mob/M in stomach_contents)
					if(M.loc != src)
						stomach_contents.Remove(M)
						continue
					if(istype(M, /mob/living/carbon) && stat != 2)
						if(M.stat == 2)
							M.death(1)
							stomach_contents.Remove(M)
							del(M)
							continue
						if(air_master.current_cycle%3==1)
							if(!M.nodamage)
								M.adjustBruteLoss(5)
							nutrition += 10
