/mob/living/carbon/brain

	Life()
		set invisibility = 0
		set background = 1

		if (src.monkeyizing)
			return

		var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
		if(src.loc)
			environment = loc.return_air()

		if (src.stat != 2) //still breathing

			//First, resolve location and get a breath

			if(air_master.current_cycle%4==2)
				//Only try to take a breath every 4 seconds, unless suffocating
				breathe()

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

	//Changeling things
		handle_changeling()

	//Handle temperature/pressure differences between body and environment
		if(environment)	// More error checking -- TLE
			handle_environment(environment)

	//Mutations and radiation
		handle_mutations_and_radiation()

	//Chemicals in the body
		handle_chemicals_in_body()

	//Disabilities
		handle_disabilities()

	//Status updates, death etc.
		handle_regular_status_updates()

		if(client)
			handle_regular_hud_updates()

	//Being buckled to a chair or bed
		check_if_buckled()

	// Yup.
		update_canmove()

	// Update clothing
		update_clothing()

		clamp_values()

	proc

		clamp_values()

			stunned = max(stunned,0)
			paralysis = max(paralysis, 0)
			weakened = max(weakened, 0)
			bruteloss = min(bruteloss, 0)
			fireloss = min(fireloss, 0)
			oxyloss = min(oxyloss, 0)
			toxloss = min(toxloss, 0)

		handle_disabilities()

		handle_mutations_and_radiation()

			if (src.radiation)
				if (src.radiation > 100)
					src.radiation = 100
					src.weakened = 10
					src << "\red You feel weak."
//					emote("collapse")

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
//							emote("collapse")
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

		get_breath_from_internal(volume_needed)

		update_canmove()
			canmove = 0

		handle_breath(datum/gas_mixture/breath)


		handle_environment(datum/gas_mixture/environment)
			if(!environment)
				return
			var/environment_heat_capacity = environment.heat_capacity()
			if(istype(loc, /turf/space))
				environment_heat_capacity = loc:heat_capacity

			if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
				var/transfer_coefficient

				transfer_coefficient = 1
				if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
					transfer_coefficient *= wear_mask.heat_transfer_coefficient

				handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

			if(stat==2)
				bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

			//Account for massive pressure differences
			return //TODO: DEFERRED

		handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
			if(src.nodamage) return
			var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
			//fireloss += 2.5*discomfort
			fireloss += 5.0*discomfort

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

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
			else
				dizziness = max(0, dizziness - 1)

			src.updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

			health = 100 - (oxyloss + toxloss + fireloss + bruteloss)

			if(oxyloss > 25) paralysis = max(paralysis, 3)

			if(src.sleeping)
				src.paralysis = max(src.paralysis, 5)
				if (prob(1) && health) spawn(0) emote("snore")

			if(src.resting)
				src.weakened = max(src.weakened, 5)

			if(health < -100)
				death()
			else if(src.health < 0)
				if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!src.rejuv) src.oxyloss++
				if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

				if(src.stat != 2)	src.stat = 1
				src.paralysis = max(src.paralysis, 5)

			if (src.stat != 2) //Alive.

				if (src.paralysis || src.stunned || src.weakened || changeling_fakedeath) //Stunned etc.
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

//			src.density = !( src.lying )

			if (src.sdisabilities & 1)
				src.blinded = 1
			if (src.sdisabilities & 4)
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
				src.sight &= ~SEE_TURFS
				src.sight &= ~SEE_MOBS
				src.sight &= ~SEE_OBJS
				src.see_in_dark = 2
				src.see_invisible = 0

			if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
			if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

			if (src.healths)
				if (src.stat != 2)
					switch(health)
						if(100 to INFINITY)
							src.healths.icon_state = "health0"
						if(80 to 100)
							src.healths.icon_state = "health1"
						if(60 to 80)
							src.healths.icon_state = "health2"
						if(40 to 60)
							src.healths.icon_state = "health3"
						if(20 to 40)
							src.healths.icon_state = "health4"
						if(0 to 20)
							src.healths.icon_state = "health5"
						else
							src.healths.icon_state = "health6"
				else
					src.healths.icon_state = "health7"

			if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


//			if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
//			if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
//			if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.
/*
			switch(src.bodytemperature) //310.055 optimal body temp

				if(345 to INFINITY)
					src.bodytemp.icon_state = "temp4"
				if(335 to 345)
					src.bodytemp.icon_state = "temp3"
				if(327 to 335)
					src.bodytemp.icon_state = "temp2"
				if(316 to 327)
					src.bodytemp.icon_state = "temp1"
				if(300 to 316)
					src.bodytemp.icon_state = "temp0"
				if(295 to 300)
					src.bodytemp.icon_state = "temp-1"
				if(280 to 295)
					src.bodytemp.icon_state = "temp-2"
				if(260 to 280)
					src.bodytemp.icon_state = "temp-3"
				else
					src.bodytemp.icon_state = "temp-4"
*/
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

		handle_random_events()

		handle_virus_updates()
			if(src.bodytemperature > 406 && src.virus)
				src.virus.cure()
			return

		check_if_buckled()


		handle_changeling()