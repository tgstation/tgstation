/**
 * # Typecast Component
 *
 * A component that casts a value to a type if it matches or outputs null.
 */
/obj/item/circuit_component/typecast
	display_name = "Typecast"
	desc = "A component that casts a value to a type if it matches or outputs null."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_value

	var/datum/port/output/output_value

	var/current_type

/obj/item/circuit_component/typecast/Initialize()
	. = ..()
	current_type = current_option
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
	if(current_type != current_option)
		current_type = current_option
		output_value.set_datatype(current_type)

	if(.)
		return

	var/value = input_value.input_value
	var/value_to_set = null
	switch(current_option)
		if(PORT_TYPE_STRING)
			if(istext(value))
				value_to_set = value
		if(PORT_TYPE_NUMBER)
			if(isnum(value))
				value_to_set = value
		if(PORT_TYPE_LIST)
			if(islist(value))
				value_to_set = value
		if(PORT_TYPE_ATOM)
			if(isatom(value))
				value_to_set = value

	output_value.set_output(value_to_set)
