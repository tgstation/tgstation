/**
 * # Concat List Component
 *
 * Concatenates a list with a separator
 */
/obj/item/circuit_component/concat_list
	display_name = "Concatenate List"
	desc = "A component that joins up a list with a separator into a single string."
	category = "List"

	/// The input port
	var/datum/port/input/list_port

	/// The seperator
	var/datum/port/input/separator

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/concat_list/populate_ports()
	list_port = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))
	separator = add_input_port("Seperator", PORT_TYPE_STRING)

	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/concat_list/input_received(datum/port/input/port)

	var/seperator = separator.value
	if(!seperator)
		return

	var/list/list_input = list_port.value
	if(!list_input)
		return

	var/list/text_list = list()
	for(var/entry in list_input)
		if(isdatum(entry))
			text_list += PORT_TYPE_ATOM
		else
			text_list += "[entry]"

	output.set_output(text_list.Join(seperator))

