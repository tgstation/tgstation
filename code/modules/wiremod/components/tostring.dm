/**
 * # To String Component
 *
 * Converts any value into a string
 */
/obj/item/component/tostring
	display_name = "To String"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

/obj/item/component/tostring/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_STRING)

	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/component/tostring/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/component/tostring/input_received()
	. = ..()
	if(.)
		return

	output.set_output("[input_port.input_value]")
