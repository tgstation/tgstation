/obj/machinery/atmospherics/components/unary/generator_input

	icon_state = "he_intact"
	density = TRUE

	name = "generator input"
	desc = "An input for a generator."
	layer = LOW_OBJ_LAYER

	var/update_cycle

/obj/machinery/atmospherics/components/unary/generator_input/update_icon()
	icon_state = NODE1 ? "intact" : "exposed"

/obj/machinery/atmospherics/components/unary/generator_input/proc/return_exchange_air()
	return AIR1
