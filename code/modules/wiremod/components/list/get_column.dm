/**
 * # Get Column Component
 *
 * Gets the column of a table and returns it as a regular list.
 */
/obj/item/circuit_component/get_column
	display_name = "Get Column"
	display_desc = "Gets the column of a table and returns it as a regular list."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list to perform the filter on
	var/datum/port/input/received_table

	/// The name of the column to check
	var/datum/port/input/column_name

	/// The filtered list
	var/datum/port/output/output_list

/obj/item/circuit_component/get_column/Initialize()
	. = ..()
	received_table = add_input_port("Input", PORT_TYPE_TABLE)
	column_name = add_input_port("Column Name", PORT_TYPE_STRING)
	output_list = add_output_port("Output", PORT_TYPE_LIST)

/obj/item/circuit_component/get_column/Destroy()
	received_table = null
	column_name = null
	output_list = null
	return ..()

/obj/item/circuit_component/get_column/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/list/input_list = received_table.input_value
	if(!islist(input_list) || isnum(column_name.input_value))
		return

	var/list/new_list = list()
	for(var/list/entry in input_list)
		var/anything = entry[column_name.input_value]
		if(islist(anything))
			continue
		new_list += anything

	output_list.set_output(new_list)
