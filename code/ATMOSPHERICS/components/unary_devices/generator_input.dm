/obj/machinery/atmospherics/unary/generator_input

	icon_state = "he_intact"
	density = 1

	name = "generator input"
	desc = "Placeholder"

	var/update_cycle

/obj/machinery/atmospherics/unary/generator_input/update_icon()
	if(nodes["n1"])
		icon_state = "intact"
	else
		icon_state = "exposed"

	return

/obj/machinery/atmospherics/unary/generator_input/proc/return_exchange_air()
	return airs["a1"]
