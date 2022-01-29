/**
 * # List Add Component
 *
 * Adds an element to a list.
 */
/obj/item/circuit_component/variable/list/listin
	display_name = "Element Find"
	desc = "Checks if an element is in a list."
	category = "List"

	/// Element to check
	var/datum/port/input/to_check

	/// Signal to say we have found the element.
	var/datum/port/output/found
	/// Signal to say we haven't found the element.
	var/datum/port/output/not_found
	/// Result of the search
	var/datum/port/output/result

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

/obj/item/circuit_component/variable/list/listin/populate_ports()
	to_check = add_input_port("To Check", PORT_TYPE_ANY)

	found = add_output_port("Succeeded", PORT_TYPE_SIGNAL)
	not_found = add_output_port("Failed", PORT_TYPE_SIGNAL)
	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/variable/list/listin/pre_input_received(datum/port/input/port)
	. = ..()
	if(current_variable)
		to_check.set_datatype(current_variable.datatype_handler.get_datatype(1))

/obj/item/circuit_component/variable/list/listin/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	var/list/info = current_variable.value
	var/data_to_check = to_check.value

	if(isdatum(data_to_check))
		data_to_check = WEAKREF(data_to_check)

	var/actual_result = (data_to_check in info)
	if(actual_result)
		found.set_output(COMPONENT_SIGNAL)
	else
		not_found.set_output(COMPONENT_SIGNAL)
	result.set_output(actual_result)
