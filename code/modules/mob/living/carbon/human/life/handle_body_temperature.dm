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
	var/body_temperature_difference = abs(310.15 - bodytemperature)
	if(body_temperature_difference < 0.5)
		return //fuck this precision
	if(undergoing_hypothermia())
		handle_hypothermia()
	if(bodytemperature > 310.15)
		//We totally need a sweat system cause it totally makes sense...~ - Now we do, sort of!
		var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR),BODYTEMP_AUTORECOVERY_MAXIMUM)
		//log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		sweat(recovery_amt,1)