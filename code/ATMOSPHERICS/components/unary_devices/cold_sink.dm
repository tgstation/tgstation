/obj/machinery/atmospherics/components/unary/cold_sink

	icon_state = "cold_map"
	use_power = 1

	name = "cold sink"
	desc = "Cools gas when connected to pipe network"

	var/on = 0

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/components/unary/cold_sink/update_icon_nopipes()
	overlays.Cut()
	if(showpipe)
		overlays += getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "scrub_cap", initialize_directions) //scrub_cap works for now

	if(!NODE1 || !on || stat & (NOPOWER|BROKEN))
		icon_state = "cold_off"
		return

	else
		icon_state = "cold_on"

//Nearly Identical Proc: /obj/machinery/atmospherics/components/unary/heat_reservoir/process_atmos()
/obj/machinery/atmospherics/components/unary/cold_sink/process_atmos()
	..()
	if(!on)
		return 0
	var/datum/gas_mixture/air_contents = AIR1

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		//current_tempature is target tempature
		var/combined_energy = current_heat_capacity*current_temperature + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity


	var/temperatureChange=abs(old_temperature-air_contents.temperature)
	if(temperatureChange > 1)
		//The new formula is based on change from current temp, instead of change from T20C
		// The 10 const is not scaled yet.
		active_power_usage = (current_heat_capacity * temperatureChange ) / 10 + idle_power_usage
		//Note: Powerusage won't be subtracted off till next tick but one tick of not being accurate before machine turns off is fine
		update_parents()
	else
		//No change in temp, use idle power
		active_power_usage= idle_power_usage

	return 1
