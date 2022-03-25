/**
 * # View Sensor
 *
 * Returns all movable objects in view.
 */

#define VIEW_SENSOR_RANGE 5

/obj/item/circuit_component/view_sensor
	display_name = "View Sensor"
	desc = "Outputs a list with all movable objects in it's view. Requires a shell."
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	power_usage_per_input = 10 //Normal components have 1

	/// The result from the output
	var/datum/port/output/result
	var/datum/port/output/cooldown

	var/see_invisible = SEE_INVISIBLE_LIVING
	var/view_cooldown = 1 SECONDS

/obj/item/circuit_component/view_sensor/populate_ports()
	result = add_output_port("Result", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	cooldown = add_output_port("Scan On Cooldown", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/view_sensor/get_ui_notices()
	. = ..()
	. += create_ui_notice("Scan Cooldown: [DisplayTimeText(view_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/view_sensor/input_received(datum/port/input/port)
	if(TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_VIEW_SENSOR))
		result.set_output(null)
		cooldown.set_output(COMPONENT_SIGNAL)
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
		if(target.invisibility > see_invisible)
			continue

		object_list += target

	result.set_output(object_list)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_VIEW_SENSOR, view_cooldown)

#undef VIEW_SENSOR_RANGE
