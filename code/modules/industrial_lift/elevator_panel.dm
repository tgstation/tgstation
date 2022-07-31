/**
 * # Elevator control panel
 *
 * A wallmounted simple machine that controls elevators,
 * allowing users to enter a UI to move it up or down
 *
 * These can be placed in two methods:
 * - You can place the control panel on the same turf as a lift. It will move up and down with the lift
 * - You can place the control panel to the side of a lift, NOT attached to the lift. It will remain in position
 */
/obj/machinery/elevator_control_panel
	name = "elevator panel"
	// Fire alarm reference.
	desc = "<i>\"In case of emergency, please use the stairs.\"</i> Thus, always use the stairs."
	density = FALSE

	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	base_icon_state = "airlock_control"

	power_channel = AREA_USAGE_ENVIRON
	// Indestructible until someone wants to make these constructible, with all the chaos that implies
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Were we instantiated at mapload? Used to determine when we should link / throw errors
	var/maploaded = FALSE

	/// A weakref to the lift_master datum we control
	var/datum/weakref/lift_weakref
	/// What specific_lift_id do we link with?
	var/linked_elevator_id
	/// A list of all possible destinations this elevator can travel.
	/// Assoc list of "Floor name" to "z level of destination".
	/// By default the floor names will auto-generate ("Floor 1", "Floor 2", etc).
	var/list/linked_elevator_destination
	/// If you want to override what each floor is named as, you can do so with this list.
	/// Make this an assoc list of "z level you want to rename" to "desired name".
	/// So, if you want the z-level 2 destination to be named "Cargo", you would do list("2" = "Cargo").
	var/list/preset_destination_names
	/// TimerID to our door reset timer, made by emergency opening doors
	var/door_reset_timerid

/obj/machinery/elevator_control_panel/Initialize(mapload)
	. = ..()

	var/static/list/tool_behaviors = list(
		TOOL_MULTITOOL = list(SCREENTIP_CONTEXT_LMB = "Reset Panel"),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Send Elevator")

	// Machinery returns lateload by default via parent,
	// this is just here for redundancy's sake
	. = INITIALIZE_HINT_LATELOAD

	maploaded = mapload
	// Maploaded panels link in LateInitialize
	if(mapload)
		return

	// Non-mapload panels link in Initialize
	var/datum/lift_master/lift = get_associated_lift()
	if(!lift)
		return

	lift_weakref = WEAKREF(lift)
	populate_destinations_list(lift)

/obj/machinery/elevator_control_panel/LateInitialize()
	. = ..()
	// If we weren't maploaded, we probably already linked (or tried to link) in Initialize().
	if(!maploaded)
		return

	// This is exclusively for linking in mapload, to ensure all elevator parts are created
	var/datum/lift_master/lift = get_associated_lift()
	if(!lift)
		// We only throw linking errors in mapload so mappers can see if they messed up
		log_mapping("Elevator control panel at [AREACOORD(src)] found no associated lift to link with, this may be a mapping error.")
		return

	lift_weakref = WEAKREF(lift)
	populate_destinations_list(lift)

/obj/machinery/elevator_control_panel/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed) * 0.5

	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "safeties overridden")
	obj_flags |= EMAGGED

/obj/machinery/elevator_control_panel/multitool_act(mob/living/user)
	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return

	balloon_alert(user, "resetting panel...")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(!do_after(user, 6 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return TRUE

	if(QDELETED(lift) || !length(lift.lift_platforms))
		return

	// If we were emagged, reset us
	if(obj_flags & EMAGGED)
		for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
			lift_platform.violent_landing = initial(lift_platform.violent_landing)
			lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
			lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed)

		obj_flags &= ~EMAGGED

	// If we had doors open, stop the timer and reset them
	if(door_reset_timerid)
		deltimer(door_reset_timerid)
	reset_doors()

	// be vague about whether something was accomplished or not
	balloon_alert(user, "panel reset")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)

	return TRUE

/// Find the elevator associated with our lift button
/obj/machinery/elevator_control_panel/proc/get_associated_lift()
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != linked_elevator_id)
			continue

		return possible_match

	return null

/// Goes through and populates the linked_elevator_destination list with all possible destinations the lift can go.
/obj/machinery/elevator_control_panel/proc/populate_destinations_list(datum/lift_master/linked_lift)
	// Get a list of all the starting locs our elevator starts at
	var/list/starting_locs = list()
	for(var/obj/structure/industrial_lift/lift_piece as anything in linked_lift.lift_platforms)
		starting_locs |= lift_piece.locs

	// Start with the initial z level obviously
	var/list/raw_destinations = list(linked_lift.lift_platforms[1].z)
	// Get all destinations below us
	add_destinations_in_a_direction_recursively(starting_locs, DOWN, raw_destinations)
	// Get all destinations above us
	add_destinations_in_a_direction_recursively(starting_locs, UP, raw_destinations)

	linked_elevator_destination = list()
	for(var/z_level in raw_destinations)
		// Check if this z-level has a preset destination associated.
		var/preset_name = preset_destination_names?[num2text(z_level)]
		// If we don't have a preset name, use Floor z-1 for the title.
		// z - 1 is used because the station z-level is 2, and goes up.
		linked_elevator_destination["[z_level]"] = preset_name || "Floor [z_level - 1]"

	// Reverse it, so higher Zs are lower are at the top of the list, and lower Zs are at the bottom
	reverse_range(linked_elevator_destination)

