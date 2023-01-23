/**
 * # associative List pick component
 *
 * Allows user to select 1 entry from a list
 * For actuel code refer to code\modules\wiremod\components\list\list_pick.dm
 */
/obj/item/circuit_component/list_pick/assoc
	display_name = "Associative List Pick"
	desc = "A component that lets a user pick 1 element from an associative list. Returns the selected element."
	category = "List"

/obj/item/circuit_component/list_pick/assoc/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/list_pick/assoc/make_list_port()
	input_list = add_input_port("List", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))


/obj/item/circuit_component/list_pick/assoc/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		input_list.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, new_type))
		output.set_datatype(new_type)

/obj/item/circuit_component/list_pick/assoc/choose_item(choice, list/choice_list)
	if(choice_list[choice])
		output.set_output(choice_list[choice])
		success.set_output(COMPONENT_SIGNAL)
	else
		failure.set_output(COMPONENT_SIGNAL)

