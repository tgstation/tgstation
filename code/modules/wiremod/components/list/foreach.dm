/**
 * # For Each Component
 *
 * Sends a signal for each item in a list
 */
/obj/item/circuit_component/foreach
	display_name = "For Each"
	desc = "A component that loops through each element in a list."
	category = "List"

	/// The list type
	var/datum/port/input/option/list_options

	/// The list to iterate over
	var/datum/port/input/list_to_iterate
	/// Move to the next index
	var/datum/port/input/next_index
	/// Resets the index to 0
	var/datum/port/input/reset_index

	/// The current element from the list
	var/datum/port/output/element
	/// The current index from the list
	var/datum/port/output/current_index
	/// A signal that is sent when the list has moved onto the next index.
	var/datum/port/output/on_next_index
	/// A signal that is sent when the list has finished iterating
	var/datum/port/output/on_finished

	var/current_actual_index = 1


/obj/item/circuit_component/foreach/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/foreach/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_to_iterate.set_datatype(PORT_TYPE_LIST(new_datatype))
		element.set_datatype(new_datatype)

/obj/item/circuit_component/foreach/populate_ports()
	list_to_iterate = add_input_port("List Input", PORT_TYPE_LIST(PORT_TYPE_ANY))
	next_index = add_input_port("Next Index", PORT_TYPE_SIGNAL, trigger = .proc/trigger_next_index)
	reset_index = add_input_port("Reset And Trigger", PORT_TYPE_SIGNAL, trigger = .proc/restart)

	element = add_output_port("Element", PORT_TYPE_ANY)
	current_index = add_output_port("Index", PORT_TYPE_NUMBER)
	on_next_index = add_output_port("Next Index", PORT_TYPE_SIGNAL)
	on_finished = add_output_port("On Finished", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/foreach/proc/restart(datum/port/input/port)
	CIRCUIT_TRIGGER
	current_actual_index = 1
	trigger_next_index(port)

/obj/item/circuit_component/foreach/proc/trigger_next_index(datum/port/input/port)
	CIRCUIT_TRIGGER

	var/list/to_check = list_to_iterate.value
	if(!to_check)
		return
	if(current_actual_index > length(to_check))
		on_finished.set_output(COMPONENT_SIGNAL)
		return
	element.set_output(to_check[current_actual_index])
	current_index.set_output(current_actual_index)
	on_next_index.set_output(COMPONENT_SIGNAL)
	current_actual_index += 1
