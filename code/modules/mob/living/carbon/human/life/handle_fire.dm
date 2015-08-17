//Refer to life.dm for caller

/mob/living/carbon/human/handle_fire()
	if(..())
		return
	var/thermal_protection = get_heat_protection(30000) //If you don't have fire suit level protection, you get a temperature increase
	if((1 - thermal_protection) > 0.0001) //MATHEMATICAL HELPERS FOR FUCKS SAKES
		bodytemperature += BODYTEMP_HEATING_MAX
	return
