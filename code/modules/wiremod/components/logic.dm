/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/component/logic
	display_name = "Logic"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/true
	var/datum/port/output/false

GLOBAL_LIST_INIT(comp_logic_options, list(
	COMP_LOGIC_AND,
	COMP_LOGIC_OR
))

/obj/item/component/logic/Initialize()
	options = GLOB.comp_logic_options
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + port_id)
		add_input_port(letter, PORT_TYPE_ANY)

	true = add_output_port("True", PORT_TYPE_NUMBER)
	false = add_output_port("False", PORT_TYPE_NUMBER)

/obj/item/component/logic/Destroy()
	true = null
	false = null
	return ..()

/obj/item/component/logic/input_received()
	. = ..()
	if(.)
		return

	// If the current_option is equal to COMP_LOGIC_AND, start with result set to TRUE
	// Otherwise, set result to FALSE.
	var/result = current_option == COMP_LOGIC_AND
	for(var/datum/port/input/port as anything in input_ports)
		if(isnull(port.connected_port))
			continue

		switch(current_option)
			if(COMP_LOGIC_AND)
				if(!port.input_value)
					result = FALSE
					break
			if(COMP_LOGIC_OR)
				if(port.input_value)
					result = TRUE
					break

	if(result)
		true.set_output(result)
	else
		false.set_output(result)
