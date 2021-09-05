/**
 * # Length Component
 *
 * Return the length of an input
 */
/obj/item/circuit_component/length
	display_name = "Length"
	desc = "A component that returns the length of its input."

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/length/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	output = add_output_port("Length", PORT_TYPE_NUMBER)

/obj/item/circuit_component/length/input_received(datum/port/input/port)

	output.set_output(length(input_port.value))

