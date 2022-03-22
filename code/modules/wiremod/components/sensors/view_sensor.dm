/**
 * # View Sensor
 *
 * Returns all movable objects in view.
 */

#define VIEW_SENSOR_RANGE 5
#define VIEW_SENSOR_COOLDOWN 0.5 SECONDS

/obj/item/circuit_component/view_sensor
	display_name = "View Sensor"
	desc = "Outputs a list with all movable objects in it's view. Requires a shell."
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	power_usage_per_input = 5 //Normal components have 1

	/// The result from the output
	var/datum/port/output/result

/obj/item/circuit_component/view_sensor/populate_ports()
	result = add_output_port("Result", PORT_TYPE_LIST(PORT_TYPE_ATOM))

/obj/item/circuit_component/view_sensor/input_received(datum/port/input/port)
	if(world.time < use_cooldown)
		result.set_output(null)
		return

	if(!parent || !parent.shell)
		result.set_output(null)
		return

	if(!isturf(parent.shell.loc))
		if(isliving(parent.shell.loc))
			var/mob/living/owner = parent.shell.loc
			if(parent.shell != owner.get_active_held_item() && parent.shell != owner.get_inactive_held_item())
				result.set_output(null)
				return
		else
			result.set_output(null)
			return

	var/object_list = list()

	for(var/atom/movable/target in view(5, get_turf(parent.shell)))
		if(target.invisibility > SEE_INVISIBLE_LIVING)
			continue

		object_list += target

	result.set_output(object_list)
	use_cooldown = world.time + VIEW_SENSOR_COOLDOWN

#undef VIEW_SENSOR_RANGE
#undef VIEW_SENSOR_COOLDOWN
