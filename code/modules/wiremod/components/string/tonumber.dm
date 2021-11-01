/**
 * #To Number Component
 *
 * Converts a string into a Number
 */
/obj/item/circuit_component/tonumber
	display_name = "To Number"
	desc = "A component that converts its input (a string) to a number. If there's text in the input, it'll only consider it if it starts with a number. It will take that number and ignore the rest."
	category = "String"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/tonumber/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_STRING)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tonumber/input_received(datum/port/input/port)

	output.set_output(text2num(input_port.value))
