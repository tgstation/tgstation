//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_environment(datum/gas_mixture/environment)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/carbon/human/proc/handle_environment() called tick#: [world.time]")
	if(!environment || (flags & INVULNERABLE))
		return
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()
	//else if(istype(get_turf(src), /turf/space))
	if(istype(loc, /obj/spacepod))
		var/obj/spacepod/S = loc
		loc_temp = S.return_temperature()
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		loc_temp = loc:air_contents.temperature
	else
		loc_temp = environment.temperature

	//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]"

	//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
	if(stat != DEAD)
		handle_body_temperature()
		//log_debug("Adjusting to atmosphere.")

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < bodytemperature)
			//Place is colder than we are
			var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			//Place is hotter than we are
			var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	//+/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		fire_alert = max(fire_alert, 2)
		if(status_flags & GODMODE)
			return 1 //Godmode
		if(dna.mutantrace != "slime") //Slimes are unaffected by heat
			switch(bodytemperature)
				if(360 to 400)
					apply_damage(HEAT_DAMAGE_LEVEL_1, BURN, used_weapon = "High Body Temperature")
					fire_alert = max(fire_alert, 2)
				if(400 to 1000)
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN, used_weapon = "High Body Temperature")
					fire_alert = max(fire_alert, 2)
				if(1000 to INFINITY)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN, used_weapon = "High Body Temperature")
					fire_alert = max(fire_alert, 2)
		else
			fire_alert = 0

	else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)
			return 1 //Godmode
		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			if(dna.mutantrace == "slime")
				adjustToxLoss(round(BODYTEMP_HEAT_DAMAGE_LIMIT - bodytemperature))
				fire_alert = max(fire_alert, 1)
			else
				switch(bodytemperature)
					if(200 to 260)
						apply_damage(COLD_DAMAGE_LEVEL_1, BURN, used_weapon = "Low Body Temperature")
						fire_alert = max(fire_alert, 1)
					if(120 to 200)
						apply_damage(COLD_DAMAGE_LEVEL_2, BURN, used_weapon = "Low Body Temperature")
						fire_alert = max(fire_alert, 1)
					if(-INFINITY to 120) //Minus infinity, you realize we're working with Kelvins right ?
						apply_damage(COLD_DAMAGE_LEVEL_3, BURN, used_weapon = "Low Body Temperature")
						fire_alert = max(fire_alert, 1)

	//Account for massive pressure differences.  Done by Polymorph
	//Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	if(status_flags & GODMODE)
		return 1 //Godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		adjustBruteLoss(min(((adjusted_pressure/species.hazard_high_pressure) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE))
		pressure_alert = 2
	else if(adjusted_pressure >= species.warning_high_pressure)
		pressure_alert = 1
	else if(adjusted_pressure >= species.warning_low_pressure)
		pressure_alert = 0
	else if(adjusted_pressure >= species.hazard_low_pressure)
		pressure_alert = -1
	else
		if(!(M_RESIST_COLD in mutations))
			adjustBruteLoss(LOW_PRESSURE_DAMAGE)
			if(istype(src.loc, /turf/space))
				adjustBruteLoss(LOW_PRESSURE_DAMAGE) //Space doubles damage (for some reason space vacuum is not station vacuum, nice snowflake)
			pressure_alert = -2
		else
			pressure_alert = -1

	if(environment.toxins > MOLES_PLASMA_VISIBLE)
		pl_effects()
	return
