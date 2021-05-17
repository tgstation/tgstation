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

/obj/item/component/typecheck/Destroy()
	true = null
	false = null
	return ..()

/obj/item/component/typecheck/input_received()
	. = ..()
	if(.)
		return

	var/result = FALSE
	var/input_val = input_port.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			result = istext(input_val)
		if(PORT_TYPE_NUMBER)
			result = isnum(input_val)
		if(PORT_TYPE_LIST)
			result = islist(input_val)
		if(PORT_TYPE_ATOM)
			result = isatom(input_val)
		if(PORT_TYPE_MOB)
			result = ismob(input_val)
		if(PORT_TYPE_HUMAN)
			result = ishuman(input_val)

	// Sends an output to the appropriate port
	if(result)
		true.set_output(result)
	else
		false.set_output(result)
