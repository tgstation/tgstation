#define COMP_TRIGONOMETRY_SINE "Sine"
#define COMP_TRIGONOMETRY_COSINE "Cosine"
#define COMP_TRIGONOMETRY_TANGENT "Tangent"
#define COMP_TRIGONOMETRY_ARCSINE "Arcsine"
#define COMP_TRIGONOMETRY_ARCCOSINE "Arccosine"
#define COMP_TRIGONOMETRY_ARCTANGENT "Arctangent"


/**
 * # Trigonometric Component
 *
 * General trigonometric unit with sine, cosine, tangent and their inverse functions.
 * This one only works with numbers.
 */
/obj/item/circuit_component/trigonometry
	display_name = "Trigonometry"
	desc = "General trigonometry component with main and inverse trigonometry functions."
	category = "Math"

	var/datum/port/input/option/trigonometric_function

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/trigonometry/populate_options()
	var/static/component_functions = list(
		COMP_TRIGONOMETRY_SINE,
		COMP_TRIGONOMETRY_COSINE,
		COMP_TRIGONOMETRY_TANGENT,
		COMP_TRIGONOMETRY_ARCSINE,
		COMP_TRIGONOMETRY_ARCCOSINE,
		COMP_TRIGONOMETRY_ARCTANGENT,
	)
	trigonometric_function = add_option_port("Trigonometric Function", component_functions)

/obj/item/circuit_component/trigonometry/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_NUMBER)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/trigonometry/input_received(datum/port/input/port)

	var/result = input_port.value

	switch(trigonometric_function.value)
		if(COMP_TRIGONOMETRY_SINE)
			result = sin(result)
		if(COMP_TRIGONOMETRY_COSINE)
			result = cos(result)
		if(COMP_TRIGONOMETRY_TANGENT)
			result = tan(result)
		if(COMP_TRIGONOMETRY_ARCSINE)
			result = arcsin(result)
		if(COMP_TRIGONOMETRY_ARCCOSINE)
			result = arccos(result)
		if(COMP_TRIGONOMETRY_ARCTANGENT)
			result = arctan(result)

	output.set_output(result)

#undef COMP_TRIGONOMETRY_SINE
#undef COMP_TRIGONOMETRY_COSINE
#undef COMP_TRIGONOMETRY_TANGENT
#undef COMP_TRIGONOMETRY_ARCSINE
#undef COMP_TRIGONOMETRY_ARCCOSINE
#undef COMP_TRIGONOMETRY_ARCTANGENT
