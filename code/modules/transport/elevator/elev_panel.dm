/**
 * # Elevator control panel
 *
 * A wallmounted simple machine that controls elevators,
 * allowing users to enter a UI to move it up or down
 *
 * These can be placed in two methods:
 * - You can place the control panel on the same turf as an elevator. It will move up and down with the elevator
 * - You can place the control panel to the side of an elevator, NOT attached to the elevator. It will remain in position
 * - I don't recommend using both methods on the same elevator, as it might result in some jank, but it's functional.
 */
/obj/machinery/elevator_control_panel
	name = "elevator panel"
	// Fire alarm reference.
	desc = "<i>\"In case of emergency, please use the stairs.\"</i> Thus, always use the stairs."
	density = FALSE

	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "elevpanel0"
	base_icon_state = "elevpanel"

	power_channel = AREA_USAGE_ENVIRON
	// Indestructible until someone wants to make these constructible, with all the chaos that implies
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Were we instantiated at mapload? Used to determine when we should link / throw errors
	var/maploaded = FALSE

	/// A weakref to the transport_controller datum we control
	var/datum/weakref/lift_weakref
	/// What specific_transport_id do we link with?
	var/linked_elevator_id

	/// A list of all possible destinations this elevator can travel.
	/// Assoc list of "Floor name" to "z level of destination".
	/// By default the floor names will auto-generate ("Floor 1", "Floor 2", etc).
	var/list/linked_elevator_destination
	/// If you want to override what each floor is named as, you can do so with this list.
	/// Make this an assoc list of "z level you want to rename" to "desired name".
	/// So, if you want the z-level 2 destination to be named "Cargo", you would do list("2" = "Cargo").
	/// (Reminder: Z1 gets loaded as Central Command, so your map's bottom Z will be Z2!)
	var/list/preset_destination_names

	/// What z-level did we move to last? Used for showing the user in the UI which direction we're moving.
	var/last_move_target
	/// TimerID to our door reset timer, made by emergency opening doors
	var/door_reset_timerid
	/// The light mask overlay we use
	light_power = 0.5 // Minimums, we want the button to glow if it has a mask, not light an area
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE
	var/light_mask = "elev-light-mask"

/obj/machinery/elevator_control_panel/Initialize(mapload)
	. = ..()

	var/static/list/tool_behaviors = list(
		TOOL_MULTITOOL = list(SCREENTIP_CONTEXT_LMB = "Reset Panel"),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Send Elevator")

	// Machinery returns lateload by default via parent,
	// this is just here for redundancy's sake.
	. = INITIALIZE_HINT_LATELOAD

	maploaded = mapload
	// Maploaded panels link in LateInitialize...
	if(mapload)
		return

	// And non-mapload panels link in Initialize
	link_with_lift(log_error = FALSE)

/obj/machinery/elevator_control_panel/LateInitialize()
	. = ..()
	// If we weren't maploaded, we probably already linked (or tried to link) in Initialize().
	if(!maploaded)
		return

	// This is exclusively for linking in mapload, just to ensure all elevator parts are created,
	// and also so we can throw mapping errors to let people know if they messed up setup.
	link_with_lift(log_error = TRUE)

/// Link with associated transport controllers, only log failure to find a lift in LateInit because those are mapped in
/obj/machinery/elevator_control_panel/proc/link_with_lift(log_error = FALSE)
	var/datum/transport_controller/linear/lift = get_associated_lift()
	if(!lift)
		if (log_error)
			log_mapping("Elevator control panel at [AREACOORD(src)] found no associated lift to link with, this may be a mapping error.")
		return

	lift_weakref = WEAKREF(lift)
	populate_destinations_list(lift)
	if ((linked_elevator_id in GLOB.elevator_music))
		var/obj/effect/abstract/elevator_music_zone/music = GLOB.elevator_music[linked_elevator_id]
		music.link_to_panel(src)

/obj/machinery/elevator_control_panel/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE

	obj_flags |= EMAGGED

	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(!lift)
		return FALSE

	for(var/obj/structure/transport/linear/lift_platform as anything in lift.transport_modules)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed) * 0.5

	for(var/obj/machinery/door/elevator_door as anything in GLOB.elevator_doors)
		if(elevator_door.transport_linked_id != linked_elevator_id)
			continue
		if(elevator_door.obj_flags & EMAGGED)
			continue
		elevator_door.elevator_status = LIFT_PLATFORM_UNLOCKED
		INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door, open), BYPASS_DOOR_CHECKS)
		elevator_door.obj_flags |= EMAGGED

	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "safeties overridden")
	return TRUE

