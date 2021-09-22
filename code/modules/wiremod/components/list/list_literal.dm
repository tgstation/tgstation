/**
 * # List Literal Component
 *
 * Return a list literal.
 */
/obj/item/circuit_component/list_literal
	display_name = "List Literal"
	desc = "A component that returns the value of a list at a given index. Attack in hand to increase list size, right click to decrease list size."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The inputs used to create the list
	var/list/datum/port/input/entry_ports = list()
	/// The result from the output
	var/datum/port/output/list_output

	var/length = 0

	var/default_list_size = 2

	var/min_size = 1
	var/max_size = 20

/obj/item/circuit_component/list_literal/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/list_literal/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])

	return ..()

/obj/item/circuit_component/list_literal/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port in entry_ports)
			remove_input_port(port)
		entry_ports = list()
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
		var/index = length(input_ports)
		if(trigger_input)
			index -= 1
		entry_ports += add_input_port("Index [index+1]", PORT_TYPE_ANY)

/obj/item/circuit_component/list_literal/populate_ports()
	set_list_size(default_list_size)
	list_output = add_output_port("Value", PORT_TYPE_LIST)

/obj/item/circuit_component/list_literal/Destroy()
	list_output = null
	return ..()

// Increases list length
/obj/item/circuit_component/list_literal/attack_self(mob/user, list/modifiers)
	. = ..()
	set_list_size(min(length + 1, max_size))
	balloon_alert(user, "new size is now [length]")

// Decreases list length
/obj/item/circuit_component/list_literal/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	set_list_size(max(length - 1, min_size))
	balloon_alert(user, "new size is now [length]")

/obj/item/circuit_component/list_literal/input_received(datum/port/input/port)

	var/list/new_literal = list()
	for(var/datum/port/input/entry_port as anything in entry_ports)
		// Prevents lists from merging together
		new_literal += list(entry_port.value)

	list_output.set_output(new_literal)

