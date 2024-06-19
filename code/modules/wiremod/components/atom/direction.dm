/**
 * # Direction Component
 *
 * Return the direction of a mob relative to the component
 */
/obj/item/circuit_component/direction
	display_name = "Get Direction"
	desc = "A component that returns the direction of itself and an entity."
	category = "Entity"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	// Directions outputs
	var/datum/port/output/north
	var/datum/port/output/south
	var/datum/port/output/east
	var/datum/port/output/west

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Maximum range for a valid direction to be returned
	var/max_range = 7

/obj/item/circuit_component/direction/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/direction/populate_ports()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	output = add_output_port("Direction", PORT_TYPE_STRING)

	north = add_output_port("North", PORT_TYPE_SIGNAL)
	east = add_output_port("East", PORT_TYPE_SIGNAL)
	south = add_output_port("South", PORT_TYPE_SIGNAL)
	west = add_output_port("West", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/direction/input_received(datum/port/input/port)

	var/atom/object = input_port.value
	if(!object)
		return
	var/turf/location = get_location()

	if(object.z != location.z || get_dist(location, object) > max_range)
		output.set_output(null)
		return

	var/direction = get_dir(location, get_turf(object))
	output.set_output(dir2text(direction))

	if(direction & NORTH)
		north.set_output(COMPONENT_SIGNAL)
	if(direction & SOUTH)
		south.set_output(COMPONENT_SIGNAL)
	if(direction & EAST)
		east.set_output(COMPONENT_SIGNAL)
	if(direction & WEST)
		west.set_output(COMPONENT_SIGNAL)
