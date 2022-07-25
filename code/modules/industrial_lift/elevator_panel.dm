/obj/machinery/elevator_control_panel
	name = "elevator panel"
	desc = "<i>\"In case of emergency, please use the stairs.\"</i> Thus, always use the stairs." // Fire alarm reference, yes.
	density = FALSE

	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	base_icon_state = "airlock_control"

	var/linked_elevator_id
	var/list/linked_elevator_desinations

/obj/machinery/elevator_control_panel/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	var/datum/lift_master/lift = get_associated_lift()
	if(!lift)
		return

	populate_destinations_list(lift)

// LateInitialize is only done after mapload,
// just to make sure all the bit exist properly, and
// to throw mapping errors if not
/obj/machinery/elevator_control_panel/LateInitialize()
	var/datum/lift_master/lift = get_associated_lift()
	if(!lift)
		log_mapping("Elevator control panel at [AREACOORD(src)] found no associated lift to link with, this may be a mapping error.")
		return

	populate_destinations_list(lift)

/// Find the elevator associated with our lift button
/obj/machinery/elevator_control_panel/proc/get_associated_lift()
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != linked_elevator_id)
			continue

		return possible_match

	return null

/// Goes through and populates the linked_elevator_desinations list with all possible destinations the lift can go.
/obj/machinery/elevator_control_panel/proc/populate_destinations_list(datum/lift_master/linked_lift)
	// Get a list of all the starting locs our elevator starts at
	var/list/starting_locs = list()
	for(var/obj/structure/industrial_lift/lift_piece as anything in lift.lift_platforms)
		starting_locs |= lift_piece.locs

	// Start with the initial destination obviously
	linked_elevator_desinations = list(loc.z)
	// Get all destinations below us
	add_destinations_in_a_direction_recursively(starting_locs, DOWN)
	// Get all destinations above us
	add_destinations_in_a_direction_recursively(starting_locs, UP)

/**
 * Recursively adds destinations to the list of linked_elevator_desinations
 * until it fails to find a valid stopping point in the passed direction.
 */
/obj/machinery/elevator_control_panel/proc/add_destinations_in_a_direction_recursively(list/turfs_to_check, direction)
	// Only vertical elevators are supported -  use trams for horizontal ones
	if(direction != UP && direction != DOWN)
		CRASH("[type] was given an invalid direction in add_destinations_in_a_direction_recursively!")

	var/list/turf/checked_turfs = list()
	// Go through every turf passed in our list of turfs to check.
	for(var/turf/place in turfs_to_check)
		// Check the turf above or below the turf we're visiting to see if a lift could feasibly move in that direction.
		var/turf/next_level = get_step_multiz(place, direction)
		// No turf = at the edge of a map vertically
		if(!next_level)
			return
		// If the next level above us has a roof, we can't move up
		if(direction == UP && !istype(next_level, /turf/open/openspace))
			return
		// If the next level below us has a floor, we can't move down
		if(direction == DOWN && !istype(place, /turf/open/openspace))
			return

		// Otherwise, we can feasibly move our direction with this turf
		checked_turfs += next_level

	// If we somehow found no turfs but made it this far, and error has been made
	if(!length(checked_turfs))
		CRASH("[type] found no turfs in add_destinations_in_a_direction_recursively!")

	// Add the Z as a possible destination
	linked_elevator_desinations += checked_turfs[1].z
	// And recursively call the proc with all the turfs we found on the next level
	add_destinations_in_a_direction_recursively(checked_turfs, direction)

/obj/machinery/elevator_control_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ElevatorPanel", name)
		ui.open()
