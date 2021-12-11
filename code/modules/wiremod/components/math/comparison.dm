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

	input_port_amount = 2
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

/obj/item/circuit_component/compare/comparison/pre_input_received(datum/port/input/port)
	switch(comparison_option.value)
		if(COMP_COMPARISON_EQUAL, COMP_COMPARISON_NOT_EQUAL)
			if(current_type != PORT_TYPE_ANY)
				current_type = PORT_TYPE_ANY
				compare_ports[1].set_datatype(PORT_TYPE_ANY)
				compare_ports[2].set_datatype(PORT_TYPE_ANY)
		else
			if(current_type != PORT_TYPE_NUMBER)
				current_type = PORT_TYPE_NUMBER
				compare_ports[1].set_datatype(PORT_TYPE_NUMBER)
				compare_ports[2].set_datatype(PORT_TYPE_NUMBER)


/obj/item/circuit_component/compare/comparison/do_comparisons(list/ports)
	if(length(ports) < input_port_amount)
		return FALSE

	// Comparison component only compares the first two ports
	var/input1 = compare_ports[1].value
	var/input2 = compare_ports[2].value
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
