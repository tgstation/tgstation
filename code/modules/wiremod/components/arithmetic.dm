/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/component/arithmetic
	display_name = "Arithmetic"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/output

GLOBAL_LIST_INIT(comp_arithmetic_options, list(
	COMP_ARITHMETIC_ADD,
	COMP_ARITHMETIC_SUBTRACT,
	COMP_ARITHMETIC_MULTIPLY,
	COMP_ARITHMETIC_DIVIDE
))

/obj/item/component/arithmetic/Initialize()
	options = GLOB.comp_arithmetic_options
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + port_id)
		add_input_port(letter, PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/component/arithmetic/Destroy()
	output = null
	return ..()

/obj/item/component/arithmetic/input_received()
	. = ..()
	if(.)
		return

	// If the current_option is equal to COMP_LOGIC_AND, start with result set to TRUE
	// Otherwise, set result to FALSE.
	var/result = 0
	var/list/ports = input_ports.Copy()
	if(current_option == COMP_ARITHMETIC_DIVIDE || current_option == COMP_ARITHMETIC_SUBTRACT)
		var/datum/port/input/first_port = ports[1]
		ports -= first_port
		result = first_port.input_value

	for(var/datum/port/input/port as anything in ports)
		var/value = port.input_value
		if(isnull(value))
			continue

		switch(current_option)
			if(COMP_ARITHMETIC_ADD)
				result += value
			if(COMP_ARITHMETIC_SUBTRACT)
				result -= value
			if(COMP_ARITHMETIC_MULTIPLY)
				result *= value
			if(COMP_ARITHMETIC_DIVIDE)
				// Protect from div by zero errors.
				if(value == 0)
					result = 0
					break
				result /= value

	output.set_output(result)
