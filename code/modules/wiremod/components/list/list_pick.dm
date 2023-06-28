/**
 * # List pick component
 *
 * Allows user to select 1 entry from a list
 */
/obj/item/circuit_component/list_pick
	display_name = "List Pick"
	desc = "A component that lets a user pick 1 element from a list. Returns the selected element."
	category = "List"

	/// The data type of the input_list
	var/datum/port/input/option/list_options

	/// The list that will be shown to the user
	var/datum/port/input/input_list
	/// The user to show the list too
	var/datum/port/input/user
	/// Name passed onto the TGUI(gives the UI a name)
	var/datum/port/input/input_name

	/// What was picked from input_list
	var/datum/port/output/output
	/// A value was picked
	var/datum/port/output/success
	/// Either it was canceld or out of range
	var/datum/port/output/failure

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/index_type = PORT_TYPE_NUMBER

/obj/item/circuit_component/list_pick/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/list_pick/proc/make_list_port()
	input_list = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/list_pick/populate_ports()
	input_name = add_input_port("Input Name", PORT_TYPE_STRING)
	user = add_input_port("User", PORT_TYPE_ATOM)
	make_list_port()

	output = add_output_port("Picked Item", PORT_TYPE_NUMBER)
	trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	failure = add_output_port("On Failure", PORT_TYPE_SIGNAL)
	success = add_output_port("On Succes", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/list_pick/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_type = list_options.value
		input_list.set_datatype(PORT_TYPE_LIST(new_type))
		output.set_datatype(new_type)


/obj/item/circuit_component/list_pick/input_received(datum/port/input/port)
	if(parent.Adjacent(user.value))
		return

	if(ismob(user.value))
		trigger_output.set_output(COMPONENT_SIGNAL)
		INVOKE_ASYNC(src, PROC_REF(show_list), user.value, input_name.value, input_list.value)

/// Show a list of options to the user using standed TGUI input list
/obj/item/circuit_component/list_pick/proc/show_list(mob/user, message, list/showed_list)
	if(!showed_list || showed_list.len == 0)
		failure.set_output(COMPONENT_SIGNAL)
		return
	if(!message)
		message = "circuit input"
	if(!(user.can_perform_action(src, FORBID_TELEKINESIS_REACH)))
		return
	var/picked = tgui_input_list(user, message = message, items = showed_list)
	if(!(user.can_perform_action(src, FORBID_TELEKINESIS_REACH)))
		return
	choose_item(picked, showed_list)

/obj/item/circuit_component/list_pick/proc/choose_item(choice, list/choice_list)
	if(choice)
		output.set_output(choice)
		success.set_output(COMPONENT_SIGNAL)
	else
		failure.set_output(COMPONENT_SIGNAL)



