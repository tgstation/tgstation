/**
 * # Combiner Component
 *
 * Combines multiple inputs into 1 output port.
 */
/obj/item/circuit_component/combiner
	display_name = "Combiner"
	desc = "A component that combines multiple inputs to provide 1 output."

	/// The amount of input ports to have
	var/input_port_amount = 4
	var/datum/port/input/option/combiner_options

	var/datum/port/output/output_port

	var/list/combiner_ports = list()
	var/current_type

/obj/item/circuit_component/combiner/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
		PORT_TYPE_SIGNAL,
	)
	combiner_options = add_option_port("Combiner Options", component_options)

/obj/item/circuit_component/combiner/Initialize()
	. = ..()
	current_type = combiner_options.input_value
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		combiner_ports += add_input_port(letter, current_type)
	output_port = add_output_port("Output", current_type)

/obj/item/circuit_component/combiner/input_received(datum/port/input/port)
	. = ..()
	if(current_type != combiner_options.input_value)
		current_type = combiner_options.input_value
		for(var/datum/port/input/input_port as anything in combiner_ports)
			input_port.set_datatype(current_type)
		output_port.set_datatype(current_type)

	if(. || !port)
		return TRUE
	output_port.set_output(port.input_value)
