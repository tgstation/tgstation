/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/circuit_component/not
	display_name = "Not"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/result
	has_trigger = TRUE

/obj/item/circuit_component/not/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/not/Destroy()
	input_port = null
	result = null
	return ..()

/obj/item/circuit_component/not/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	result.set_output(!input_port.input_value)
	trigger_output.set_output(COMPONENT_SIGNAL)
