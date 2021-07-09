/**
 * # Pathfinding component
 *
 * Calcualtes a path, returns a list of entities. Each entity is the next step in the path. Can be used with the direction component to move.
 */
/obj/item/circuit_component/pathfind
	display_name = "Pathfinder"
	display_desc = "Calculates a path, returns a list of entities. Each entity is the next step in the path. Can be used with the direction component to move."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/target_X
	var/datum/port/input/target_Y

	var/datum/port/output/output
	var/datum/port/output/on_fail

/obj/item/circuit_component/pathfind/Initialize()
	. = ..()
	target_X = add_input_port("X", PORT_TYPE_NUMBER, FALSE)
	target_Y = add_input_port("Y", PORT_TYPE_NUMBER, FALSE)

	output = add_output_port("Output", PORT_TYPE_LIST)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/pathfind/Destroy()
	target_X = null
	target_Y = null
	output = null
	on_fail = null
	return ..()

/obj/item/circuit_component/pathfind/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(isnull(target_X))
		return

	if(isnull(target_Y))
		return

	var/turf/currentpos = get_turf(src)
	var/turf/destination = locate(target_X, target_Y, currentpos?.z)
	var/list/path = get_path_to(src, destination)
	output.set_output(path)
	if(!path)
		on_fail.set_output(COMPONENT_SIGNAL)
		return
	else
		output.set_output(path)
