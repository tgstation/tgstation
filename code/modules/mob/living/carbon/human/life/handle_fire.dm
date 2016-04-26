//Refer to life.dm for caller

/mob/living/carbon/human/handle_fire()
	if(..())
		return
	var/thermal_protection = get_heat_protection(get_heat_protection_flags(30000)) //If you don't have fire suit level protection, you get a temperature increase
	if((1 - thermal_protection) > 0.0001 && bodytemperature < T0C+100) //MATHEMATICAL HELPERS FOR FUCKS SAKES
		bodytemperature = min(bodytemperature + BODYTEMP_HEATING_MAX,T0C+100)
	return
