#define COMP_TRIGONOMETRIC_SINE "Sine"
#define COMP_TRIGONOMETRIC_COSINE "Cosine"
#define COMP_TRIGONOMETRIC_TANGENT "Tangent"
#define COMP_TRIGONOMETRIC_ARCSINE "Arcsine"
#define COMP_TRIGONOMETRIC_ARCCOSINE "Arccosine"
#define COMP_TRIGONOMETRIC_ARCTANGENT "Arctangent"


/**
 * # Trigonometric Component
 *
 * General trigonometric unit with sine, cosine, tangent and their inverse functions.
 * This one only works with numbers.
 */
/obj/item/circuit_component/trigonometric
	display_name = "Arithmetic"
	desc = "General trigonometric component with main and inverse trigonometric functions."

	var/datum/port/input/option/trigonometric_function

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/trigonometric/populate_options()
	var/static/component_functions = list(
		COMP_TRIGONOMETRIC_SINE,
		COMP_TRIGONOMETRIC_COSINE,
		COMP_TRIGONOMETRIC_TANGENT,
		COMP_TRIGONOMETRIC_ARCSINE,
		COMP_TRIGONOMETRIC_ARCCOSINE,
		COMP_TRIGONOMETRIC_ARCTANGENT,
	)
	trigonometric_function = add_option_port("Trigonometric Function", component_functions)

/obj/item/circuit_component/trigonometric/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_NUMBER)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/trigonometric/input_received(datum/port/input/port)

	var/result = input_port.value

	switch(trigonometric_function.value)
		if(COMP_TRIGONOMETRIC_SINE)
			result = sin(result)
		if(COMP_TRIGONOMETRIC_COSINE)
			result = cos(result)
		if(COMP_TRIGONOMETRIC_TANGENT)
			result = tan(result)
		if(COMP_TRIGONOMETRIC_ARCSINE)
			result = arcsin(result)
		if(COMP_TRIGONOMETRIC_ARCCOSINE)
			result = arccos(result)
		if(COMP_TRIGONOMETRIC_ARCTANGENT)
			result = arctan(result)

	output.set_output(result)

#undef COMP_TRIGONOMETRIC_SINE
#undef COMP_TRIGONOMETRIC_COSINE
#undef COMP_TRIGONOMETRIC_TANGENT
#undef COMP_TRIGONOMETRIC_ARCSINE
#undef COMP_TRIGONOMETRIC_ARCCOSINE
#undef COMP_TRIGONOMETRIC_ARCTANGENT
