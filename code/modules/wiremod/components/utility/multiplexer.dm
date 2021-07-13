/**
 * # Combiner Component
 *
 * Combines multiple inputs into 1 output port.
 */
/obj/item/circuit_component/multiplexer
	display_name = "Multiplexer"
	display_desc = "A component that allows you to selectively choose which input port provides an output. The first port is the selector and takes a number between 1 and the maximum port amount."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The port to select from, goes from 1 to input_port_amount
	var/datum/port/input/input_port

	/// The amount of input ports to have
	var/input_port_amount = 4

	var/datum/port/output/output_port

	/// Current type of the ports
	var/current_type

	/// The multiplexer inputs. These are what get selected for the output by the input_port.
	var/list/datum/port/input/multiplexer_inputs

/obj/item/circuit_component/multiplexer/populate_options()
	var/static/component_options = list(
		COMP_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	options = component_options

/obj/item/circuit_component/multiplexer/Initialize()
	. = ..()
	current_option = COMP_TYPE_ANY
	current_type = COMP_TYPE_ANY
	input_port = add_input_port("Selector", PORT_TYPE_NUMBER, default = 1)
	multiplexer_inputs = list()
	for(var/port_id in 1 to input_port_amount)
		multiplexer_inputs += add_input_port("Port [port_id]", PORT_TYPE_ANY)
	output_port = add_output_port("Output", PORT_TYPE_ANY)

/obj/item/circuit_component/multiplexer/Destroy()
	output_port = null
	multiplexer_inputs.Cut()
	multiplexer_inputs = null
	return ..()


/obj/item/circuit_component/multiplexer/input_received(datum/port/input/port)
	. = ..()
	if(current_type != current_option && (current_option != COMP_TYPE_ANY || current_type != PORT_TYPE_ANY))
		current_type = current_option
		if(current_type == COMP_TYPE_ANY)
			current_type = PORT_TYPE_ANY
		for(var/datum/port/input/input_port as anything in multiplexer_inputs)
			input_port.set_datatype(current_type)
		output_port.set_datatype(current_type)

	input_port.set_input(clamp(input_port.input_value || 1, 1, input_port_amount), FALSE)
	if(.)
		return TRUE
	output_port.set_output(multiplexer_inputs[input_port.input_value].input_value)

