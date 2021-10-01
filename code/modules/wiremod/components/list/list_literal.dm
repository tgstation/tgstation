/**
 * # List Literal Component
 *
 * Return a list literal.
 */
/obj/item/circuit_component/list_literal
	display_name = "List Literal"
	desc = "A component that returns the value of a list at a given index. Attack in hand to increase list size, right click to decrease list size."
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

/obj/item/circuit_component/list_literal/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/list_literal/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/list_literal/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])

	return ..()

/obj/item/circuit_component/list_literal/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port as anything in entry_ports)
			remove_input_port(port)
		entry_ports.Cut()
		length = 0
		return

	while(length > new_size)
		var/index = length(entry_ports)
		var/entry_port = entry_ports[index]
		entry_ports -= entry_port
		remove_input_port(entry_port)
		length--

	while(length < new_size)
		length++
		var/index = length(entry_ports)
		entry_ports += add_input_port("Index [index+1]", list_options.value || PORT_TYPE_ANY)

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
		if(islist(value))
			var/list/lists_to_check = list()
			lists_to_check += list(value)
			var/lists = 1
			while(length(lists_to_check))
				var/list/list_to_iterate = lists_to_check[length(lists_to_check)]
				for(var/list/list_data in list_to_iterate)
					lists_to_check += list(new_data)
					lists += 1
				lists_to_check.len--
				if(lists > max_list_count)
					visible_message(span_warning("[src] begins to overheat!"))
					return
		new_literal += list(value)

	list_output.set_output(new_literal)

