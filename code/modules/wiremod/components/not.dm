/**
 * # Logic Component
 *
 * General logic unit with AND OR capabilities
 */
/obj/item/component/not
	display_name = "Not"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/result

/obj/item/component/not/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/component/not/Destroy()
	input_port = null
	result = null
	return ..()

/obj/item/component/not/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!isnull(input_port.input_value))
		return

	result.set_output(!input_port.input_value)
