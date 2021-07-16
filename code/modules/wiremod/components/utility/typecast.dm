/**
 * # Typecheck Component
 *
 * Checks the type of a value
 */
/obj/item/circuit_component/typecast
	display_name = "Typecheck"
	display_desc = "A component that checks the type of its input."

	var/datum/port/input/input_value


	var/datum/port/output/output_value

/obj/item/circuit_component/typecast/Initialize()
	. = ..()
	input_value = add_input_port("Input", PORT_TYPE_ANY)
	output_value = add_output_port("Output", current_option)

/obj/item/circuit_component/typecast/populate_options()
	var/static/component_options = list(
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
	)
	options = component_options

/obj/item/circuit_component/typecast/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/value = input_value.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			if(istext(value))

