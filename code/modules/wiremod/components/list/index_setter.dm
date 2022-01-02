/obj/item/circuit_component/index_setter
	display_name = "Set List Element By Index"
	desc = "A component that sets the value of a list at a given index."
	category = "List"

	/// The list type
	var/datum/port/input/option/list_options

	/// The input ports
	var/datum/port/input/list_input_port
	var/datum/port/input/new_element_value
	var/datum/port/input/index_port

	/// The list after setting the value
	var/datum/port/output/list_output_port
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/index_type = PORT_TYPE_NUMBER

/obj/item/circuit_component/index_setter/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/index_setter/proc/make_list_ports()
	list_input_port = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))
	list_output_port = add_output_port("Modified List", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/index_setter/populate_ports()
	index_port = add_input_port("Index", index_type)
	new_element_value = add_input_port("New Value", PORT_TYPE_ANY)
	make_list_ports()

/obj/item/circuit_component/index_setter/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		list_input_port.set_datatype(PORT_TYPE_LIST(new_type))
		list_output_port.set_datatype(PORT_TYPE_LIST(new_type))
		new_element_value.set_datatype(new_type)

/obj/item/circuit_component/index_setter/input_received(datum/port/input/port)

	var/index = index_port.value
	var/list/list_input = list_input_port.value

	if(!list_input)
		return

	var/list/modified_list = deep_copy_list(list_input)

	if(index > 0 && index <= modified_list.len)
		modified_list[index] = new_element_value.value

	list_output_port.set_output(modified_list)

/obj/item/circuit_component/index_setter/assoc_string
	display_name = "Set Assoc List Element By Index"
	desc = "A component that can be used to set a row from a table. Modifies data from a key, value list."

	index_type = PORT_TYPE_STRING

/obj/item/circuit_component/index_setter/assoc_string/make_list_ports()
	list_input_port = add_input_port("List", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))
	list_output_port = add_output_port("Modified List", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))

/obj/item/circuit_component/index_setter/assoc_string/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		list_input_port.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_type))
		list_output_port.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_type))
		new_element_value.set_datatype(new_type)
