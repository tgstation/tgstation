/**
 * # Combiner Component
 *
 * Combines multiple signals into 1 output port.
 */
/obj/item/circuit_component/combiner
	display_name = "Signal Combiner"

	/// The amount of input ports to have
	var/input_port_amount = 4

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/combiner/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, PORT_TYPE_SIGNAL)

/obj/item/circuit_component/combiner/input_received(datum/port/input/port)
	. = ..()
	if(. || !port)
		return TRUE
