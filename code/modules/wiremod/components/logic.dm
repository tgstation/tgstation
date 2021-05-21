/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/compare/logic
	display_name = "Logic"

GLOBAL_LIST_INIT(comp_logic_options, list(
	COMP_LOGIC_AND,
	COMP_LOGIC_OR
))

/obj/item/circuit_component/compare/logic/Initialize()
	options = GLOB.comp_logic_options
	return ..()

/obj/item/circuit_component/compare/logic/do_comparisons(list/ports)
	. = FALSE
	for(var/datum/port/input/port as anything in ports)
		if(isnull(port.connected_port))
			continue

		switch(current_option)
			if(COMP_LOGIC_AND)
				if(!port.input_value)
					return FALSE
				. = port.input_value
			if(COMP_LOGIC_OR)
				if(port.input_value)
					return port.input_value
