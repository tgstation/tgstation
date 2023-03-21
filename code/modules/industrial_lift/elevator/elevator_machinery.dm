GLOBAL_LIST_EMPTY(elevator_doors)

/**
 * # Elevator control panel
 *
 * A wallmounted simple machine that controls elevators,
 * allowing users to enter a UI to move it up or down
 *
 * These can be placed in two methods:
 * - You can place the control panel on the same turf as a lift. It will move up and down with the lift
 * - You can place the control panel to the side of a lift, NOT attached to the lift. It will remain in position
 * I don't recommend using both methods on the same elevator, as it might result in some jank, but it's functional.
 */
/obj/machinery/elevator_control_panel
	name = "elevator panel"
	// Fire alarm reference.
	desc = "<i>\"In case of emergency, please use the stairs.\"</i> Thus, always use the stairs."
	density = FALSE

	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "elevpanel0"
	base_icon_state = "elevpanel"

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

	// This is exclusively for linking in mapload, just to ensure all elevator parts are created,
	// and also so we can throw mapping errors to let people know if they messed up setup.
	var/datum/lift_master/lift = get_associated_lift()
	if(!lift)
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

	for(var/obj/machinery/door/window/elevator/elevator_door in GLOB.elevator_doors)
		if(elevator_door.id != linked_elevator_id)
			continue
		elevator_door.open
		elevator_door.obj_flags |= EMAGGED

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

		for(var/obj/machinery/door/window/elevator/elevator_door in GLOB.elevator_doors)
			if(elevator_door.id != linked_elevator_id)
				continue
			elevator_door.obj_flags &= ~EMAGGED

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
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != linked_elevator_id)
			continue

		return possible_match

	return null

/// Goes through and populates the linked_elevator_destination list with all possible destinations the lift can go.
/obj/machinery/elevator_control_panel/proc/populate_destinations_list(datum/lift_master/linked_lift)
	// This list will track all the raw z-levels which we found that we can travel to
	var/list/raw_destinations = list()

	// Get a list of all the starting locs our elevator starts at
	var/list/starting_locs = list()
	for(var/obj/structure/industrial_lift/lift_piece as anything in linked_lift.lift_platforms)
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
		// We check all turfs we found in case of multi-z lift memes.
		destinations |= found.z

	// And recursively call the proc with all the turfs we found on the next level
	add_destinations_in_a_direction_recursively(checked_turfs, direction, destinations)

/obj/machinery/elevator_control_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ElevatorPanel", name)
		ui.open()

/obj/machinery/elevator_control_panel/ui_status(mob/user)
	// We moved up a z-level, probably via the lift itself, so don't preserve the UI.
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

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(lift)
		data["lift_exists"] = TRUE
		data["currently_moving"] = lift.controls_locked == LIFT_PLATFORM_LOCKED
		data["currently_moving_to_floor"] = last_move_target
		data["current_floor"] = lift.lift_platforms[1].z

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

			var/datum/lift_master/lift = lift_weakref?.resolve()
			if(!lift || lift.controls_locked == LIFT_PLATFORM_LOCKED)
				return TRUE // We shouldn't be moving anything, update UI

			INVOKE_ASYNC(lift, TYPE_PROC_REF(/datum/lift_master, move_to_zlevel), desired_z, CALLBACK(src, PROC_REF(check_panel)), usr)
			last_move_target = desired_z
			return TRUE // Succcessfully initiated a move. Regardless of whether it actually works, update the UI

		if("emergency_door")
			var/datum/lift_master/lift = lift_weakref?.resolve()
			if(!lift)
				return TRUE // Something is wrong, update UI

			// The emergency door button is only available at red alert or higher.
			// This is so people don't keep it in emergency mode 100% of the time.
			if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED)
				return TRUE // The security level might have been lowered since last update, so update UI

			// Open all lift doors, it's an emergency dang it!
			lift.update_lift_doors(action = OPEN_DOORS)
			door_reset_timerid = addtimer(CALLBACK(src, PROC_REF(reset_doors)), 3 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
			return TRUE // We opened up all the doors, update the UI so the emergency button is replaced correctly

		if("reset_doors")
			if(!door_reset_timerid)
				return TRUE // All the doors were shut since last update, so update UI

			deltimer(door_reset_timerid)
			reset_doors()
			return TRUE // We closed all the doors, update the UI so the door button is replaced correctly

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

	var/list/zs_we_are_present_on = lift.get_zs_we_are_on()
	var/list/zs_we_are_absent = list()

	for(var/z_level in linked_elevator_destination)
		z_level = text2num(z_level) // Stored as strings.
		if(z_level in zs_we_are_present_on)
			continue

		zs_we_are_absent |= z_level

	// Open all the doors on the zs we should be open on,
	// and close all doors we aren't on. Simple enough.
	lift.update_lift_doors(zs_we_are_present_on, action = OPEN_DOORS)
	lift.update_lift_doors(zs_we_are_absent, action = CLOSE_DOORS)

	door_reset_timerid = null

/obj/machinery/elevator_control_panel/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/elevator_control_panel, 31)

