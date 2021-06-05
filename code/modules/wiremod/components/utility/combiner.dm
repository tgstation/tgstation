/**
 * # Combiner Component
 *
 * Combines multiple inputs into 1 output port.
 */
/obj/item/circuit_component/combiner
	display_name = "Combiner"

	/// The amount of input ports to have
	var/input_port_amount = 4

	var/datum/port/output/output_port

	var/current_type

GLOBAL_LIST_INIT(comp_combiner_options, list(
	COMP_COMBINER_ANY,
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_LIST,
	PORT_TYPE_ATOM,
	PORT_TYPE_SIGNAL,
))

/obj/item/circuit_component/combiner/Initialize()
	options = GLOB.comp_combiner_options
	. = ..()
	current_type = current_option
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, current_type)
	output_port = add_output_port("Output", current_type)

/obj/item/circuit_component/combiner/input_received(datum/port/input/port)
	. = ..()
	if(current_type != current_option && (current_option != COMP_COMBINER_ANY || current_type != PORT_TYPE_ANY))
		current_type = current_option
		if(current_type == COMP_COMBINER_ANY)
			current_type = PORT_TYPE_ANY
		for(var/datum/port/input/input_port as anything in input_ports)
			input_port.set_datatype(current_type)
		output_port.set_datatype(current_type)

	output_port.set_output(port?.input_value)
	if(. || !port)
		return TRUE
