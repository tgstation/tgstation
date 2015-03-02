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
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			pressure_alert = -1
		else
			adjustBruteLoss( LOW_PRESSURE_DAMAGE )
			pressure_alert = -2

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

	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"

	if(pullin)
		if(pulling)
			pullin.icon_state = "pull"
		else
			pullin.icon_state = "pull0"

	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 2 : 0]"

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
