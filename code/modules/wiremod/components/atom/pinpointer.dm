/**
 * # Proximity Pinpointer Component
 *
 * Return the location of its input.
 */
/obj/item/circuit_component/pinpointer
	display_name = "Proximity Pinpointer"
	desc = "A component that returns the xyz co-ordinates of its entity input, as long as its in view."
	category = "Entity"

	var/datum/port/input/target

	var/datum/port/output/x_pos
	var/datum/port/output/y_pos
	var/datum/port/output/z_pos
	var/datum/port/output/on_error

	var/max_range = 7

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/pinpointer/populate_ports()
	target = add_input_port("Target entity", PORT_TYPE_ATOM, FALSE)

	x_pos = add_output_port("X", PORT_TYPE_NUMBER)
	y_pos = add_output_port("Y", PORT_TYPE_NUMBER)
	z_pos = add_output_port("Z", PORT_TYPE_NUMBER)
	on_error = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/pinpointer/input_received(datum/port/input/port)

	if(isnull(target.value))
		x_pos.set_output(null)
		y_pos.set_output(null)
		z_pos.set_output(null)
		on_error.set_output(COMPONENT_SIGNAL)
		return

	var/atom/target_entity = target.value

	if(is_in_sight(target_entity, get_location()) && IN_GIVEN_RANGE(get_location(), target_entity, max_range))
		var/turf/location = get_turf(target_entity)

		x_pos.set_output(location?.x)
		y_pos.set_output(location?.y)
		z_pos.set_output(location?.z)
	else
		x_pos.set_output(null)
		y_pos.set_output(null)
		z_pos.set_output(null)
		on_error.set_output(COMPONENT_SIGNAL)
		return TRUE


