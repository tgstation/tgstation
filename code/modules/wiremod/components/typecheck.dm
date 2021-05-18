/**
 * # Typecheck Component
 *
 * Checks the type of a value
 */
/obj/item/component/typecheck
	display_name = "Typecheck"

	/// First object to compare
	var/datum/port/input/input_port

	/// Result of the comparison.
	var/datum/port/output/true
	var/datum/port/output/false
	var/datum/port/output/result

GLOBAL_LIST_INIT(comp_typecheck_options, list(
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_LIST,
	PORT_TYPE_MOB,
))

/obj/item/component/typecheck/Initialize()
	options = GLOB.comp_typecheck_options
	. = ..()
	input_port = add_input_port("Value", PORT_TYPE_ANY)

	true = add_output_port("True", PORT_TYPE_NUMBER)
	false = add_output_port("False", PORT_TYPE_NUMBER)
	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/component/typecheck/Destroy()
	true = null
	false = null
	input_port = null
	return ..()

/obj/item/component/typecheck/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/logic_result = FALSE
	var/input_val = input_port.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			logic_result = istext(input_val)
		if(PORT_TYPE_NUMBER)
			logic_result = isnum(input_val)
		if(PORT_TYPE_LIST)
			logic_result = islist(input_val)
		if(PORT_TYPE_ATOM)
			logic_result = isatom(input_val)
		if(PORT_TYPE_MOB)
			logic_result = ismob(input_val)
		if(PORT_TYPE_HUMAN)
			logic_result = ishuman(input_val)

	// Sends an output to the appropriate port
	if(logic_result)
		true.set_output(COMPONENT_SIGNAL)
	else
		false.set_output(COMPONENT_SIGNAL)
	result.set_output(logic_result)
