/**
 * # Square root component
 *
 * Returns the square root of the input
 */
/obj/item/circuit_component/square_root
	display_name = "Square root"
	desc = "A component that returns the square root of its input."
	category = "Math"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/length/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_NUMBER)

	output = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/length/input_received(datum/port/input/port)

	output.set_output(sqrt(input_port.value))
