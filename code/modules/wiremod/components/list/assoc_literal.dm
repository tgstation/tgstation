/**
 * # Assoc List Literal Component
 *
 * Return an associative list literal.
 */
/obj/item/circuit_component/assoc_literal
	display_name = "Associative List Literal"
	desc = "A component that returns an associative list consisting of the inputs."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// The inputs used to create the list
	var/list/datum/port/input/entry_ports = list()
	/// The inputs used to create the list
	var/list/datum/port/input/key_ports = list()

	/// The result from the output
	var/datum/port/output/list_output

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

	var/max_list_count = 100

/obj/item/circuit_component/assoc_literal/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_output.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_datatype))
		for(var/datum/port/input/port_to_set as anything in entry_ports)
			port_to_set.set_datatype(new_datatype)

/obj/item/circuit_component/assoc_literal/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/assoc_literal/populate_ports()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = entry_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_ANY, \
		prefix = "Index", \
		minimum_amount = 1, \
		maximum_amount = 20 \
	)
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = key_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_STRING, \
		prefix = "Key", \
		minimum_amount = 1, \
		maximum_amount = 20 \
	)
	list_output = add_output_port("Value", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY), order = 1.1)

/obj/item/circuit_component/assoc_literal/input_received(datum/port/input/port)
	var/list/new_literal = list()
	var/datum/circuit_datatype/value_handler = GLOB.circuit_datatypes[list_options.value]
	var/datum/circuit_datatype/key_handler = GLOB.circuit_datatypes[PORT_TYPE_STRING]
	for(var/index in 1 to length(entry_ports))
		// To prevent people from infinitely making lists to crash the server
		if(islist(entry_ports[index].value) && get_list_count(entry_ports[index].value, max_list_count) >= max_list_count)
			visible_message("[src] begins to overheat!")
			return
		var/value_to_add = value_handler.convert_value(port, entry_ports[index].value)
		if(isdatum(value_to_add))
			value_to_add = WEAKREF(value_to_add)
		new_literal[key_handler.convert_value(port, key_ports[index].value)] = value_to_add

	list_output.set_output(new_literal)

