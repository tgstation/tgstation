/obj/machinery/atmospherics/unary/heat_reservoir
//currently the same code as cold_sink but anticipating process() changes

	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Heat Reservoir"
	desc = "Heats gas when connected to pipe network"

	var/on = 0

	var/current_temperature = T20C
	var/current_heat_capacity = 50000 //totally random

	update_icon()
		if(node)
			icon_state = "intact_[on?("on"):("off")]"
		else
			icon_state = "exposed"

			on = 0

		return

	process()
		..()
		if(!on)
			return 0
		var/air_heat_capacity = air_contents.heat_capacity()
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		var/old_temperature = air_contents.temperature

		if(combined_heat_capacity > 0)
			var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
			air_contents.temperature = combined_energy/combined_heat_capacity

		//todo: have current temperature affected. require power to bring up current temperature again

		if(abs(old_temperature-air_contents.temperature) > 1)
			network.update = 1
		return 1