/obj/machinery/atmospherics/components/unary/generator_input

	icon_state = "he_intact"
	density = TRUE

	name = "generator input"
	desc = "An input for a generator."
	layer = LOW_OBJ_LAYER

	var/update_cycle

/obj/machinery/atmospherics/components/unary/generator_input/update_icon()
	if(NODE1)
		icon_state = "intact"
	else
		icon_state = "exposed"

	return

/obj/machinery/atmospherics/components/unary/generator_input/proc/return_exchange_air()
	return AIR1
