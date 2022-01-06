/**
 * # Assoc List Literal Component
 *
 * Return an associative list literal.
 */
/obj/item/circuit_component/list_literal/assoc_literal
	display_name = "Associative List Literal"
	desc = "A component that returns an associative list consisting of the inputs."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The inputs used to create the list
	var/list/datum/port/input/key_ports = list()

/obj/item/circuit_component/list_literal/assoc_literal/clear_lists()
	for(var/datum/port/input/port as anything in key_ports)
		remove_input_port(port)
	for(var/datum/port/input/port as anything in entry_ports)
		remove_input_port(port)
	key_ports = list()
	entry_ports = list()
	length = 0

/obj/item/circuit_component/list_literal/assoc_literal/remove_one_entry()
	var/index = length(entry_ports)
	var/key_port = key_ports[index]
	key_ports -= key_port
	remove_input_port(key_port)
	var/value_port = entry_ports[index]
	entry_ports -= value_port
	remove_input_port(value_port)
	length--

/obj/item/circuit_component/list_literal/assoc_literal/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_output.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_datatype))
		for(var/datum/port/input/port_to_set as anything in entry_ports)
			port_to_set.set_datatype(new_datatype)

/obj/item/circuit_component/list_literal/assoc_literal/add_one_entry()
	length++
	key_ports += add_input_port("Key [length]", PORT_TYPE_STRING)
	entry_ports += add_input_port("Index [length]", PORT_TYPE_ANY)

/obj/item/circuit_component/list_literal/assoc_literal/populate_ports()
	set_list_size(default_list_size)
	list_output = add_output_port("Value", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))

/obj/item/circuit_component/list_literal/assoc_literal/input_received(datum/port/input/port)
	var/list/new_literal = list()
	for(var/index in 1 to length)
		// To prevent people from infinitely making lists to crash the server
		if(islist(entry_ports[index].value) && get_list_count(entry_ports[index].value, max_list_count) >= max_list_count)
			visible_message("[src] begins to overheat!")
			return
		var/value_to_add = entry_ports[index].value
		if(isdatum(value_to_add))
			value_to_add = WEAKREF(value_to_add)
		new_literal[key_ports[index].value] = entry_ports[index].value

	list_output.set_output(new_literal)

