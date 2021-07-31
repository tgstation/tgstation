/**
 * # GPS Component
 *
 * Return the location of input
 */
/obj/item/circuit_component/gps
	display_name = "Internal GPS"
	display_desc = "A component that returns the xyz co-ordinates of itself if its input port is empty, and of the input if it is not. Target has to be within the line of sight of the shell."

	var/datum/port/input/entity

	/// The result from the output
	var/datum/port/output/x_pos
	var/datum/port/output/y_pos
	var/datum/port/output/z_pos

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/gps/Initialize()
	. = ..()

	entity = add_input_port("Entity", PORT_TYPE_ATOM)

	x_pos = add_output_port("X", PORT_TYPE_NUMBER)
	y_pos = add_output_port("Y", PORT_TYPE_NUMBER)
	z_pos = add_output_port("Z", PORT_TYPE_NUMBER)

/obj/item/circuit_component/gps/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/turf/location

	if(!isnull(entity.input_value))
		if(isInSight(entity.input_value, parent.shell))
			location = get_turf(entity.input_value)
		else
			location = null
	else
		location = get_turf(src)

	x_pos.set_output(location?.x)
	y_pos.set_output(location?.y)
	z_pos.set_output(location?.z)