/obj/machinery/elevator_control_panel/multitool_act(mob/living/user)
	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(!lift)
		return

	balloon_alert(user, "resetting panel...")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(!do_after(user, 6 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return TRUE

	if(QDELETED(lift) || !length(lift.transport_modules))
		return

	// If we were emagged, reset us
	if(obj_flags & EMAGGED)
		for(var/obj/structure/transport/linear/lift_platform as anything in lift.transport_modules)
			lift_platform.violent_landing = initial(lift_platform.violent_landing)
			lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
			lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed)

		for(var/obj/machinery/door/elevator_door as anything in GLOB.elevator_doors)
			if(elevator_door.transport_linked_id != linked_elevator_id)
				continue
			if(!(elevator_door.obj_flags & EMAGGED))
				continue
			elevator_door.obj_flags &= ~EMAGGED
			INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door, close))

		obj_flags &= ~EMAGGED

	// If we had doors open, stop the timer and reset them
	if(door_reset_timerid)
		deltimer(door_reset_timerid)
	reset_doors()

	// Be vague about whether something was accomplished or not
	balloon_alert(user, "panel reset")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)

	return TRUE

/// Find the elevator associated with our lift button.
/obj/machinery/elevator_control_panel/proc/get_associated_lift()
	for(var/datum/transport_controller/linear/possible_match as anything in SStransport.transports_by_type[TRANSPORT_TYPE_ELEVATOR])
		if(possible_match.specific_transport_id != linked_elevator_id)
			continue

		return possible_match

	return null

/// Goes through and populates the linked_elevator_destination list with all possible destinations the lift can go.
/obj/machinery/elevator_control_panel/proc/populate_destinations_list(datum/transport_controller/linear/linked_lift)
	// This list will track all the raw z-levels which we found that we can travel to
	var/list/raw_destinations = list()

	// Get a list of all the starting locs our elevator starts at
	var/list/starting_locs = list()
	for(var/obj/structure/transport/linear/lift_piece as anything in linked_lift.transport_modules)
		starting_locs |= lift_piece.locs
		// The raw destination list will start with all the z's we start at
		raw_destinations |= lift_piece.z

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

	// Reverse the destination list.
	// By this point the list will go from bottom floor to top floor,
	// which is unintuitive when passed to the UI to show to users.
	// This way we have the top floors at the top, and the bottom floors the bottom.
	reverse_range(linked_elevator_destination)
	update_static_data_for_all_viewers()

/**
 * Recursively adds destinations to the list of linked_elevator_destination
 * until it fails to find a valid stopping point in the passed direction.
 */
/obj/machinery/elevator_control_panel/proc/add_destinations_in_a_direction_recursively(list/turfs_to_check, direction, list/destinations)
	// Only vertical elevators are supported -  use trams for horizontal ones.
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

	// If we somehow found no turfs, BUT made it this far, something definitely went wrong.
	if(!length(checked_turfs))
		CRASH("[type] found no turfs in add_destinations_in_a_direction_recursively!")

	// Add the Zs of all the found turfs as possible destinations
	for(var/turf/found as anything in checked_turfs)
		// We check all turfs we found in case of multi-z memes.
		destinations |= found.z

	// And recursively call the proc with all the turfs we found on the next level
	add_destinations_in_a_direction_recursively(checked_turfs, direction, destinations)

/obj/machinery/elevator_control_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ElevatorPanel", name)
		ui.open()