/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."
	/// A weakref to the lift_master datum we control
	var/datum/weakref/lift_weakref

/obj/item/assembly/control/elevator/Initialize(mapload)
	. = ..()

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	var/datum/lift_master/lift = get_lift()
	if(!lift)
		return

	lift_weakref = WEAKREF(lift)

/obj/item/assembly/control/elevator/LateInitialize()
	var/datum/lift_master/lift = get_lift()
	if(!lift)
		log_mapping("Elevator call button at [AREACOORD(src)] found no associated lift to link with, this may be a mapping error.")
		return

	lift_weakref = WEAKREF(lift)

// Emagging elevator buttons will disable safeties
/obj/item/assembly/control/elevator/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed) * 0.5

	// Note that we can either be emagged by having the button we are inside swiped,
	// or by someone emagging the assembly directly after removing it (to be cheeky)
	var/atom/balloon_alert_loc = get(src, /obj/machinery/button) || src
	balloon_alert_loc.balloon_alert(user, "safeties overridden")
	obj_flags |= EMAGGED
	return TRUE

// Multitooling emagged elevator buttons will fix the safeties
/obj/item/assembly/control/elevator/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		return ..()

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return ..()

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = initial(lift_platform.violent_landing)
		lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed)

	// We can only be multitooled directly so just throw up the balloon alert
	balloon_alert(user, "safeties reset")
	obj_flags &= ~EMAGGED
	return TRUE

/obj/item/assembly/control/elevator/activate(mob/activator)
	if(cooldown)
		return

	cooldown = TRUE
	// Actually try to call the elevator - this sleeps.
	// If we failed to call it, play a buzz sound.
	if(!call_elevator(activator))
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, TRUE)

	// Finally, give people a chance to get off after it's done before going back off cooldown
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)

