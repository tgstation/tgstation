/**
 * # Assoc List Set Component
 *
 * Sets a string value on an assoc list.
 */
/obj/item/circuit_component/variable/assoc_list/list_set
	display_name = "Associative List Set"
	desc = "Sets a string key on an associative list to a specific value."
	category = "List"

	/// Key to set
	var/datum/port/input/key
	/// Value to set the key to.
	var/datum/port/input/value
	/// For when the list is too long, a signal is sent here.
	var/datum/port/output/failed

	var/max_list_size = 500

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/variable/assoc_list/list_set/get_ui_notices()
	. = ..()
	. += create_ui_notice("Max List Size: [max_list_size]", "orange", "sitemap")

/obj/item/circuit_component/variable/assoc_list/list_set/populate_ports()
	key = add_input_port("Key", PORT_TYPE_STRING)
	value = add_input_port("Value", PORT_TYPE_ANY)
	failed = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/variable/assoc_list/list_set/pre_input_received(datum/port/input/port)
	. = ..()
	if(current_variable)
		value.set_datatype(current_variable.datatype_handler.get_datatype(2))

/obj/item/circuit_component/variable/assoc_list/list_set/input_received(datum/port/input/port, list/return_values)
	if(!current_variable)
		return
	var/list/info = current_variable.value
	var/key_to_set = key.value
	var/value_to_set = value.value

	if(!key_to_set)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(length(info) >= max_list_size)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(isdatum(value_to_set))
		value_to_set = WEAKREF(value_to_set)

	info[key_to_set] = value_to_set
