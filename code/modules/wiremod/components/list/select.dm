/**
 * # Select Component
 *
 * Selects a list from a list of lists by a specific column. Used only by USBs for communications to and from computers with lists of varying sizes.
 */
/obj/item/circuit_component/select
	display_name = "Select Query"
	display_desc = "A component that can perform select queries on a list based on the column name selected. The values are then compared with the comparison input. Only useful for USB cables"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list to perform the filter on
	var/datum/port/input/received_list

	/// The name of the column to check
	var/datum/port/input/column_name

	/// The input to compare with
	var/datum/port/input/comparison_input

	/// The filtered list
	var/datum/port/output/filtered_list

	var/current_type = PORT_TYPE_ANY

/obj/item/circuit_component/select/populate_options()
	var/static/component_options = list(
		COMP_COMPARISON_EQUAL,
		COMP_COMPARISON_NOT_EQUAL,
		COMP_COMPARISON_GREATER_THAN,
		COMP_COMPARISON_LESS_THAN,
		COMP_COMPARISON_GREATER_THAN_OR_EQUAL,
		COMP_COMPARISON_LESS_THAN_OR_EQUAL,
	)
	options = component_options

/obj/item/circuit_component/select/Initialize()
	. = ..()
	received_list = add_input_port("Input List", PORT_TYPE_TABLE)
	column_name = add_input_port("Column Name", PORT_TYPE_STRING)
	comparison_input = add_input_port("Comparison Input", PORT_TYPE_ANY)

	filtered_list = add_output_port("Output", PORT_TYPE_TABLE)

/obj/item/circuit_component/select/Destroy()
	received_list = null
	column_name = null
	comparison_input = null
	filtered_list = null
	return ..()

/obj/item/circuit_component/select/input_received(datum/port/input/port)
	. = ..()
	switch(current_option)
		if(COMP_COMPARISON_EQUAL, COMP_COMPARISON_NOT_EQUAL)
			if(current_type != PORT_TYPE_ANY)
				current_type = PORT_TYPE_ANY
				comparison_input.set_datatype(PORT_TYPE_ANY)
		else
			if(current_type != PORT_TYPE_NUMBER)
				current_type = PORT_TYPE_NUMBER
				comparison_input.set_datatype(PORT_TYPE_NUMBER)

	if(.)
		return

	var/list/input_list = received_list.input_value
	if(!islist(input_list) || isnum(column_name.input_value))
		return

	var/comparison_value = comparison_input.input_value
	var/list/new_list = list()
	for(var/list/entry in input_list)
		var/anything = entry[column_name.input_value]
		if(!anything || islist(anything))
			continue
		if(current_option != COMP_COMPARISON_EQUAL && current_option != COMP_COMPARISON_NOT_EQUAL && !isnum(anything))
			continue
		var/add_to_list = FALSE
		switch(current_option)
			if(COMP_COMPARISON_EQUAL)
				add_to_list = anything == comparison_value
			if(COMP_COMPARISON_NOT_EQUAL)
				add_to_list = anything != comparison_value
			if(COMP_COMPARISON_GREATER_THAN)
				add_to_list = anything > comparison_value
			if(COMP_COMPARISON_GREATER_THAN_OR_EQUAL)
				add_to_list = anything >= comparison_value
			if(COMP_COMPARISON_LESS_THAN)
				add_to_list = anything < comparison_value
			if(COMP_COMPARISON_LESS_THAN_OR_EQUAL)
				add_to_list = anything <= comparison_value

		if(add_to_list)
			new_list += list(entry)

	filtered_list.set_output(new_list)