/// Actually calls the elevator.
/// Returns FALSE if we failed to setup the move.
/// Returns TRUE if the move setup was a success, EVEN IF the move itself fails afterwards
/obj/item/assembly/control/elevator/proc/call_elevator(mob/activator)
	// We can't call an elevator that doesn't exist
	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		loc.balloon_alert(activator, "no elevator connected!")
		return FALSE

	// We can't call an elevator that's moving. You may say "you totally can do that", but that's not modelled
	if(lift.controls_locked == LIFT_PLATFORM_LOCKED)
		loc.balloon_alert(activator, "elevator is moving!")
		return FALSE

	// If the elevator is already here, open the doors.
	var/obj/structure/industrial_lift/prime_lift = lift.return_closest_platform_to_z(loc.z)
	if(prime_lift.z == loc.z)
		INVOKE_ASYNC(lift, TYPE_PROC_REF(/datum/lift_master, open_lift_doors_callback))
		loc.balloon_alert(activator, "elevator is here!")
		return TRUE

	// At this point, we can start moving.

	// Give the user, if supplied, a balloon alert.
	if(activator)
		loc.balloon_alert(activator, "elevator called")

	// Actually try to move the lift. This will sleep.
	if(!lift.move_to_zlevel(loc.z, CALLBACK(src, PROC_REF(check_button))))
		loc.balloon_alert(activator, "elevator out of service!")
		return FALSE

	// From here on all returns are TRUE, as we successfully moved the lift, even if we maybe didn't reach our floor

	// Our button was destroyed mid transit.
	if(!check_button())
		return TRUE

	// Our lift platform survived, but it didn't reach our landing z.
	if(!QDELETED(prime_lift) && prime_lift.z != loc.z)
		if(!QDELETED(activator))
			loc.balloon_alert(activator, "elevator out of service!")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return TRUE

	// Everything went according to plan
	playsound(loc, 'sound/machines/ping.ogg', 50, TRUE)
	if(!QDELETED(activator))
		loc.balloon_alert(activator, "elevator arrived")

	return TRUE

/// Callback for move_to_zlevel / general proc to check if we're still in a button
/obj/item/assembly/control/elevator/proc/check_button()
	if(QDELETED(src))
		return FALSE
	if(!istype(loc, /obj/machinery/button))
		return FALSE
	return TRUE

/// Gets the lift associated with our assembly / button
/obj/item/assembly/control/elevator/proc/get_lift()
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != id)
			continue

		return possible_match

	return null

/obj/machinery/button/elevator
	name = "elevator button"
	desc = "Go back. Go back. Go back. Can you operate the elevator."
	icon_state = "hallctrl"
	skin = "hallctrl"
	device_type = /obj/item/assembly/control/elevator
	req_access = list()
	id = 1
	light_mask = "hall-light-mask"

/obj/machinery/button/elevator/Initialize(mapload, ndir, built)
	. = ..()
	// Kind of a cop-out
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Call Elevator")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/elevator, 32)


/**
 * A lift indicator aka an elevator hall lantern w/ floor number
 */
/obj/machinery/lift_indicator
	name = "elevator indicator"
	desc = "Indicates what floor the elevator is at and which way it's going."
	icon = 'icons/obj/machines/lift_indicator.dmi'
	icon_state = "lift_indo-base"
	base_icon_state = "lift_indo-"
	max_integrity = 500
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	anchored = TRUE
	density = FALSE

	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_DARK_BLUE
	luminosity = 1

	maptext_x = 17
	maptext_y = 21
	maptext_width = 4
	maptext_height = 8

	/// What specific_lift_id do we link with?
	var/linked_elevator_id

	// = (real lowest floor's z-level) - (what we want to display)
	var/lowest_floor_offset = 1

	/// Weakref to the lift.
	var/datum/weakref/lift_ref
	/// The lowest floor number. Determined by lift init.
	var/lowest_floor_num = 1
	/// Positive for going up, negative going down, 0 for stopped
	var/current_lift_direction = 0
	/// The lift's current floor relative to its lowest floor being 1
	var/current_lift_floor = 1

/obj/machinery/lift_indicator/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/lift_indicator/LateInitialize()
	. = ..()

	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != linked_elevator_id)
			continue

		lift_ref = WEAKREF(possible_match)
		RegisterSignal(possible_match, COMSIG_LIFT_SET_DIRECTION, PROC_REF(on_lift_direction))

/obj/machinery/lift_indicator/examine(mob/user)
	. = ..()

	if(!is_operational)
		. += span_notice("The display is dark.")
		return

	var/dirtext
	switch(current_lift_direction)
		if(UP)
			dirtext = "travelling upwards"
		if(DOWN)
			dirtext = "travelling downwards"
		else
			dirtext = "stopped"

	. += span_notice("The elevator is at floor [current_lift_floor], [dirtext].")

/**
 * Update state, and only process if lift is moving.
 */
