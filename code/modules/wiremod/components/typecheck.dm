/**
 * # Typecheck Component
 *
 * Checks the type of a value
 */
/obj/item/circuit_component/compare/typecheck
	display_name = "Typecheck"

	input_port_amount = 1

	has_trigger = TRUE


GLOBAL_LIST_INIT(comp_typecheck_options, list(
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_LIST,
	PORT_TYPE_ATOM,
	COMP_TYPECHECK_MOB,
	COMP_TYPECHECK_HUMAN,
))

/obj/item/circuit_component/compare/typecheck/Initialize()
	options = GLOB.comp_typecheck_options
	return ..()

/obj/item/circuit_component/compare/typecheck/do_comparisons(list/ports)
	if(!length(ports))
		return
	. = FALSE

	// We're only comparing the first port/value. There shouldn't be any more.
	var/datum/port/input/input_port = ports[1]
	var/input_val = input_port.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			return istext(input_val)
		if(PORT_TYPE_NUMBER)
			return isnum(input_val)
		if(PORT_TYPE_LIST)
			return islist(input_val)
		if(PORT_TYPE_ATOM)
			return isatom(input_val)
		if(COMP_TYPECHECK_MOB)
			return ismob(input_val)
		if(COMP_TYPECHECK_HUMAN)
			return ishuman(input_val)
	trigger_output.set_output(COMPONENT_SIGNAL)
