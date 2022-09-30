/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/index
	display_name = "Index List"
	desc = "A component that returns the value of a list at a given index."
	category = "List"

	/// The list type
	var/datum/port/input/option/list_options

	/// The input port
	var/datum/port/input/list_port
	var/datum/port/input/index_port

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/index_type = PORT_TYPE_NUMBER

/obj/item/circuit_component/index/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/index/proc/make_list_port()
	list_port = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/index/populate_ports()
	index_port = add_input_port("Index", index_type)
	make_list_port()

	output = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/index/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		list_port.set_datatype(PORT_TYPE_LIST(new_type))
		output.set_datatype(new_type)

/obj/item/circuit_component/index/input_received(datum/port/input/port)

	var/index = index_port.value
	var/list/list_input = list_port.value

	if(!islist(list_input) || !index)
		output.set_output(null)
		return

	if(isnum(index) && (index < 1 || index > length(list_input)))
		output.set_output(null)
		return

	output.set_output(list_input[index])

/obj/item/circuit_component/index/assoc_string
	display_name = "Index Associative List"
	desc = "A component that is commonly used to access a row from a table. Accesses data from a key, value list."

	index_type = PORT_TYPE_STRING

/obj/item/circuit_component/index/assoc_string/make_list_port()
	list_port = add_input_port("List", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))

/obj/item/circuit_component/index/assoc_string/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		list_port.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_type))
		output.set_datatype(new_type)
