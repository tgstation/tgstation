#define COMP_INPUT_STRING "string"
#define COMP_INPUT_NUMBER "number"
#define COMP_INPUT_LIST "list"

/**
 * # Input Request Component
 *
 * Requests an input from someone.
 */
/obj/item/circuit_component/input_request
	display_name = "Input Request"
	desc = "Converts a string into a typepath. Useful for adding components."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// Options for input requests
	var/datum/port/input/option/input_options

	/// The input path to convert into a typepath
	var/datum/port/input/entity

	/// The custom parameter of the option
	var/datum/port/input/parameter

	/// The response from the player
	var/datum/port/output/input_response

	/// Triggered when the input is received
	var/datum/port/output/input_triggered

	/// Triggered when the player fails to give an input.
	var/datum/port/output/input_failed

/obj/item/circuit_component/input_request/populate_options()
	var/static/list/component_options = list(
		COMP_INPUT_STRING,
		COMP_INPUT_NUMBER,
		COMP_INPUT_LIST
	)

	input_options = add_option_port("Option", component_options)

/obj/item/circuit_component/input_request/populate_ports()
	entity = add_input_port("Entity", PORT_TYPE_ATOM)
	input_response = add_output_port("Response", PORT_TYPE_ANY)
	input_triggered = add_output_port("Input Sent", PORT_TYPE_SIGNAL)
	input_failed = add_output_port("Input Failed", PORT_TYPE_SIGNAL)

	update_options()

/obj/item/circuit_component/input_request/input_received(datum/port/input/port)
	var/mob/player = entity.value
	if(!istype(player))
		return

	INVOKE_ASYNC(src, .proc/request_input_from_player, player)

/obj/item/circuit_component/input_request/proc/request_input_from_player(mob/player)
	var/new_option = input_options.value
	switch(new_option)
		if(COMP_INPUT_STRING)
			var/player_input = tgui_input_text(player, "Input a value", "Input value")
			if(isnull(player_input))
				return
			input_response.set_output(player_input)
		if(COMP_INPUT_NUMBER)
			var/player_input = tgui_input_number(player, "Input a value", "Input value")
			if(isnull(player_input))
				return
			input_response.set_output(player_input)
		if(COMP_INPUT_LIST)
			var/list/data = parameter.value
			if(!islist(data))
				return
			var/player_input = tgui_input_list(player, "Input a value", "Input value", data)
			if(isnull(player_input))
				return
			input_response.set_output(player_input)
	input_triggered.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/input_request/pre_input_received(datum/port/input/port)
	if(port == input_options)
		update_options(port)

/obj/item/circuit_component/input_request/proc/update_options(datum/port/input/port)
	var/new_option = input_options.value
	if(parameter)
		remove_input_port(parameter)
		parameter = null

	switch(new_option)
		if(COMP_INPUT_STRING)
			input_response.set_datatype(PORT_TYPE_STRING)
		if(COMP_INPUT_NUMBER)
			input_response.set_datatype(PORT_TYPE_NUMBER)
		if(COMP_INPUT_LIST)
			parameter = add_input_port("Options List", PORT_TYPE_LIST(PORT_TYPE_ANY))
			input_response.set_datatype(PORT_TYPE_STRING)

#undef COMP_INPUT_STRING
#undef COMP_INPUT_NUMBER
#undef COMP_INPUT_LIST
