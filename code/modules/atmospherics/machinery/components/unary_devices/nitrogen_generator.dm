/obj/machinery/atmospherics/components/unary/nitrogen_generator

	icon_state = "o2gen_map"

	name = "nitrogen generator"
	desc = "Generates nitrogen"

	dir = SOUTH
	initialize_directions = SOUTH

	var/on = 0

	var/nitrogen_content = 10

/obj/machinery/atmospherics/components/unary/nitrogen_generator/update_icon_nopipes()

	overlays.Cut()
	if(showpipe)
		overlays += getpipeimage('icons/obj/atmospherics/components/unary_devices.dmi', "scrub_cap", initialize_directions) //it works for now

	if(!NODE1 || !on || stat & BROKEN)
		icon_state = "o2gen_off"
		return

	else
		icon_state = "o2gen_on"

/obj/machinery/atmospherics/components/unary/nitrogen_generator/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = 50
	AIR1 = air_contents

/obj/machinery/atmospherics/components/unary/nitrogen_generator/process_atmos()
	..()
	if(!on)
		return 0

	var/datum/gas_mixture/air_contents = AIR1

	var/total_moles = air_contents.total_moles()

	if(total_moles < nitrogen_content)
		var/current_heat_capacity = air_contents.heat_capacity()

		var/added_nitrogen = nitrogen_content - total_moles

		air_contents.temperature = (current_heat_capacity*air_contents.temperature + 20*added_nitrogen*T0C)/(current_heat_capacity+20*added_nitrogen)
		air_contents.assert_gas("n2")
		air_contents.gases["n2"][MOLES] += added_nitrogen

		update_parents()

	return 1
