#define RADIATION_CAPACITY 30000 //Radiation isn't particularly effective (TODO BALANCE)


/obj/machinery/atmospherics/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration

	icon = 'cold_sink.dmi'
	icon_state = "intact_off"

	name = "Thermal Transfer Plate"
	desc = "Transfers heat to and from an area"

	update_icon()
		if(node)
			icon_state = "intact_off"
		else
			icon_state = "exposed"
		return

	process()
		..()

		var/datum/gas_mixture/environment = loc.return_air()

		//Get processable air sample and thermal info from environment

		var/transfer_moles = 0.25 * environment.total_moles
		var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

		if (!external_removed)
			return radiate()

		if (external_removed.total_moles < 10)
			return radiate()

		//Get same info from connected gas

		var/internal_transfer_moles = 0.25 * air_contents.total_moles
		var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

		if (!internal_removed)
			environment.merge(external_removed)
			return 1

		var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
		var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature

		if(!combined_heat_capacity) combined_heat_capacity = 1
		var/final_temperature = combined_energy / combined_heat_capacity

		external_removed.temperature = final_temperature
		environment.merge(external_removed)

		internal_removed.temperature = final_temperature
		air_contents.merge(internal_removed)

		network.update = 1

		return 1

	proc/radiate()

		var/internal_transfer_moles = 0.25 * air_contents.total_moles
		var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

		if (!internal_removed)
			return 1

		var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
		var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

		var/final_temperature = combined_energy / combined_heat_capacity

		internal_removed.temperature = final_temperature
		air_contents.merge(internal_removed)

		if (network)
			network.update = 1

		return 1