/obj/machinery/lift_indicator/proc/on_lift_direction(datum/source, direction)
	SIGNAL_HANDLER

	var/datum/lift_master/lift = lift_ref?.resolve()
	if(!lift)
		return

	set_lift_state(direction, current_lift_floor)
	update_operating()

/obj/machinery/lift_indicator/on_set_is_operational()
	. = ..()

	update_operating()

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/lift_indicator/proc/update_operating()
	// Let process() figure it out to have the logic in one place.
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/lift_indicator/process()
	var/datum/lift_master/lift = lift_ref?.resolve()

	// Check for stopped states.
	if(!lift || !is_operational)
		// Lift missing, or we lost power.
		set_lift_state(0, 0, force = !is_operational)
		return PROCESS_KILL

	use_power(active_power_usage)

	var/obj/structure/industrial_lift/lift_part = lift.lift_platforms[1]

	if(QDELETED(lift_part))
		set_lift_state(0, 0, force = !is_operational)
		return PROCESS_KILL

	// Update
	set_lift_state(current_lift_direction, lift.lift_platforms[1].z - lowest_floor_offset)

	// Lift's not moving, we're done; we just had to update the floor number one last time.
	if(!current_lift_direction)
		return PROCESS_KILL

/**
 * Set the state and update appearance.
 *
 * Arguments:
 * new_direction - new arrow state: UP, DOWN, or 0
 * new_floor - set the floor number, eg. 1, 2, 3
 * force_update - force appearance to update even if state didn't change.
 */
/obj/machinery/lift_indicator/proc/set_lift_state(new_direction, new_floor, force = FALSE)
	if(new_direction == current_lift_direction && new_floor == current_lift_floor && !force)
		return

	current_lift_direction = new_direction
	current_lift_floor = new_floor
	update_appearance()

/obj/machinery/lift_indicator/update_appearance(updates)
	. = ..()

	if(!is_operational)
		set_light(l_on = FALSE)
		maptext = ""
		return

	set_light(l_on = TRUE)
	maptext = {"<div style="font:5pt 'Small Fonts';color:[LIGHT_COLOR_DARK_BLUE]">[current_lift_floor]</div>"}

/obj/machinery/lift_indicator/update_overlays()
	. = ..()

	if(!is_operational)
		return

	. += emissive_appearance(icon, "[base_icon_state]e", offset_spokesman = src, alpha = src.alpha)

	if(!current_lift_direction)
		return

	var/arrow_icon_state = "[base_icon_state][current_lift_direction == UP ? "up" : "down"]"

	. += mutable_appearance(icon, arrow_icon_state)
	. += emissive_appearance(icon, "[arrow_icon_state]e", offset_spokesman = src, alpha = src.alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/lift_indicator, 32)

/obj/machinery/door/window/elevator
	name = "elevator door"
	desc = "Keeps idiots like you from walking into an open elevator shaft."
	can_atmos_pass = ATMOS_PASS_DENSITY // elevator shaft is airtight when closed
	var/id = null
	var/safety_enabled = TRUE

/obj/machinery/door/window/elevator/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	INVOKE_ASYNC(src, PROC_REF(open))
	GLOB.elevator_doors += src

/obj/machinery/door/window/elevator/Destroy()
	GLOB.elevator_doors -= src
	return ..()

/obj/machinery/door/window/elevator/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null
	if(!safety_enabled)
		open_and_close()
	else if(allowed(user))
		open()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/elevator/proc/cycle_doors(command)
	switch(command)
		if(OPEN_DOORS)
			if(!obj_flags & EMAGGED)
				safety_enabled = TRUE
			open_and_close()
		if(CLOSE_DOORS)
			if(!density)
				if(!close())
					return FALSE
			if(!obj_flags & EMAGGED)
				safety_enabled = TRUE

/obj/machinery/door/window/elevator/open_and_close()
	if(!open())
		return
	autoclose = TRUE
	sleep(7 SECONDS)
	if(!density && autoclose) // in case something happened
		close()
