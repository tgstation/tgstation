/obj/machinery/atmospherics/components/unary/generator_input

	icon_state = "he_intact"
	density = 1

	name = "generator input"
	desc = "Placeholder"

	var/update_cycle

/obj/machinery/atmospherics/components/unary/generator_input/update_icon()
	if(nodes[NODE1])
		icon_state = "intact"
	else
		icon_state = "exposed"

	return

/obj/machinery/atmospherics/components/unary/generator_input/proc/return_exchange_air()
	return airs[AIR1]
