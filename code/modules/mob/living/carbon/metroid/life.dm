/mob/living/carbon/metroid/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	/*
	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(src.loc)
		environment = loc.return_air() */


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()

	//Handle temperature/pressure differences between body and environment
	/*
	if(environment)	// More error checking -- TLE
		handle_environment(environment) */


	//Chemicals in the body
	handle_chemicals_in_body()

	//Status updates, death etc.
	handle_regular_status_updates()

	/*
	if(client)
		handle_regular_hud_updates() */

	handle_nutrition()


	// Grabbing

	if(!client && !stat)

		// DO AI STUFF HERE
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))



/mob/living/carbon/metroid
	proc

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

				// handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

			if(stat==2)
				bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

			//Account for massive pressure differences
			return //TODO: DEFERRED

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)


			src.updatehealth()

			return //TODO: DEFERRED


		handle_regular_status_updates()

			if(istype(src, /mob/living/carbon/metroid/adult))
				health = 300 - (oxyloss + toxloss + fireloss + bruteloss + cloneloss)
			else
				health = 250 - (oxyloss + toxloss + fireloss + bruteloss + cloneloss)




			if(health < -100)
				death()
				return

			else if(src.health < 0)
				// if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!src.rejuv) src.oxyloss++
				if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss+=8

				if(src.stat != 2)	src.stat = 1

			if(prob(80))
				oxyloss = max(oxyloss-5, 0)
				toxloss = max(toxloss-5, 0)


			if (src.stat == 2)

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


		handle_nutrition()
			if(prob(25)) nutrition--
			if(nutrition <= 0)
				nutrition = 0
				if(prob(75))

					toxloss+=rand(0,5)

			else
				if(istype(src, /mob/living/carbon/metroid/adult))
					if(nutrition >= 350)
						if(prob(40)) amount_grown++

				else
					if(nutrition >= 250)
						if(prob(40)) amount_grown++

		handle_virus_updates()
			if(bodytemperature > 406)
				for(var/datum/disease/D in viruses)
					D.cure()
			return


