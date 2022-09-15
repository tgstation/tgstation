/**
 * # GPS Component
 *
 * Return the location of this
 */
/obj/item/circuit_component/gps
	display_name = "Internal GPS"
	desc = "A component that returns the xyz co-ordinates of itself."
	category = "Entity"

	/// The result from the output
	var/datum/port/output/x_pos
	var/datum/port/output/y_pos
	var/datum/port/output/z_pos

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/gps/populate_ports()
	x_pos = add_output_port("X", PORT_TYPE_NUMBER)
	y_pos = add_output_port("Y", PORT_TYPE_NUMBER)
	z_pos = add_output_port("Z", PORT_TYPE_NUMBER)

/obj/item/circuit_component/gps/input_received(datum/port/input/port)

	var/turf/location = get_location()

	x_pos.set_output(location?.x)
	y_pos.set_output(location?.y)
	z_pos.set_output(location?.z)

