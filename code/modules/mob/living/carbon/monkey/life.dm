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

/mob/living/carbon/monkey/handle_breath_temperature(datum/gas_mixture/breath)
	if(abs(310.15 - breath.temperature) > 50)
		switch(breath.temperature)
			if(-INFINITY to 120)
				adjustFireLoss(3)
			if(120 to 200)
				adjustFireLoss(1.5)
			if(200 to 260)
				adjustFireLoss(0.5)
			if(360 to 400)
				adjustFireLoss(2)
			if(400 to 1000)
				adjustFireLoss(3)
			if(1000 to INFINITY)
				adjustFireLoss(8)

/mob/living/carbon/monkey/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	if(stat != DEAD)
		natural_bodytemperature_stabilization()

	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < bodytemperature)
			bodytemperature += min(((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			bodytemperature += min(((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		switch(bodytemperature)
			if(360 to 400)
				throw_alert("temp","hot",1)
				adjustFireLoss(2)
			if(400 to 460)
				throw_alert("temp","hot",2)
				adjustFireLoss(3)
			if(460 to INFINITY)
				throw_alert("temp","hot",3)
				if(on_fire)
					adjustFireLoss(8)
				else
					adjustFireLoss(3)

	else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		if(!istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
			switch(bodytemperature)
				if(200 to 260)
					throw_alert("temp","cold",1)
					adjustFireLoss(0.5)
				if(120 to 200)
					throw_alert("temp","cold",2)
					adjustFireLoss(1.5)
				if(-INFINITY to 120)
					throw_alert("temp","cold",3)
					adjustFireLoss(3)
		else
			clear_alert("temp")

	else
		clear_alert("temp")

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


/mob/living/carbon/monkey/handle_hud_icons()

	handle_hud_icons_health()

	return 1

/mob/living/carbon/monkey/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return


/mob/living/carbon/monkey/handle_changeling()
	if(mind && hud_used)
		if(mind.changeling)
			mind.changeling.regenerate(src)
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(mind.changeling.chem_charges)]</font></div>"
		else
			hud_used.lingchemdisplay.invisibility = 101

/mob/living/carbon/monkey/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
			return 1

/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	bodytemperature += BODYTEMP_HEATING_MAX
	return
