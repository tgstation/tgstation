/**
 * # associative List pick component
 *
 * Allows user to select 1 entry from a list
 */

/obj/item/circuit_component/assoc_list_pick
	display_name = "Associative List Pick"
	desc = "A component that lets a user pick 1 element from a associative list. returns the selected element"
	category = "List"

	var/datum/port/input/option/list_options

	var/datum/port/input/input_list
	var/datum/port/input/user
	var/datum/port/input/input_name


	var/datum/port/output/output
	var/datum/port/output/succes
	var/datum/port/output/failure

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/index_type = PORT_TYPE_NUMBER

/obj/item/circuit_component/assoc_list_pick/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/assoc_list_pick/proc/make_list_port()
	input_list = add_input_port("List", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING,PORT_TYPE_LIST(PORT_TYPE_ANY)))

/obj/item/circuit_component/assoc_list_pick/populate_ports()
	input_name = add_input_port("Input Name", PORT_TYPE_STRING)
	user = add_input_port("User", PORT_TYPE_ATOM)
	make_list_port()

	output = add_output_port("Picked Item", PORT_TYPE_NUMBER)
	trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	failure = add_output_port("On Failure", PORT_TYPE_SIGNAL)
	succes = add_output_port("On Succes", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/assoc_list_pick/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		input_list.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING,new_type))
		output.set_datatype(new_type)


/obj/item/circuit_component/assoc_list_pick/input_received(datum/port/input/port)
	if(parent.Adjacent(user.value))
		return
	if(istype(user.value,/mob))
		trigger_output.set_output(COMPONENT_SIGNAL)
		INVOKE_ASYNC(src, PROC_REF(show_list), user.value, input_name.value, input_list.value)

/obj/item/circuit_component/assoc_list_pick/proc/show_list(mob/user, message, list/showed_list)
	if(!showed_list || showed_list.len == 0)
		failure.set_output(COMPONENT_SIGNAL)
		return
	if(!message)
		message = "circuit input"
	var/picked = tgui_input_list(user, message = message, items = showed_list)
	if(showed_list[picked])
		output.set_output(showed_list[picked])
		succes.set_output(COMPONENT_SIGNAL)
	else
		failure.set_output(COMPONENT_SIGNAL)



