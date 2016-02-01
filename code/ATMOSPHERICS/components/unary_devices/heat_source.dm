/obj/machinery/atmospherics/components/unary/heat_reservoir
//currently the same code as cold_sink but anticipating process() changes

	icon_state = "cold_map"
	use_power = 1

	name = "heat reservoir"
	desc = "Heats gas when connected to pipe network"

	var/on = 0

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

/obj/machinery/atmospherics/components/unary/heat_reservoir/update_icon_nopipes()
	overlays.Cut()
	if(showpipe)
		overlays += getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "scrub_cap", initialize_directions) //scrub_cap works for now

	if(!NODE1 || !on || stat & (NOPOWER|BROKEN))
		icon_state = "cold_off"
		return

	else
		icon_state = "cold_on"

//Nearly Identical Proc: /obj/machinery/atmospherics/components/unary/cold_sink/process_atmos()
/obj/machinery/atmospherics/components/unary/heat_reservoir/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/air_contents = AIR1

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity



	var/temperatureChange=abs(old_temperature-air_contents.temperature)

	if(temperatureChange > 1)
		active_power_usage = (current_heat_capacity * temperatureChange ) / 10 + idle_power_usage
		update_parents()
	else
		//No change in temp, use idle power
		active_power_usage= idle_power_usage

	return 1
