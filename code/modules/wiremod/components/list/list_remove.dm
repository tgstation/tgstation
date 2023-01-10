/**
 * # List Remove Component
 *
 * Removes an element to a list.
 */
/obj/item/circuit_component/variable/list/listremove
	display_name = "List Remove"
	desc = "Removes an element from a list variable."
	category = "List"

	/// Element to remove to the list
	var/datum/port/input/to_remove

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/list/listremove/populate_ports()
	to_remove = add_input_port("To Remove", PORT_TYPE_ANY)

/obj/item/circuit_component/variable/list/listremove/pre_input_received(datum/port/input/port)
	. = ..()
	if(current_variable)
		to_remove.set_datatype(current_variable.datatype_handler.get_datatype(1))

/obj/item/circuit_component/variable/list/listremove/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	var/list/info = current_variable.value
	var/value_to_remove = to_remove.value

	if(isdatum(value_to_remove))
		value_to_remove = WEAKREF(value_to_remove)
	info -= value_to_remove
