/**
 * # List Add Component
 *
 * Adds an element to a list.
 */
/obj/item/circuit_component/variable/list/listadd
	display_name = "List Add"
	desc = "Adds an element to a list variable."
	category = "List"

	/// Element to add to the list
	var/datum/port/input/to_add
	/// Whether to add duplicates or not
	var/datum/port/input/allow_duplicate
	/// For when the list is too long, a signal is sent here.
	var/datum/port/output/failed

	var/max_list_size = 500

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/list/listadd/get_ui_notices()
	. = ..()
	. += create_ui_notice("Max List Size: [max_list_size]", "orange", "sitemap")

/obj/item/circuit_component/variable/list/listadd/populate_ports()
	to_add = add_input_port("To Add", PORT_TYPE_ANY)
	allow_duplicate = add_input_port("Allow Duplicate", PORT_TYPE_NUMBER, default = 0)
	failed = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/variable/list/listadd/pre_input_received(datum/port/input/port)
	. = ..()
	if(current_variable)
		to_add.set_datatype(current_variable.datatype_handler.get_datatype(1))

/obj/item/circuit_component/variable/list/listadd/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	var/list/info = current_variable.value
	var/data_to_add = to_add.value

	if(length(info) >= max_list_size)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(isdatum(data_to_add))
		data_to_add = WEAKREF(data_to_add)

	if(!allow_duplicate.value)
		info |= data_to_add
	else
		info += data_to_add
