/**
 * # Text Component
 *
 * Either makes the text upper case or lower case.
 */
/obj/item/circuit_component/textcase
	display_name = "Text Case"
	display_desc = "A component that makes its input uppercase or lowercase."

	/// The input port
	var/datum/port/input/input_port

	/// The result of the text operation
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/textcase/populate_options()
	var/static/component_options = list(
		COMP_TEXT_LOWER,
		COMP_TEXT_UPPER,
	)
	options = component_options

/obj/item/circuit_component/textcase/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_STRING)
	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/textcase/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/textcase/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/value = input_port.input_value
	if(isnull(value))
		return

	var/result
	switch(current_option)
		if(COMP_TEXT_LOWER)
			result = lowertext(value)
		if(COMP_TEXT_UPPER)
			result = uppertext(value)

	output.set_output(result)

