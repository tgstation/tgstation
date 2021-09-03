/**
 * # Index Table Component
 *
 * Gets the row of a table using the index inputted. Will return no value if the index is invalid or a proper table is not returned.
 */
/obj/item/circuit_component/index_table
	display_name = "Index Table"
	desc = "Gets the row of a table using the index inputted. Will return no value if the index is invalid or a proper table is not returned."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The list to perform the filter on
	var/datum/port/input/received_table

	/// The target index
	var/datum/port/input/target_index

	/// The filtered list
	var/datum/port/output/output_list

/obj/item/circuit_component/index_table/populate_ports()
	received_table = add_input_port("Input", PORT_TYPE_TABLE)
	target_index = add_input_port("Index", PORT_TYPE_NUMBER)

	output_list = add_output_port("Output", PORT_TYPE_LIST)

/obj/item/circuit_component/index_table/input_received(datum/port/input/port)

	var/list/target_list = received_table.value
	if(!islist(target_list) || !length(target_list))
		output_list.set_output(null)
		return

	var/index = target_index.value
	if(index < 1 || index > length(target_list))
		output_list.set_output(null)
		return

	output_list.set_output(target_list[index])
