/**
 * # Length Component
 *
 * Return the length of an input
 */
/obj/item/circuit_component/length
	display_name = "Length"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output
	has_trigger = TRUE

/obj/item/circuit_component/length/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	output = add_output_port("Length", PORT_TYPE_NUMBER)

/obj/item/circuit_component/length/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/length/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	output.set_output(length(input_port.input_value))
	trigger_output.set_output(COMPONENT_SIGNAL)
