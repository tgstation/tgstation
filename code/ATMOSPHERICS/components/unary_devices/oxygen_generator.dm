/obj/machinery/atmospherics/unary/oxygen_generator

	icon_state = "o2gen_map"

	name = "oxygen generator"
	desc = "Generates oxygen"

	dir = SOUTH
	initialize_directions = SOUTH

	var/on = 0

	var/oxygen_content = 10

/obj/machinery/atmospherics/unary/oxygen_generator/update_icon_nopipes()

	overlays.Cut()
	if(showpipe)
		overlays += getpipeimage('icons/obj/atmospherics/unary_devices.dmi', "scrub_cap", initialize_directions) //it works for now

	if(!nodes[1] || !on || stat & BROKEN)
		icon_state = "o2gen_off"
		return

	else
		icon_state = "o2gen_on"

/obj/machinery/atmospherics/unary/oxygen_generator/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1] ; air_contents.volume = 50
	airs[1] = air_contents

/obj/machinery/atmospherics/unary/oxygen_generator/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/air_contents = airs[1]

	var/total_moles = air_contents.total_moles()

	if(total_moles < oxygen_content)
		var/current_heat_capacity = air_contents.heat_capacity()

		var/added_oxygen = oxygen_content - total_moles

		air_contents.temperature = (current_heat_capacity*air_contents.temperature + 20*added_oxygen*T0C)/(current_heat_capacity+20*added_oxygen)
		air_contents.oxygen += added_oxygen

		update_airs(air_contents)
		update_parents()

	return 1
