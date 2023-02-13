#define COMP_ARITHMETIC_ADD "Add"
#define COMP_ARITHMETIC_SUBTRACT "Subtract"
#define COMP_ARITHMETIC_MULTIPLY "Multiply"
#define COMP_ARITHMETIC_DIVIDE "Divide"
#define COMP_ARITHMETIC_MIN "Minimum"
#define COMP_ARITHMETIC_MAX "Maximum"

/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/arithmetic
	display_name = "Arithmetic"
	desc = "General arithmetic component with arithmetic capabilities."
	category = "Math"

	var/datum/port/input/option/arithmetic_option

	/// The result from the output
	var/datum/port/output/output

	var/list/arithmetic_ports
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL
	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

/obj/item/circuit_component/arithmetic/populate_options()
	var/static/component_options = list(
		COMP_ARITHMETIC_ADD,
		COMP_ARITHMETIC_SUBTRACT,
		COMP_ARITHMETIC_MULTIPLY,
		COMP_ARITHMETIC_DIVIDE,
		COMP_ARITHMETIC_MIN,
		COMP_ARITHMETIC_MAX,
	)
	arithmetic_option = add_option_port("Arithmetic Option", component_options)

/obj/item/circuit_component/arithmetic/populate_ports()
	arithmetic_ports = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = arithmetic_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Port", \
		minimum_amount = 2 \
	)
	output = add_output_port("Output", PORT_TYPE_NUMBER, order = 1.1)

/obj/item/circuit_component/arithmetic/input_received(datum/port/input/port)

	var/list/ports = arithmetic_ports.Copy()
	var/datum/port/input/first_port = popleft(ports)
	var/result = first_port.value

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.value
		if(isnull(value))
			continue

		switch(arithmetic_option.value)
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

#undef COMP_ARITHMETIC_ADD
#undef COMP_ARITHMETIC_SUBTRACT
#undef COMP_ARITHMETIC_MULTIPLY
#undef COMP_ARITHMETIC_DIVIDE
#undef COMP_ARITHMETIC_MIN
#undef COMP_ARITHMETIC_MAX
