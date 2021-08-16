/** Performs heat calculation for the freezer. The full equation for this whole process is:
 * T3 = (C1*T1  +  (C1*C2)/(C1+C2)*(T2-T1)*E) / C1.
 * T4 = (C1*T1  -  (C1*C2)/(C1+C2)*(T2-T1)*E  +  M) / C1.
 * C1 is main port heat capacity, T1 is the temp.
 * C2 and T2 is for the heat capacity of the freezer and temperature that we desire respectively.
 * T3 is the temperature we get, T4 is the exchange target (heat reservoir).
 * M is the motor heat.
 * E is the efficiency variable. At E=1 and M=0 it works out to be ((C1*T1)+(C2*T2))/(C1+C2).
 */
/obj/machinery/atmospherics/components/binary/thermomachine/process_atmos()
	if(!is_operational || !on)  //if it has no power or its switched off, dont process atmos
		on = FALSE
		update_appearance()
		return

	var/turf/local_turf = get_turf(src)
	if(!local_turf)
		on = FALSE
		update_appearance()
		return

	// The gas we want to cool/heat
	var/datum/gas_mixture/main_port = airs[1]

	// The difference between target and what we need to heat/cool. Positive if heating, negative if cooling.
	var/temperature_target_delta = target_temperature - main_port.temperature

	// This variable holds the (C1*C2)/(C1+C2)*(T2-T1) part of the equation.
	var/heat_amount = temperature_target_delta * (main_port.heat_capacity() * heat_capacity / (main_port.heat_capacity() + heat_capacity))

	// Motor heat is the heat added to both ports of the thermomachine at every tick.
	var/motor_heat = 5000
	if(abs(temperature_target_delta) < 5) //Allow the machine to work more finely on lower temperature differences.
		motor_heat = 0

	// Automatic Switching. Longer if check to prevent unecessary update_appearances.
	if ((cooling && temperature_target_delta > 0) || (!cooling && temperature_target_delta < 0))
		cooling = temperature_target_delta <= 0 // Thermomachines that reached the target will default to cooling.
		update_appearance()

	skipping_work = FALSE

	if (main_port.total_moles() < 0.01)
		skipping_work = TRUE
		return

	// Efficiency should be a proc level variable, but we need it for the ui.
	// This is to reset the value when we are heating.
	efficiency = 1

	if(cooling)
		var/datum/gas_mixture/exchange_target
		// Exchange target is the thing we are paired with, be it enviroment or the red port.
		if(use_enviroment_heat)
			exchange_target = local_turf.return_air()
		else
			exchange_target = airs[2]

		if (exchange_target.total_moles() < 0.01)
			skipping_work = TRUE
			return

		// The hotter the heat reservoir is, the larger the malus.
		var/temperature_exchange_delta = exchange_target.temperature - main_port.temperature
		// Log 1 is already 0, going any lower will result in a negative number.
		efficiency = clamp(1 - log(10, max(1, temperature_exchange_delta)) * 0.08, 0.65, 1)
		// We take an extra efficiency malus for enviroments where the mol is too low.
		// Cases of log(0) will be caught by the early return above.
		if (use_enviroment_heat)
			efficiency *= clamp(log(1.55, exchange_target.total_moles()) * 0.15, 0.65, 1)

		if (exchange_target.temperature > THERMOMACHINE_SAFE_TEMPERATURE && safeties)
			on = FALSE
			visible_message(span_warning("The heat reservoir has reached critical levels, shutting down..."))
			update_appearance()
			return

		else if(exchange_target.temperature > THERMOMACHINE_SAFE_TEMPERATURE && !safeties)
			if((REALTIMEOFDAY - lastwarning) / 5 >= WARNING_DELAY)
				lastwarning = REALTIMEOFDAY
				visible_message(span_warning("The heat reservoir has reached critical levels!"))
				if(check_explosion(exchange_target.temperature))
					explode()
					return PROCESS_KILL //We're dying anyway, so let's stop processing

		exchange_target.temperature = max((THERMAL_ENERGY(exchange_target) - (heat_amount * efficiency) + motor_heat) / exchange_target.heat_capacity(), TCMB)

	main_port.temperature = max((THERMAL_ENERGY(main_port) + (heat_amount * efficiency)) / main_port.heat_capacity(), TCMB)

	heat_amount = abs(heat_amount)
	var/power_usage = 0
	if(abs(temperature_target_delta)  > 1)
		power_usage = (heat_amount * 0.35 + idle_power_usage) ** (1.25 - (5e7 * efficiency) / (max(5e7, heat_amount)))
	else
		power_usage = idle_power_usage
	if(power_usage > 1e6)
		power_usage *= efficiency

	use_power(power_usage)
	update_appearance()
	update_parents()
