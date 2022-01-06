/**
 * # Select Component
 *
 * Selects a list from a list of lists by a specific column. Used only by USBs for communications to and from computers with lists of varying sizes.
 */
/obj/item/circuit_component/select
	display_name = "Select Query"
	desc = "A component used with USB cables that can perform select queries on a list based on the column name selected. The values are then compared with the comparison input."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/comparison_options

	/// The list to perform the filter on
	var/datum/port/input/received_table

	/// The name of the column to check
	var/datum/port/input/column_name

	/// The input to compare with
	var/datum/port/input/comparison_input

	/// The filtered list
	var/datum/port/output/filtered_table

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
	comparison_options = add_option_port("Comparison Options", component_options)

/obj/item/circuit_component/select/populate_ports()
	received_table = add_input_port("Input", PORT_TYPE_TABLE)
	column_name = add_input_port("Column Name", PORT_TYPE_STRING)
	comparison_input = add_input_port("Comparison Input", PORT_TYPE_ANY)

	filtered_table = add_output_port("Output", PORT_TYPE_TABLE)

/obj/item/circuit_component/select/pre_input_received(datum/port/input/port)
	var/current_option = comparison_options.value
	switch(current_option)
		if(COMP_COMPARISON_EQUAL, COMP_COMPARISON_NOT_EQUAL)
			if(current_type != PORT_TYPE_ANY)
				current_type = PORT_TYPE_ANY
				comparison_input.set_datatype(PORT_TYPE_ANY)
		else
			if(current_type != PORT_TYPE_NUMBER)
				current_type = PORT_TYPE_NUMBER
				comparison_input.set_datatype(PORT_TYPE_NUMBER)


/obj/item/circuit_component/select/input_received(datum/port/input/port)
	var/current_option = comparison_options.value
	var/list/input_list = received_table.value
	if(!islist(input_list) || isnum(column_name.value))
		return

	var/comparison_value = comparison_input.value
	var/list/new_list = list()
	for(var/list/entry in input_list)
		var/anything = entry[column_name.value]
		if(islist(anything))
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

	filtered_table.set_output(new_list)
