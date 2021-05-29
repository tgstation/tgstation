/**
 * # Direction Component
 *
 * Return the direction of a mob relative to the component
 */
/obj/item/circuit_component/direction
	display_name = "Get Direction"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	// Directions outputs
	var/datum/port/output/north
	var/datum/port/output/south
	var/datum/port/output/east
	var/datum/port/output/west

	has_trigger = TRUE

	/// Minimum range for a valid direction to be returned
	var/min_range = 7

/obj/item/circuit_component/direction/Initialize()
	. = ..()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	output = add_output_port("Direction", PORT_TYPE_STRING)

	north = add_output_port("North", PORT_TYPE_SIGNAL)
	south = add_output_port("South", PORT_TYPE_SIGNAL)
	east = add_output_port("East", PORT_TYPE_SIGNAL)
	west = add_output_port("West", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/direction/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/direction/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/atom/object = input_port.input_value
	if(!object)
		return
	var/turf/location = get_turf(src)

	if(object.z != location.z || get_dist(location, object) > min_range)
		output.set_output(null)
		return

	output.set_output(dir2text(get_dir(location, get_turf(object))))
	north.set_output(COMPONENT_SIGNAL)
	south.set_output(COMPONENT_SIGNAL)
	east.set_output(COMPONENT_SIGNAL)
	west.set_output(COMPONENT_SIGNAL)
