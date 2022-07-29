/**
 * # List Clear Component
 *
 * Clears an element to a list.
 */
/obj/item/circuit_component/variable/list/listclear
	display_name = "List Clear"
	desc = "Clears a list variable."
	category = "List"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/list/listclear/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	current_variable.set_value(list())

