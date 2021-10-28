#define COMP_LOGIC_AND "AND"
#define COMP_LOGIC_OR "OR"
#define COMP_LOGIC_XOR "XOR"

/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/compare/logic
	display_name = "Logic"
	desc = "A component with 'and' and 'or' capabilities."
	category = "Math"

	var/datum/port/input/option/logic_options

/obj/item/circuit_component/compare/logic/populate_options()
	var/static/component_options = list(
		COMP_LOGIC_AND,
		COMP_LOGIC_OR,
		COMP_LOGIC_XOR,
	)
	logic_options = add_option_port("Logic Options", component_options)

/obj/item/circuit_component/compare/logic/do_comparisons(list/ports)
	. = FALSE
	var/current_option = logic_options.value

	// Used by XOR
	var/total_ports = 0
	var/total_true_ports = 0
	for(var/datum/port/input/port as anything in ports)
		if(isnull(port.value) && length(port.connected_ports) == 0)
			continue

		total_ports += 1
		switch(current_option)
			if(COMP_LOGIC_AND)
				if(!port.value)
					return FALSE
				. = TRUE
			if(COMP_LOGIC_OR)
				if(port.value)
					return TRUE
			if(COMP_LOGIC_XOR)
				if(port.value)
					. = TRUE
					total_true_ports += 1

	if(current_option == COMP_LOGIC_XOR)
		if(total_ports == total_true_ports)
			return FALSE
		if(.)
			return TRUE

#undef COMP_LOGIC_AND
#undef COMP_LOGIC_OR
#undef COMP_LOGIC_XOR
