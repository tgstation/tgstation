
/mob/living/carbon/brain/handle_breathing()
	return

/mob/living/carbon/brain/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			if(!container)//If it's not in an MMI
				src << "<span class='danger'>You feel weak.</span>"
			else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
				src << "<span class='danger'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</span>"

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					if(!container)
						src << "<span class='danger'>You feel weak.</span>"
					else
						src << "<span class='danger'>STATUS: DANGEROUS LEVELS OF RADIATION DETECTED.</span>"
		..()

/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences

	return //TODO: DEFERRED

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(5.0*discomfort)


/mob/living/carbon/brain/handle_regular_status_updates()	//TODO: comment out the unused bits >_>

	if(stat == DEAD)
		eye_blind = max(eye_blind, 1)
		silent = 0
	else
		updatehealth()
		if( !container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)) )
			death()
			eye_blind = max(eye_blind, 1)
			silent = 0
			return
		else
			stat = CONSCIOUS

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
						eye_blind = max(eye_blind, 1)
						setEarDamage(-1,1)
						silent = 1
						if(!alert)//Sounds an alarm, but only once per 'level'
							emote("alarm")
							src << "<span class='danger'>Major electrical distruption detected: System rebooting.</span>"
							alert = 1
						if(prob(75))
							emp_damage -= 1
					if(20)
						alert = 0
						eye_blind = 0
						setEarDamage(-1,0)
						silent = 0
						emp_damage -= 1
					if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
						eye_blurry = 1
						setEarDamage(1,-1)
						if(!alert)
							emote("alert")
							src << "<span class='danger'>Primary systems are now online.</span>"
							alert = 1
						if(prob(50))
							emp_damage -= 1
					if(10)
						alert = 0
						eye_blurry = 0
						setEarDamage(0,-1)
						emp_damage -= 1
					if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
						if(!alert)
							emote("notice")
							src << "<span class='danger'>System reboot nearly complete.</span>"
							alert = 1
						if(prob(25))
							emp_damage -= 1
					if(1)
						alert = 0
						src << "<span class='danger'>All systems restored.</span>"
						emp_damage -= 1
			else
				eye_blind = 0

		return 1

/mob/living/carbon/brain/handle_disabilities()
	//Eyes
	if(disabilities & BLIND || stat)
		eye_blind = max(eye_blind, 1)
	else
		if(eye_blind)
			eye_blind = 0
		if(eye_blurry)
			eye_blurry = 0
		if(eye_stat)
			eye_stat = 0

	//Ears
	if(disabilities & DEAF)
		setEarDamage(-1, max(ear_deaf, 1))
	else if(ear_damage < 100)
		setEarDamage(0, 0)

/mob/living/carbon/brain/handle_status_effects()
	return

/mob/living/carbon/brain/handle_regular_hud_updates()
	handle_vision()
	handle_hud_icons_health()
	return 1
