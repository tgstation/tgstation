#define RADIATION_CAPACITY 30000 //Radiation isn't particularly effective (TODO BALANCE)


/obj/machinery/atmospherics/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration

	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "off"
	level = 1

	name = "Thermal Transfer Plate"
	desc = "Transfers heat to and from an area."

/obj/machinery/atmospherics/unary/thermal_plate/process()
	. = ..()

	var/datum/gas_mixture/environment = loc.return_air()

	//Get processable air sample and thermal info from environment

	var/environment_moles = environment.total_moles()
	var/transfer_moles = 0.25 * environment_moles
	var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

	if(!external_removed)
		return radiate()

	if(environment_moles < NO_GAS)
		return radiate()
	else if(environment_moles < SOME_GAS)
		return 0

	//Get same info from connected gas

	var/internal_transfer_moles = 0.25 * air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

	if (!internal_removed)
		environment.merge(external_removed)
		return

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

/obj/machinery/atmospherics/unary/thermal_plate/hide(var/i) //to make the little pipe section invisible, the icon changes.
	var/prefix=""
	//var/suffix="_idle" // Also available: _heat, _cool
	if(i == 1 && istype(loc, /turf/simulated))
		prefix="h"
	icon_state = "[prefix]off"
	return

/obj/machinery/atmospherics/unary/thermal_plate/proc/radiate()
	if(network && network.radiate) //Since each member of a network has the same gases each tick
		air_contents.copy_from(network.radiate) //We can cut down on processing time by only calculating radiate() once and then applying the result
		return

	var/internal_transfer_moles = 0.25 * air_contents.total_moles()
	var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

	if (!internal_removed)
		return

	var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
	var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

	var/final_temperature = combined_energy / combined_heat_capacity

	internal_removed.temperature = final_temperature
	air_contents.merge(internal_removed)

	if (network)
		network.update = 1
		network.radiate = air_contents

	return 1