/**
 * Recursively adds destinations to the list of linked_elevator_destination
 * until it fails to find a valid stopping point in the passed direction.
 */
/obj/machinery/elevator_control_panel/proc/add_destinations_in_a_direction_recursively(list/turfs_to_check, direction, list/destinations)
	// Only vertical elevators are supported -  use trams for horizontal ones
	if(direction != UP && direction != DOWN)
		CRASH("[type] was given an invalid direction in add_destinations_in_a_direction_recursively!")

	var/list/turf/checked_turfs = list()
	// Go through every turf passed in our list of turfs to check.
	for(var/turf/place in turfs_to_check)
		// If the place we're checking isn't openspace, then we can't go downwards
		if(direction == DOWN && !istype(place, /turf/open/openspace))
			return

		// Check the turf at the next level (either above or below the place we're checking)
		var/turf/next_level = get_step_multiz(place, direction)
		// No turf = at the edge of a map vertically
		if(!next_level)
			return
		// If the next level above us has a roof, we can't move up
		if(direction == UP && !istype(next_level, /turf/open/openspace))
			return

		// Otherwise, we can feasibly move our direction with this turf
		checked_turfs += next_level

	// If we somehow found no turfs but made it this far, and error has been made
	if(!length(checked_turfs))
		CRASH("[type] found no turfs in add_destinations_in_a_direction_recursively!")

	// Add the Z as a possible destination
	destinations |= checked_turfs[1].z
	// And recursively call the proc with all the turfs we found on the next level
	add_destinations_in_a_direction_recursively(checked_turfs, direction, destinations)

/obj/machinery/elevator_control_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ElevatorPanel", name)
		ui.open()

/obj/machinery/elevator_control_panel/ui_status(mob/user)
	// We moved up a z-level, probably via the lift itself, don't preserve the UI
	if(user.z != z)
		return UI_CLOSE

	// Our list if gone - look but don't touch
	if(!lift_weakref?.resolve())
		return UI_UPDATE

	// We're non-functional, probably - don't do anything
	if(!check_panel())
		return UI_DISABLED

	// Otherwise, just check the default state
	return ..()

/obj/machinery/elevator_control_panel/ui_data(mob/user)
	var/list/data = list()

	data["panel_z"] = z
	data["emergency_level"] = capitalize(SSsecurity_level.get_current_level_as_text())
	data["is_emergency"] = SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED
	data["doors_open"] = !!door_reset_timerid

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(lift)
		data["lift_exists"] = TRUE
		data["currently_moving"] = lift.controls_locked == LIFT_PLATFORM_LOCKED
		data["current_floor"] = lift.lift_platforms[1].z

	else
		data["lift_exists"] = FALSE
		data["current_floor"] = -1

	return data

/obj/machinery/elevator_control_panel/ui_static_data(mob/user)
	var/list/data = list()

	data["all_floor_data"] = list()
	for(var/destination in linked_elevator_destination)
		data["all_floor_data"] += list(list(
			"name" = linked_elevator_destination[destination],
			"z_level" = text2num(destination),
		))

	return data

/obj/machinery/elevator_control_panel/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!check_panel())
		return TRUE // We shouldn't be usable right now, update UI

	switch(action)
		if("move_lift")
			if(!allowed(usr))
				balloon_alert(usr, "access denied!")
				return

			var/desired_z = params["z"]
			// Num2text here is required as the z's are stored as strings
			if(!(num2text(desired_z) in linked_elevator_destination))
				return TRUE // Something is inaccurate, update UI

			var/datum/lift_master/lift = lift_weakref?.resolve()
			if(!lift || lift.controls_locked == LIFT_PLATFORM_LOCKED)
				return TRUE // We shouldn't be moving anything, update UI

			INVOKE_ASYNC(lift, /datum/lift_master.proc/move_to_zlevel, desired_z, CALLBACK(src, .proc/check_panel), usr)
			return TRUE // Succcessfully initiated a move, regardless of whether it actually works update the UI

		if("emergency_door")
			var/datum/lift_master/lift = lift_weakref?.resolve()
			if(!lift)
				return TRUE // Something is very wrong

			if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED)
				return TRUE // Only operational on red alert or higher, so people won't just ALWAYS put it on emergency mode

			lift.open_lift_doors()
			door_reset_timerid = addtimer(CALLBACK(src, .proc/reset_doors), 3 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
			return TRUE

		if("reset_doors")
			if(!door_reset_timerid)
				return TRUE

			deltimer(door_reset_timerid)
			reset_doors()
			return TRUE

/// Callback for move_to_zlevel to ensure the lift can continue to move.
/obj/machinery/elevator_control_panel/proc/check_panel()
	if(QDELETED(src))
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	return TRUE

/// Helper proc to go through all of our desetinations and reset all elevator doors,
/// closing doors on z-levels the lift is away from, and opening doors on the z the lift is
/obj/machinery/elevator_control_panel/proc/reset_doors()
	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return

	for(var/z_level in linked_elevator_destination)
		z_level = text2num(z_level)
		if(z_level == lift.lift_platforms[1].z)
			lift.open_lift_doors(z_level)
		else
			lift.close_lift_doors(z_level)

	door_reset_timerid = null

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/elevator_control_panel, 30)
