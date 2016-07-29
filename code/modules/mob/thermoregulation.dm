/mob/living/proc/handle_body_temperature()
	var/body_temperature_difference = abs(310.15 - bodytemperature)
	if(body_temperature_difference < 0.5)
		return //fuck this precision
	if(undergoing_hypothermia())
		handle_hypothermia()
	if(bodytemperature > 310.15)
		var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR),BODYTEMP_AUTORECOVERY_MAXIMUM)
		sweat(recovery_amt,1)

/mob/living/proc/burn_calories(var/amount,var/forceburn = 0)
	var/cached_max_temp = max(bodytemperature,T0C+50)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return 1
	if(forceburn && ticker && ticker.hardcore_mode)
		forceburn = 0
	if(nutrition - amount > 0 || forceburn)
		var/heatmodifier = 0.7
		nutrition = max(nutrition - amount,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature = min(bodytemperature + (amount * heatmodifier), cached_max_temp)	// until we have a proper hyperthermia system
		return 1
	else
		return 0

/mob/living/silicon/burn_calories(var/amount,var/forceburn = 0)
	return 1	// ideally this'd call their cell charge thing but whatever

/mob/living/simple_animal/burn_calories(var/amount,var/forceburn = 0)
	return 1

/mob/living/carbon/alien/burn_calories(var/amount,var/forceburn = 0)
	return 1	// figure this out later

/mob/living/proc/sweat(var/amount,var/forcesweat = 0)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return 1
	/* buggy as fug
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(!H.species.has_sweat_glands)
			return 1

	*/
	if(forcesweat && ticker && ticker.hardcore_mode)
		forcesweat = 0
	var/sustenance = amount / 50
	if(nutrition - sustenance > 0 || forcesweat)
		var/heatmodifier = 1
		nutrition = max(nutrition - sustenance,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature -= amount * heatmodifier
		return 1
	else
		return 0

/mob/living/proc/get_thermal_loss(var/datum/gas_mixture/environment)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return 0
	if(!environment)
		environment = loc.return_air()
	var/loc_temp = get_loc_temp(environment)
	if(loc_temp < bodytemperature)
		// We're going to try and just use exposed area(temperature difference)/cold divisor, and assume we're only conducting.
		var/thermal_loss = (1-get_cold_protection())  				// How much of your skin is exposed.
		if(!isVentCrawling() && (environment.total_moles > MOLES_CELLSTANDARD || !IS_SPACE_COLD))
			var/pressure_diff   = environment.total_moles/MOLES_CELLSTANDARD // How many moles are in the environment over 103.934, the normal value of a station.
			var/pressure_factor = (-COLD_PRESSUREFACTOR_MAX)/(pressure_diff) + COLD_PRESSUREFACTOR_MAX // non linear.
			if(pressure_diff < PRESSUREFACTOR_NO_LINEAR)
				pressure_factor = pressure_diff
			thermal_loss *= pressure_factor
		thermal_loss	*= (get_skin_temperature() - loc_temp)		// Multiplied by the difference between you and the room temperature
		thermal_loss	/= BODYTEMP_COLD_DIVISOR					// Divided by the cold_divisor
		return thermal_loss
	return 0

/mob/living/proc/get_thermal_protection_flags()
	return 0

/mob/living/proc/get_thermal_protection(var/thermal_protection_flags)
	var/thermal_protection = 0.0

	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += COVER_PROTECTION_HEAD
		if(thermal_protection_flags & EYES)
			thermal_protection += COVER_PROTECTION_EYES
		if(thermal_protection_flags & MOUTH)
			thermal_protection += COVER_PROTECTION_MOUTH
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += COVER_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += COVER_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += COVER_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += COVER_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += COVER_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += COVER_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += COVER_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += COVER_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += COVER_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += COVER_PROTECTION_HAND_RIGHT
		if(thermal_protection_flags & EARS)
			thermal_protection += COVER_PROTECTION_EARS

	return min(1, thermal_protection)

/mob/living/proc/get_heat_protection(var/thermal_protection_flags)
	return 0

/mob/living/proc/get_heat_protection_flags(temperature)
	return 0

/mob/living/proc/get_cold_protection(var/thermal_protection_flags)
	return 0

/mob/living/proc/get_loc_temp(var/datum/gas_mixture/environment)
	if(!environment)
		environment = loc.return_air()
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()
	//else if(istype(get_turf(src), /turf/space))
	if(istype(loc, /obj/spacepod))
		var/obj/spacepod/S = loc
		loc_temp = S.return_temperature()
	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/CC = loc
		loc_temp = CC.air_contents.temperature
	else
		loc_temp = environment.temperature
	return loc_temp

