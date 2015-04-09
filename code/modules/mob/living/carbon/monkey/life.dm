//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/monkey


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return

	..()

	if(!client && stat == CONSCIOUS)
		if(prob(33) && canmove && isturf(loc) && !pulledby && !grabbed_by.len)
			step(src, pick(cardinal))
		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey/calculate_affecting_pressure(var/pressure)
	..()
	return pressure

/mob/living/carbon/monkey/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			Weaken(10)
			src << "<span class='danger'>You feel weak.</span>"
			emote("collapse")

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					Weaken(3)
					src << "<span class='danger'>You feel weak.</span>"
					emote("collapse")

			if(75 to 100)
				if(prob(1))
					src << "<span class='danger'>You mutate!</span>"
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")
		..()


/mob/living/carbon/monkey/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if(!on_fire)
		if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
			var/transfer_coefficient = 1

			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat != 2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			throw_alert("pressure","highpressure",2)
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert("pressure","highpressure",1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			throw_alert("pressure","lowpressure",1)
		else
			adjustBruteLoss( LOW_PRESSURE_DAMAGE )
			throw_alert("pressure","lowpressure",2)

	return

/mob/living/carbon/monkey/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return
	var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0*discomfort)
	else
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/monkey/handle_hud_icons()

	handle_hud_icons_health()

	return 1

/mob/living/carbon/monkey/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return


/mob/living/carbon/monkey/handle_changeling()
	if(mind)
		if(mind.changeling)
			mind.changeling.regenerate()
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[mind.changeling.chem_charges]</font></div>"
		else
			hud_used.lingchemdisplay.invisibility = 101

/mob/living/carbon/monkey/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
			return 1

///FIRE CODE
/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return
//END FIRE CODE
