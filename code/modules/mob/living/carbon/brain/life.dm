/mob/living/carbon/brain

	Life()
		set invisibility = 0
		set background = 1

		var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
		if(loc)
			environment = loc.return_air()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
		blinded = null

	//Disease Check
		handle_virus_updates()

	//Handle temperature/pressure differences between body and environment
		if(environment)	// More error checking -- TLE
			handle_environment(environment)

	//Mutations and radiation
		handle_mutations_and_radiation()

	//Chemicals in the body
		handle_chemicals_in_body()

	//Status updates, death etc.
		handle_regular_status_updates()

		if(client)
			handle_regular_hud_updates()

	// Yup.
		update_canmove()

		clamp_values()

	proc

		clamp_values()

			AdjustParalysis(0)
			AdjustStunned(0)
			AdjustWeakened(0)
			adjustBruteLoss(0)
			adjustFireLoss(0)
			adjustOxyLoss(0)
			adjustToxLoss(0)

		handle_mutations_and_radiation()

			if (radiation)
				if (radiation > 100)
					radiation = 100
					Weaken(10)
					src << "\red You feel weak."

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
//							emote("collapse")
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

		update_canmove()
			if(in_contents_of(/obj/mecha))
				canmove = 1
			else
				canmove = 0
			return

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
			if(nodamage) return

			if(exposed_temperature > bodytemperature)
				var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
				//adjustFireLoss(2.5*discomfort)
				//adjustFireLoss(5.0*discomfort)
				adjustFireLoss(20.0*discomfort)

			else
				var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
				//adjustFireLoss(2.5*discomfort)
				adjustFireLoss(5.0*discomfort)



		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

			if (drowsyness)
				drowsyness--
				eye_blurry = max(2, eye_blurry)
				if (prob(5))
					sleeping = 1
					Paralyse(5)

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 5)
			else
				dizziness = max(0, dizziness - 1)

			updatehealth()

			return //TODO: DEFERRED

		handle_regular_status_updates()

			health = 100 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

			if(getOxyLoss() > 25) Paralyse(3)

			if(sleeping)
				Paralyse(5)
				if (prob(1) && health) spawn(0) emote("snore")

			if(resting)
				Weaken(5)

			if(stat != 2 && (!container && (health < config.health_threshold_dead || (config.revival_brain_life >= 0 && ((world.time - timeofhostdeath) > config.revival_brain_life )))))
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
			if (slurring) slurring--

			if (eye_blind)
				eye_blind--
				blinded = 1

			if (ear_deaf > 0) ear_deaf--
			if (ear_damage < 25)
				ear_damage -= 0.05
				ear_damage = max(ear_damage, 0)

//			density = !( lying )

			if (disabilities & 128)
				blinded = 1
			if (disabilities & 32)
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
				sight &= ~SEE_TURFS
				sight &= ~SEE_MOBS
				sight &= ~SEE_OBJS
				see_in_dark = 2
				see_invisible = 0

			if (src.sleep)
				src.sleep.icon_state = text("sleep[]", src.sleeping > 0 ? 1 : 0)
				src.sleep.overlays = null
				if(src.sleeping_willingly)
					src.sleep.overlays += icon(src.sleep.icon, "sleep_willing")
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

			if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

			if (!src.hud_used)
				src.hud_used = new/obj/hud(src)
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

		handle_virus_updates()
			if(bodytemperature > 409)
				for(var/datum/disease/D in viruses)
					D.cure()
			return