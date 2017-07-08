/obj/machinery/atmospherics/components/unary/oxygen_generator

	icon_state = "o2gen_map"

	name = "oxygen generator"
	desc = "Generates oxygen"

	dir = SOUTH
	initialize_directions = SOUTH
	layer = GAS_SCRUBBER_LAYER

	var/on = 0

	var/oxygen_content = 10

/obj/machinery/atmospherics/components/unary/oxygen_generator/update_icon_nopipes()

	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "scrub_cap", initialize_directions)) //it works for now

	if(!NODE1 || !on || stat & BROKEN)
		icon_state = "o2gen_off"
		return

	else
		icon_state = "o2gen_on"

/obj/machinery/atmospherics/components/unary/oxygen_generator/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = 50
	AIR1 = air_contents

/obj/machinery/atmospherics/components/unary/oxygen_generator/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/air_contents = AIR1

	var/total_moles = air_contents.total_moles()

	if(total_moles < oxygen_content)
		var/current_heat_capacity = air_contents.heat_capacity()

		var/added_oxygen = oxygen_content - total_moles

		air_contents.temperature = (current_heat_capacity*air_contents.temperature + 20*added_oxygen*T0C)/(current_heat_capacity+20*added_oxygen)
		air_contents.assert_gas("o2")
		air_contents.gases["o2"][MOLES] += added_oxygen

		update_parents()

	return 1
