/**
 * # To String Component
 *
 * Converts any value into a string
 */
/obj/item/circuit_component/tostring
	display_name = "To String"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	has_trigger = TRUE

	var/min_range = 5

/obj/item/circuit_component/tostring/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/tostring/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/tostring/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/input_value = input_port.input_value
	if(isatom(input_value))
		var/turf/location = get_turf(src)
		var/atom/object = input_value
		if(object.z != location.z || get_dist(location, object) > min_range)
			output.set_output(PORT_TYPE_ATOM)
			return

	output.set_output("[input_value]")
	trigger_output.set_output(COMPONENT_SIGNAL)
