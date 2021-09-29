/**
 * # Assoc List Literal Component
 *
 * Return an associative list literal.
 */
/obj/item/circuit_component/assoc_literal
	display_name = "Associative List Literal"
	desc = "A component that returns an associative list consisting of the inputs. Attack in hand to increase list size, right click to decrease table size."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The inputs used to create the list
	var/list/datum/port/input/key_ports = list()
	var/list/datum/port/input/value_ports = list()
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

/obj/item/circuit_component/assoc_literal/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/assoc_literal/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])

	return ..()

/obj/item/circuit_component/assoc_literal/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port as anything in key_ports)
			remove_input_port(port)
		for(var/datum/port/input/port as anything in value_ports)
			remove_input_port(port)
		key_ports = list()
		value_ports = list()
		length = 0
		return

	while(length > new_size)
		var/index = length(value_ports)
		var/key_port = key_ports[index]
		key_ports -= key_port
		remove_input_port(key_port)
		var/value_port = value_ports[index]
		value_ports -= value_port
		remove_input_port(value_port)
		length--

	while(length < new_size)
		length++
		var/index = length(input_ports)
		if(trigger_input)
			index -= 1
		key_ports += add_input_port("Key [index+1]", PORT_TYPE_STRING)
		value_ports += add_input_port("Index [index+1]", PORT_TYPE_ANY)

/obj/item/circuit_component/assoc_literal/populate_ports()
	set_list_size(default_list_size)
	list_output = add_output_port("Value", PORT_TYPE_ASSOC_LIST)

/obj/item/circuit_component/assoc_literal/Destroy()
	list_output = null
	return ..()

/obj/item/circuit_component/assoc_literal/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_list_size(min(length + 1, max_size))
		if("decrease")
			set_list_size(max(length - 1, min_size))

/obj/item/circuit_component/assoc_literal/input_received(datum/port/input/port)

	var/list/new_literal = list()
	for(var/index in 1 to length)
		new_literal += list(key_ports[index].value = value_ports[index].value)

	list_output.set_output(new_literal)

