/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/not
	display_name = "Not"
	desc = "A component that inverts its input."
	category = "Math"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/result
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/not/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/not/input_received(datum/port/input/port)

	result.set_output(!input_port.value)

