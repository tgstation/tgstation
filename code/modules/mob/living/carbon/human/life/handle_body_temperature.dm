//Refer to life.dm for caller

/*
 * Old, deprecated method to handle body temperature
/mob/living/carbon/human/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//Get difference
	var/increments// = difference/10 //Find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments * boost //Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature + change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature - change)
	temp_change = (temperature - current)
	return temp_change
*/

/mob/living/carbon/human/proc/handle_body_temperature()
	var/body_temperature_difference = 310.15 - bodytemperature
	if(abs(body_temperature_difference) < 0.5)
		return //fuck this precision
	switch(bodytemperature)
		if(-INFINITY to 260.15) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
			if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
				nutrition -= 2
			var/recovery_amt = max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
			//log_debug("Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt
		if(260.15 to 360.15)
			var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
			//log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt
		if(360.15 to INFINITY) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
			//We totally need a sweat system cause it totally makes sense...~
			var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM) //We're dealing with negative numbers
			//log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt
