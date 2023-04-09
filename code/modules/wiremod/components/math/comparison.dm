/**
 * # Comparison Component
 *
 * Compares two objects
 */
/obj/item/circuit_component/compare/comparison
	display_name = "Comparison"
	desc = "A component that compares two objects."
	category = "Math"

	var/datum/port/input/option/comparison_option

	/// First value to compare with the second value
	var/datum/port/input/first_port
	/// Second value to compare with the first value
	var/datum/port/input/second_port

	var/current_type = PORT_TYPE_ANY

/obj/item/circuit_component/compare/comparison/populate_options()
	var/static/component_options = list(
		COMP_COMPARISON_EQUAL,
		COMP_COMPARISON_NOT_EQUAL,
		COMP_COMPARISON_GREATER_THAN,
		COMP_COMPARISON_LESS_THAN,
		COMP_COMPARISON_GREATER_THAN_OR_EQUAL,
		COMP_COMPARISON_LESS_THAN_OR_EQUAL,
	)
	comparison_option = add_option_port("Comparison Option", component_options)

/obj/item/circuit_component/compare/comparison/populate_custom_ports()
	first_port = add_input_port("A", PORT_TYPE_ANY)
	second_port = add_input_port("B", PORT_TYPE_ANY)

/obj/item/circuit_component/compare/comparison/pre_input_received(datum/port/input/port)
	switch(comparison_option.value)
		if(COMP_COMPARISON_EQUAL, COMP_COMPARISON_NOT_EQUAL)
			if(current_type != PORT_TYPE_ANY)
				current_type = PORT_TYPE_ANY
				first_port.set_datatype(PORT_TYPE_ANY)
				second_port.set_datatype(PORT_TYPE_ANY)
		else
			if(current_type != PORT_TYPE_NUMBER)
				current_type = PORT_TYPE_NUMBER
				first_port.set_datatype(PORT_TYPE_NUMBER)
				second_port.set_datatype(PORT_TYPE_NUMBER)


/obj/item/circuit_component/compare/comparison/do_comparisons()
	var/input1 = first_port.value
	var/input2 = second_port.value
	var/current_option = comparison_option.value

	switch(current_option)
		if(COMP_COMPARISON_EQUAL)
			return input1 == input2
		if(COMP_COMPARISON_NOT_EQUAL)
			return input1 != input2
		if(COMP_COMPARISON_GREATER_THAN)
			return input1 > input2
		if(COMP_COMPARISON_GREATER_THAN_OR_EQUAL)
			return input1 >= input2
		if(COMP_COMPARISON_LESS_THAN)
			return input1 < input2
		if(COMP_COMPARISON_LESS_THAN_OR_EQUAL)
			return input1 <= input2
