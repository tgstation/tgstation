
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
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1)
		adjustFireLoss(20*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1)
		adjustFireLoss(5*discomfort)

/mob/living/carbon/brain/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= config.health_threshold_dead || !container)
			death()
			return
		if(emp_damage>15)
			if(stat == CONSCIOUS)
				stat = UNCONSCIOUS
				set_blindness(1)
		else
			if(stat == UNCONSCIOUS)
				stat = CONSCIOUS
				set_blindness(0)



/* //currently unused feature, since brain outside a mmi is always dead.
/mob/living/carbon/brain/proc/handle_brain_revival_life()
	if(stat != DEAD)
		if(config.revival_brain_life != -1)
			if( !container && (world.time - timeofhostdeath) > config.revival_brain_life)
				death()
*/

/mob/living/carbon/brain/handle_status_effects()
	if(!container)
		emp_damage = 0
		return
	if(emp_damage)
		update_stat()
		emp_damage = max(emp_damage-1, 0)

/mob/living/carbon/brain/handle_disabilities()
	return

/mob/living/carbon/brain/setEarDamage()
	return

/mob/living/carbon/brain/handle_changeling()
	return


