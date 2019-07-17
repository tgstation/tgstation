#define COOLING 1
#define HEATING 2
#define NEUTRAL 3

///this the plumbing version of a heater/freezer.
/obj/machinery/plumbing/acclimator
	name = "chemical acclimator"
	desc = "An efficient cooler and heater for the perfect showering temperature or illicit chemical factories."

	icon_state = "acclimator_off"
	buffer = 200
	/**Do we constantly let chems in and out (if it reached target temperature)?
	* Set to FALSE to not let any other chems in while heating. We also do not let any chems in while still emptying
	*/
	var/constant = TRUE
	///The volume at wich we start working. 0 to always process. Note that this is very important if constant = FALSE
	var/start_volume = 0
	///towards wich temperature do we build?
	var/target_temperature = 300
	///cool/heat power
	var/heater_coefficient = 0.1
	///Are we turned on or off? this is from the on and off button
	var/enabled = TRUE
	///COOLING, HEATING or NEUTRAL. We track this for change, so we dont needlessly update our icon
	var/acclimate_state

/obj/machinery/plumbing/acclimator/process()
	if(stat & NOPOWER || reagents.total_volume < start_volume || !enabled || reagents.chem_temp == target_temperature)
		if(acclimate_state != NEUTRAL)
			acclimate_state = NEUTRAL
			update_icon()
		return

	if(reagents.chem_temp < target_temperature && acclimate_state != HEATING) //note that we check if the temperature is the same at the start
		acclimate_state = HEATING
		update_icon()
	else if(reagents.chem_temp > target_temperature && acclimate_state != COOLING)
		acclimate_state = COOLING
		update_icon()

	reagents.adjust_thermal_energy((target_temperature - reagents.chem_temp) * heater_coefficient * SPECIFIC_HEAT_DEFAULT * reagents.total_volume) //keep constant with chem heater
	reagents.handle_reactions()

/obj/machinery/plumbing/acclimator/update_icon()
	icon_state = initial(icon_state)
	switch(acclimate_state)
		if(COOLING)
			icon_state += "_cold"
		if(HEATING)
			icon_state += "_hot"
