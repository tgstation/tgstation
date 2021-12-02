/**
 * # List Literal Component
 *
 * Return a list literal.
 */
/obj/item/circuit_component/list_literal
	display_name = "List Literal"
	desc = "A component that creates a list from whatever input you give it."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list type
	var/datum/port/input/option/list_options

	/// The inputs used to create the list
	var/list/datum/port/input/entry_ports = list()
	/// The result from the output
	var/datum/port/output/list_output

	var/length = 0

	var/default_list_size = 2

	var/min_size = 1
	var/max_size = 20

	ui_buttons = list(
		"plus" = "increase",
		"minus" = "decrease"
	)

	var/max_list_count = 100

/obj/item/circuit_component/list_literal/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/list_literal/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/list_literal/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])

	return ..()

/obj/item/circuit_component/list_literal/proc/clear_lists()
	for(var/datum/port/input/port as anything in entry_ports)
		remove_input_port(port)
	entry_ports.Cut()
	length = 0

/obj/item/circuit_component/list_literal/proc/remove_one_entry()
	var/index = length(entry_ports)
	var/entry_port = entry_ports[index]
	entry_ports -= entry_port
	remove_input_port(entry_port)
	length--

/obj/item/circuit_component/list_literal/proc/add_one_entry()
	length++
	entry_ports += add_input_port("Index [length]", list_options.value || PORT_TYPE_ANY)

/obj/item/circuit_component/list_literal/proc/set_list_size(new_size)
	if(new_size <= 0)
		clear_lists()
		return

	while(length > new_size)
		remove_one_entry()

	while(length < new_size)
		add_one_entry()

/obj/item/circuit_component/list_literal/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_output.set_datatype(PORT_TYPE_LIST(new_datatype))
		for(var/datum/port/input/port_to_set as anything in entry_ports)
			port_to_set.set_datatype(new_datatype)

/obj/item/circuit_component/list_literal/populate_ports()
	set_list_size(default_list_size)
	list_output = add_output_port("Value", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/list_literal/Destroy()
	list_output = null
	return ..()

// Increases list length
/obj/item/circuit_component/list_literal/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_list_size(min(length + 1, max_size))
		if("decrease")
			set_list_size(max(length - 1, min_size))

/obj/item/circuit_component/list_literal/input_received(datum/port/input/port)

	var/list/new_literal = list()
	for(var/datum/port/input/entry_port as anything in entry_ports)
		var/value = entry_port.value
		// To prevent people from infinitely making lists to crash the server
		if(islist(value) && get_list_count(value, max_list_count) >= max_list_count)
			visible_message("[src] begins to overheat!")
			return
		if(is_proper_datum(value))
			new_literal += WEAKREF(value)
		else
			new_literal += list(value)

	list_output.set_output(new_literal)

/proc/get_list_count(list/value, max_list_count)
	var/list/lists_to_check = list()
	lists_to_check += list(value)
	var/lists = 1
	while(length(lists_to_check))
		var/list/list_to_iterate = lists_to_check[length(lists_to_check)]
		lists_to_check.len--
		for(var/list/list_data in list_to_iterate)
			lists_to_check += list(list_data)
			lists += 1
		if(lists > max_list_count)
			return lists
	return lists
