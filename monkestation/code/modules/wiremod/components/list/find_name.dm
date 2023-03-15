/**
 * # Find By Name Component
 *
 * A component that returns an entity from a list by its name.
 */
/obj/item/circuit_component/find_name
	display_name = "Find Entity By Name"
	display_desc = "A component that returns an entity from a list by its name."

	//The list of mobs to look through
	var/datum/port/input/input_list
	//The name of the mob to look for
	var/datum/port/input/target_name

	//The target from the list
	var/datum/port/output/target
	//If we find the target
	var/datum/port/output/passed
	//If we fail to find the target
	var/datum/port/output/failed

	COOLDOWN_DECLARE(find_cooldown)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

/obj/item/circuit_component/find_name/get_ui_notices()
	. = ..()
	//More like 1.8 seconds if youre using the 'clock' component because that one has a 0.9 sec cd
	. += create_ui_notice("Viewer Cooldown: [DisplayTimeText(1 SECONDS)]", "orange", "stopwatch")

/obj/item/circuit_component/find_name/Initialize(mapload)
	. = ..()

	input_list = add_input_port("List", PORT_TYPE_LIST)
	target_name = add_input_port("Target Name", PORT_TYPE_STRING)

	target = add_output_port("Target", PORT_TYPE_ATOM)
	passed = add_output_port("Passed", PORT_TYPE_SIGNAL)
	failed = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/find_name/Destroy()
	input_list = null
	target_name = null
	target = null
	passed = null
	failed = null
	return ..()

/obj/item/circuit_component/find_name/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COOLDOWN_FINISHED(src, find_cooldown))
		return

	if(length(input_list.input_value) < 1)
		failed.set_output(COMPONENT_SIGNAL)
		return

	COOLDOWN_START(src, find_cooldown, 1 SECONDS)

	for(var/atom/i in input_list.input_value)
		if(i.name == target_name.input_value)
			target.set_output(i)
			passed.set_output(COMPONENT_SIGNAL)
			return

	failed.set_output(COMPONENT_SIGNAL)


