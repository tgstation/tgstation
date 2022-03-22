/**
 * # Concatenate Component
 *
 * General string concatenation component. Puts strings together.
 */
/obj/item/circuit_component/concat
	display_name = "Concatenate"
	desc = "A component that combines strings."
	category = "String"

	/// The amount of input ports to have
	var/input_port_amount = 4

	var/list/datum/port/input/concat_ports = list()

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/concat/populate_ports()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		concat_ports += add_input_port(letter, PORT_TYPE_STRING)

	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/concat/input_received(datum/port/input/port)

	var/result = ""
	for(var/datum/port/input/input_port as anything in concat_ports)
		var/value = input_port.value
		if(isnull(value))
			continue

		result += "[value]"

	output.set_output(result)

