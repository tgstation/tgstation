/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/compare/logic
	display_name = "Logic"


GLOBAL_LIST_INIT(comp_logic_options, list(
	COMP_LOGIC_AND,
	COMP_LOGIC_OR,
	COMP_LOGIC_XOR
))

/obj/item/circuit_component/compare/logic/Initialize()
	options = GLOB.comp_logic_options
	return ..()

/obj/item/circuit_component/compare/logic/do_comparisons(list/ports)
	. = FALSE
	// Used by XOR
	var/total_ports = 0
	var/total_true_ports = 0
	for(var/datum/port/input/port as anything in ports)
		if(isnull(port.input_value) && isnull(port.connected_port))
			continue

		total_ports += 1
		switch(current_option)
			if(COMP_LOGIC_AND)
				if(!port.input_value)
					return FALSE
				. = TRUE
			if(COMP_LOGIC_OR)
				if(port.input_value)
					return TRUE
			if(COMP_LOGIC_XOR)
				if(port.input_value)
					. = TRUE
					total_true_ports += 1

	if(current_option == COMP_LOGIC_XOR)
		if(total_ports == total_true_ports)
			return FALSE
		if(.)
			return TRUE
