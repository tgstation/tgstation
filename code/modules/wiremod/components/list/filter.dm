/**
 * # For Each Component
 *
 * Filters
 */
/obj/item/circuit_component/filter_list
	display_name = "Filter"
	desc = "A component that loops through each element in a list and filters them."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_INSTANT

	/// The list type
	DEFINE_OPTION_PORT(list_options)

	/// Adds the list to the result
	DEFINE_INPUT_PORT(accept_entry)
	/// The list to filter over
	DEFINE_INPUT_PORT(list_to_filter)

	/// The current element from the list
	DEFINE_OUTPUT_PORT(element)
	/// The current index from the list
	DEFINE_OUTPUT_PORT(current_index)
	/// A signal that is sent when the list has moved onto the next index.
	DEFINE_OUTPUT_PORT(on_next_index)
	/// The finished list
	DEFINE_OUTPUT_PORT(finished_list)
	/// A signal that is sent when the filtering has finished
	DEFINE_OUTPUT_PORT(on_finished)
	/// A signal that is sent when the filtering has failed
	DEFINE_OUTPUT_PORT(on_failed)

	ui_buttons = list(
		"plus" = "increase",
	)

/obj/item/circuit_component/filter_list/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/filter_list/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		list_to_filter.set_datatype(PORT_TYPE_LIST(new_datatype))
		finished_list.set_datatype(PORT_TYPE_LIST(new_datatype))
		element.set_datatype(new_datatype)

/obj/item/circuit_component/filter_list/populate_ports()
	list_to_filter = add_input_port("List Input", PORT_TYPE_LIST(PORT_TYPE_ANY))
	accept_entry = add_input_port("Accept Entry", PORT_TYPE_SIGNAL, trigger = .proc/accept_entry)

	element = add_output_port("Element", PORT_TYPE_ANY)
	current_index = add_output_port("Index", PORT_TYPE_NUMBER)
	on_next_index = add_output_port("Next Index", PORT_TYPE_SIGNAL)
	finished_list = add_output_port("Filtered List", PORT_TYPE_LIST(PORT_TYPE_ANY))
	on_finished = add_output_port("On Finished", PORT_TYPE_SIGNAL)
	on_failed = add_output_port("On Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/filter_list/proc/accept_entry(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER
	if(return_values)
		return_values["accept_entry"] = TRUE

/obj/item/circuit_component/filter_list/input_received(datum/port/input/port)
	var/index = 1
	var/start_tick_usage = TICK_USAGE
	var/list/filtered_list = list()
	for(var/element_in_list in list_to_filter.value)
		SScircuit_component.queue_instant_run(start_tick_usage)
		element.set_output(element_in_list)
		current_index.set_output(index)
		on_next_index.set_output(COMPONENT_SIGNAL)
		index += 1
		var/list/result = SScircuit_component.execute_instant_run()
		if(!result)
			visible_message("[src] starts to overheat!")
			on_failed.set_output(COMPONENT_SIGNAL)
			return
		if(result["accept_entry"])
			filtered_list += list(element_in_list)
	finished_list.set_output(filtered_list)
	on_finished.set_output(COMPONENT_SIGNAL)
