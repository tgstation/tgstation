/**
 * # Get Column Component
 *
 * Gets the column of a table and returns it as a regular list.
 */
/obj/item/circuit_component/get_column
	display_name = "Get Column"
	desc = "Gets the column of a table and returns it as a regular list."
	category = "List"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list to perform the filter on
	var/datum/port/input/received_table

	/// The name of the column to check
	var/datum/port/input/column_name

	/// The filtered list
	var/datum/port/output/output_list

/obj/item/circuit_component/get_column/populate_ports()
	received_table = add_input_port("Input", PORT_TYPE_TABLE)
	column_name = add_input_port("Column Name", PORT_TYPE_STRING)
	output_list = add_output_port("Output", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/get_column/input_received(datum/port/input/port)

	var/list/input_list = received_table.value
	if(!islist(input_list) || isnum(column_name.value))
		return

	var/list/new_list = list()
	for(var/list/entry in input_list)
		var/anything = entry[column_name.value]
		if(islist(anything))
			continue
		new_list += anything

	output_list.set_output(new_list)
