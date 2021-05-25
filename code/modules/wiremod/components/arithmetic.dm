/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/arithmetic
	display_name = "Arithmetic"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/output

	has_trigger = TRUE

GLOBAL_LIST_INIT(comp_arithmetic_options, list(
	COMP_ARITHMETIC_ADD,
	COMP_ARITHMETIC_SUBTRACT,
	COMP_ARITHMETIC_MULTIPLY,
	COMP_ARITHMETIC_DIVIDE,
	COMP_ARITHMETIC_MIN,
	COMP_ARITHMETIC_MAX,
))

/obj/item/circuit_component/arithmetic/Initialize()
	options = GLOB.comp_arithmetic_options
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/arithmetic/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/arithmetic/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/list/ports = input_ports.Copy()
	var/datum/port/input/first_port = ports[1]
	ports -= first_port
	ports -= trigger_input
	var/result = first_port.input_value

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.input_value
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
					result = null
					break
				result /= value
			if(COMP_ARITHMETIC_MAX)
				result = max(result, value)
			if(COMP_ARITHMETIC_MIN)
				result = min(result, value)

	output.set_output(result)
	trigger_output.set_output(COMPONENT_SIGNAL)
