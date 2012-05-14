obj/machinery/atmospherics/unary/oxygen_generator
	icon = 'oxygen_generator.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Oxygen Generator"
	desc = ""

	dir = SOUTH
	initialize_directions = SOUTH

	var/on = 0

	var/oxygen_content = 10

	update_icon()
		if(node)
			icon_state = "intact_[on?("on"):("off")]"
		else
			icon_state = "exposed_off"

			on = 0

		return

	New()
		..()

		air_contents.volume = 50

	process()
		..()
		if(!on)
			return 0

		var/total_moles = air_contents.total_moles

		if(total_moles < oxygen_content)
			var/current_heat_capacity = air_contents.heat_capacity()

			var/added_oxygen = oxygen_content - total_moles

			air_contents.temperature = (current_heat_capacity*air_contents.temperature + 20*added_oxygen*T0C)/(current_heat_capacity+20*added_oxygen)
			air_contents.oxygen += added_oxygen
			air_contents.update_values()

			if(network)
				network.update = 1

		return 1