/**
 * # Concat List Component
 *
 * Concatenates a list with a separator
 */
/obj/item/circuit_component/concat_list
	display_name = "Concatenate List"
	desc = "Splits string by a separator, turning it into a list."

	/// The input port
	var/datum/port/input/input_port

	/// The seperator
	var/datum/port/input/separator

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/concat_list/populate_ports()
<<<<<<< HEAD:code/modules/wiremod/components/list/concat_list.dm
	list_port = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))
=======
	list_port = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))
>>>>>>> master:code/modules/wiremod/components/list/concat.dm
	separator = add_input_port("Seperator", PORT_TYPE_STRING)
	output = add_output_port("Output", PORT_TYPE_LIST)

/obj/item/circuit_component/concat_list/input_received(datum/port/input/port)

	var/separator_value = separator.value
	if(isnull(separator_value))
		return

	var/value = input_port.value
	if(isnull(value))
		return

	var/list/result = splittext(value,separator_value)

	output.set_output(result)
