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

/obj/item/circuit_component/list_pick/proc/make_list_port()
	input_list = add_input_port("List", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/list_pick/populate_ports()
	input_name = add_input_port("Input Name", PORT_TYPE_STRING)
	user = add_input_port("User", PORT_TYPE_USER)
	make_list_port()

	output = add_output_port("Picked Item", PORT_TYPE_STRING)
	failure = add_output_port("On Failure", PORT_TYPE_SIGNAL)
	success = add_output_port("On Success", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/list_pick/input_received(datum/port/input/port)
	var/mob/mob_user = user.value
	if(!ismob(mob_user) || HAS_TRAIT_FROM(parent, TRAIT_CIRCUIT_UI_OPEN, REF(mob_user)))
		failure.set_output(COMPONENT_SIGNAL)
		return
	INVOKE_ASYNC(src, PROC_REF(show_list), mob_user, input_name.value, input_list.value)

/// Show a list of options to the user using standed TGUI input list
/obj/item/circuit_component/list_pick/proc/show_list(mob/user, message, list/showed_list)
	if(!showed_list || showed_list.len == 0)
		failure.set_output(COMPONENT_SIGNAL)
		return
	if(!message)
		message = "circuit input"
	if(!(user.can_perform_action(parent.shell, FORBID_TELEKINESIS_REACH|ALLOW_SILICON_REACH|ALLOW_RESTING)))
		failure.set_output(COMPONENT_SIGNAL)
		return
	var/user_ref = REF(user)
	ADD_TRAIT(parent, TRAIT_CIRCUIT_UI_OPEN, user_ref)
	var/picked = tgui_input_list(user, message = message, items = showed_list)
	REMOVE_TRAIT(parent, TRAIT_CIRCUIT_UI_OPEN, user_ref)
	if(QDELETED(src))
		return
	if(!(user.can_perform_action(parent.shell, FORBID_TELEKINESIS_REACH|ALLOW_SILICON_REACH|ALLOW_RESTING)))
		failure.set_output(COMPONENT_SIGNAL)
		return
	choose_item(picked, showed_list)

/obj/item/circuit_component/list_pick/proc/choose_item(choice, list/choice_list)
	if(choice)
		output.set_output(choice)
		success.set_output(COMPONENT_SIGNAL)
	else
		failure.set_output(COMPONENT_SIGNAL)



