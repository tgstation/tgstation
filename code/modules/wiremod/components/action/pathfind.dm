/**
 * # Pathfinding component
 *
 * Calcualtes a path, returns a list of entities. Each entity is the next step in the path. Can be used with the direction component to move.
 */
/obj/item/circuit_component/pathfind
	display_name = "Pathfinder"
	desc = "When triggered, the next step to the target's location as an entity. This can be used with the direction component and the drone shell to make it move on its own. The Id Card input port is for considering ID access when pathing, it does not give the shell actual access."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/input_X
	var/datum/port/input/input_Y
	var/datum/port/input/id_card

	var/datum/port/output/output
	var/datum/port/output/finished
	var/datum/port/output/failed
	var/datum/port/output/reason_failed

	var/list/path
	var/turf/old_dest
	var/turf/next_turf

	// Cooldown to limit how frequently we can path to the same location.
	var/same_path_cooldown = 5 SECONDS
	var/different_path_cooldown = 30 SECONDS

	var/max_range = 60

/obj/item/circuit_component/pathfind/get_ui_notices()
	. = ..()
	// Not necessary to show the same path cooldown, since it doesn't change much for the player
	. += create_ui_notice("Pathfinding Cooldown: [DisplayTimeText(different_path_cooldown)]", "orange", "stopwatch")
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/pathfind/populate_ports()
	input_X = add_input_port("Target X", PORT_TYPE_NUMBER, trigger = null)
	input_Y = add_input_port("Target Y", PORT_TYPE_NUMBER, trigger = null)
	id_card = add_input_port("ID Card", PORT_TYPE_ATOM, trigger = null)

	output = add_output_port("Next step", PORT_TYPE_ATOM)
	finished = add_output_port("Arrived to destination", PORT_TYPE_SIGNAL)
	failed = add_output_port("Failed", PORT_TYPE_SIGNAL)
	reason_failed = add_output_port("Fail reason", PORT_TYPE_STRING)

/obj/item/circuit_component/pathfind/input_received(datum/port/input/port)
	INVOKE_ASYNC(src, PROC_REF(perform_pathfinding), port)

/obj/item/circuit_component/pathfind/proc/perform_pathfinding(datum/port/input/port)
	var/target_X = input_X.value
	if(isnull(target_X))
		return

	var/target_Y = input_Y.value
	if(isnull(target_Y))
		return

	var/list/access = list()
	if(isidcard(id_card.value))
		var/obj/item/card/id/id = id_card.value
		access = id.GetAccess()
	else if (id_card.value)
		failed.set_output(COMPONENT_SIGNAL)
		reason_failed.set_output("Object marked is not an ID! Using no ID instead.")

	// Get both the current turf and the destination's turf
	var/turf/current_turf = get_location()
	var/turf/destination = locate(target_X, target_Y, current_turf?.z)

	// We're already here! No need to do anything.
	if(current_turf == destination)
		finished.set_output(COMPONENT_SIGNAL)
		old_dest = null
		TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)
		next_turf = null
		return

	// If we're going to the same place and the cooldown hasn't subsided, we're probably on the same path as before
	if (destination == old_dest && TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME))

		// Check if the current turf is the same as the current turf we're supposed to be in. If so, then we set the next step as the next turf on the list
		if(current_turf == next_turf)
			popleft(path)
			next_turf = get_turf(path[1])
			output.set_output(next_turf)

			// Restart the cooldown since we don't need a new path ( TIMER_COOLDOWN_START might restart the timer by itself and i dont need to call TIMER_COOLDOWN_END, but better safe than sorry )
			TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)
			TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME, same_path_cooldown)


	else // Either we're not going to the same place or the cooldown is over. Either way, we need a new path

		if(destination != old_dest && TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_PATHFIND_DIF))
			failed.set_output(COMPONENT_SIGNAL)
			reason_failed.set_output("Cooldown still active!")
			return

		TIMER_COOLDOWN_END(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME)

		old_dest = destination
		path = get_path_to(src, destination, max_range, access=access)
		if(length(path) == 0 || !path)// Check if we can even path there
			next_turf = null
			failed.set_output(COMPONENT_SIGNAL)
			reason_failed.set_output("Can't go there!")
			return
		else
			TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_DIF, different_path_cooldown)
			next_turf = get_turf(path[1])
			output.set_output(next_turf)
		TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_PATHFIND_SAME, same_path_cooldown)
