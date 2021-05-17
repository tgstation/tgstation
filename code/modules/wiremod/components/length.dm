/**
 * # Length Component
 *
 * Return the length of an input
 */
/obj/item/component/length
	display_name = "Length"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

/obj/item/component/length/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	output = add_output_port("Length", PORT_TYPE_NUMBER)

/obj/item/component/length/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/component/length/input_received()
	. = ..()
	if(.)
		return

	output.set_output(length(input_port.input_value))