/obj/machinery/elevator_control_panel/ui_status(mob/user)
	// We moved up a z-level, probably via the elevator itself, so don't preserve the UI.
	if(user.z != z)
		return UI_CLOSE

	// Our lift is gone entirely - look, but don't touch.
	if(!lift_weakref?.resolve())
		return UI_UPDATE

	// We're non-functional - don't do anything.
	if(!check_panel())
		return UI_DISABLED

	// Otherwise, just check default state (is the user conscious and close, etc).
	return ..()

/obj/machinery/elevator_control_panel/ui_data(mob/user)
	var/list/data = list()

	data["emergency_level"] = capitalize(SSsecurity_level.get_current_level_as_text())
	data["is_emergency"] = SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED
	data["doors_open"] = !!door_reset_timerid

	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(lift)
		data["lift_exists"] = TRUE
		data["currently_moving"] = lift.controls_locked == LIFT_PLATFORM_LOCKED
		data["currently_moving_to_floor"] = last_move_target
		data["current_floor"] = lift.transport_modules[1].z

	else
		data["lift_exists"] = FALSE
		data["currently_moving"] = FALSE
		data["current_floor"] = 0 // 0 shows up as "Floor -1" in the UI, which is fine for what it is

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
			// num2text here is required as the z is stored as strings in the list, but passed here as a number.
			if(!(num2text(desired_z) in linked_elevator_destination))
				return TRUE // Something is inaccurate, update UI

			var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
			if(!lift || lift.controls_locked == LIFT_PLATFORM_LOCKED)
				return TRUE // We shouldn't be moving anything, update UI

			INVOKE_ASYNC(lift, TYPE_PROC_REF(/datum/transport_controller/linear, move_to_zlevel), desired_z, CALLBACK(src, PROC_REF(check_panel)), usr)
			last_move_target = desired_z
			return TRUE // Succcessfully initiated a move. Regardless of whether it actually works, update the UI

		if("emergency_door")
			var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
			if(!lift)
				return TRUE // Something is wrong, update UI

			// The emergency door button is only available at red alert or higher.
			// This is so people don't keep it in emergency mode 100% of the time.
			if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED)
				return TRUE // The security level might have been lowered since last update, so update UI

			// Open all elevator doors, it's an emergency dang it!
			lift.update_lift_doors(action = CYCLE_OPEN)
			door_reset_timerid = addtimer(CALLBACK(src, PROC_REF(reset_doors)), 3 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
			return TRUE // We opened up all the doors, update the UI so the emergency button is replaced correctly

		if("reset_doors")
			if(!door_reset_timerid)
				return TRUE // All the doors were shut since last update, so update UI

			deltimer(door_reset_timerid)
			reset_doors()
			return TRUE // We closed all the doors, update the UI so the door button is replaced correctly

/// Callback for move_to_zlevel to ensure the elevator can continue to move.
/obj/machinery/elevator_control_panel/proc/check_panel()
	if(QDELETED(src))
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE

	return TRUE

/// Helper proc to go through all of our desetinations and reset all elevator doors,
/// closing doors on z-levels the elevator is away from, and opening doors on the z the elevator is
/obj/machinery/elevator_control_panel/proc/reset_doors()
	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(!lift)
		return

	var/list/zs_we_are_present_on = lift.get_zs_we_are_on()
	var/list/zs_we_are_absent = list()

	for(var/z_level in linked_elevator_destination)
		z_level = text2num(z_level) // Stored as strings.
		if(z_level in zs_we_are_present_on)
			continue

		zs_we_are_absent |= z_level

	// Open all the doors on the zs we should be open on,
	// and close all doors we aren't on. Simple enough.
	lift.update_lift_doors(zs_we_are_present_on, action = CYCLE_OPEN)
	lift.update_lift_doors(zs_we_are_absent, action = CYCLE_CLOSED)

	door_reset_timerid = null

/obj/machinery/elevator_control_panel/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/elevator_control_panel, 31)
