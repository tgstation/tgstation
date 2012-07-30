/mob/living/carbon/brain/Life()
	set invisibility = 0
	set background = 1
	..()

	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disease Check
		//handle_virus_updates() There is no disease that affects brains

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()


/mob/living/carbon/brain/
	proc/handle_mutations_and_radiation()

		if (radiation)
			if (radiation > 100)
				radiation = 100
				if(!container)//If it's not in an MMI
					src << "\red You feel weak."
				else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
					src << "\red STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED."

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
						if(!container)
							src << "\red You feel weak."
						else
							src << "\red STATUS: DANGEROUS LEVELS OF RADIATION DETECTED."
					updatehealth()

				if(75 to 100)
					radiation -= 3
					adjustToxLoss(3)
					updatehealth()


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

		return //TODO: DEFERRED

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
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



	proc/handle_chemicals_in_body()

		if(reagents) reagents.metabolize(src)

		confused = max(0, confused - 1)
		// decrement dizziness counter, clamped to 0
		if(resting)
			dizziness = max(0, dizziness - 5)
		else
			dizziness = max(0, dizziness - 1)

		updatehealth()

		return //TODO: DEFERRED


	proc/handle_regular_status_updates()	//TODO: comment out the unused bits >_>
		updatehealth()

		if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
			blinded = 1
			silent = 0
		else				//ALIVE. LIGHTS ARE ON
			if( !container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)) )
				death()
				blinded = 1
				silent = 0
				return 1

			//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
			if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
				if(!(container && istype(container, /obj/item/device/mmi)))
					emp_damage = 0
				else
					emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
				switch(emp_damage)
					if(31 to INFINITY)
						emp_damage = 30//Let's not overdo it
					if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
						eye_blind = 1
						blinded = 1
						ear_deaf = 1
						silent = 1
						if(!alert)//Sounds an alarm, but only once per 'level'
							emote("alarm")
							src << "\red Major electrical distruption detected: System rebooting."
							alert = 1
						if(prob(75))
							emp_damage -= 1
					if(20)
						alert = 0
						blinded = 0
						eye_blind = 0
						ear_deaf = 0
						silent = 0
						emp_damage -= 1
					if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
						eye_blurry = 1
						ear_damage = 1
						if(!alert)
							emote("alert")
							src << "\red Primary systems are now online."
							alert = 1
						if(prob(50))
							emp_damage -= 1
					if(10)
						alert = 0
						eye_blurry = 0
						ear_damage = 0
						emp_damage -= 1
					if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
						if(!alert)
							emote("notice")
							src << "\red System reboot nearly complete."
							alert = 1
						if(prob(25))
							emp_damage -= 1
					if(1)
						alert = 0
						src << "\red All systems restored."
						emp_damage -= 1

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

		if (stat == 2 || (XRAY in src.mutations))
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

		if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

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

	proc/handle_virus_updates()
		if(bodytemperature > 409)
			for(var/datum/disease/D in viruses)
				D.cure()
		return

/*/mob/living/carbon/brain/emp_act(severity)
	if(!(container && istype(container, /obj/item/device/mmi)))
		return
	else
		switch(severity)
			if(1)
				emp_damage += rand(20,30)
			if(2)
				emp_damage += rand(10,20)
			if(3)
				emp_damage += rand(0,10)
	..()*/