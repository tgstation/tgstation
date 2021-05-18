/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/component/compare/logic
	display_name = "Logic"

GLOBAL_LIST_INIT(comp_logic_options, list(
	COMP_LOGIC_AND,
	COMP_LOGIC_OR
))

/obj/item/component/compare/logic/Initialize()
	options = GLOB.comp_logic_options
	return ..()

/obj/item/component/compare/logic/do_comparisons(list/ports)
	// If the current_option is equal to COMP_LOGIC_AND, start with return value set to TRUE
	// Otherwise, set return value to FALSE.
	. = current_option == COMP_LOGIC_AND
	for(var/datum/port/input/port as anything in ports)
		if(isnull(port.connected_port))
			continue

		switch(current_option)
			if(COMP_LOGIC_AND)
				if(!port.input_value)
					return FALSE
			if(COMP_LOGIC_OR)
				if(port.input_value)
					return TRUE

