GLOBAL_LIST_EMPTY(tram_signals)
GLOBAL_LIST_EMPTY(tram_signs)
GLOBAL_LIST_EMPTY(tram_doors)

/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_state = "tram_controls"
	base_icon_state = "tram_"
	icon_screen = "tram_Central Wing_idle"
	icon_keyboard = null
	layer = SIGN_LAYER
	density = FALSE
	circuit = /obj/item/circuitboard/computer/tram_controls
	flags_1 = NODECONSTRUCT_1 | SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_SET_MACHINE
	light_color = COLOR_BLUE_LIGHT
	light_range = 0 //we dont want to spam SSlighting with source updates every movement

	///Weakref to the tram piece we control
	var/datum/weakref/tram_ref

	var/specific_lift_id = MAIN_STATION_TRAM

/obj/machinery/computer/tram_controls/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/tram_controls))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/tram_controls/LateInitialize()
	. = ..()
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(update_tram_display))
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_idle"
		update_appearance(UPDATE_ICON)

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/tram_controls/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == specific_lift_id)
			tram_ref = WEAKREF(lift)

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/tram_controls/ui_status(mob/user,/datum/tgui/ui)
	var/datum/lift_master/tram/tram = tram_ref?.resolve()

	if(tram?.travelling)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/tram_controls/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!user.can_read(src, reading_check_flags = READING_CHECK_LITERACY))
		try_illiterate_movement(user)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/// Traverse to a random location after some time
/obj/machinery/computer/tram_controls/proc/try_illiterate_movement(mob/user)
	var/datum/lift_master/tram/tram_lift = tram_ref?.resolve()
	if (!tram_lift || tram_lift.travelling)
		return
	user.visible_message(span_notice("[user] starts mashing buttons at random!"))
	if(!do_after(user, 5 SECONDS, target = src))
		return
	if (!tram_lift || tram_lift.travelling)
		to_chat(user, span_warning("The screen displays a flashing error message, but you can't comprehend it."))
		return // Broke or started moving during progress bar
	var/list/all_destinations = GLOB.tram_landmarks[specific_lift_id] || list()
	var/list/possible_destinations = all_destinations.Copy() - tram_lift.idle_platform
	if (!length(possible_destinations))
		to_chat(user, span_warning("The screen displays a flashing error message, but you can't comprehend it."))
		return // No possible places to end up
	try_send_tram(pick(possible_destinations))

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/datum/lift_master/tram/tram_lift = tram_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_lift?.travelling
	data["broken"] = tram_lift ? FALSE : TRUE
	var/obj/effect/landmark/tram/current_loc = tram_lift?.idle_platform
	if(current_loc)
		data["tram_location"] = current_loc.name
	return data

/obj/machinery/computer/tram_controls/ui_static_data(mob/user)
	var/list/data = list()
	data["destinations"] = get_destinations()
	return data

/**
 * Finds the destinations for the tram console gui
 *
 * Pulls tram landmarks from the landmark gobal list
 * and uses those to show the proper icons and destination
 * names for the tram console gui.
 */
/obj/machinery/computer/tram_controls/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[specific_lift_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			var/obj/effect/landmark/tram/destination_platform
			for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[specific_lift_id])
				if(destination.platform_code == params["destination"])
					destination_platform = destination
					break

			if (!destination_platform)
				return FALSE

			return try_send_tram(destination_platform)

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(obj/effect/landmark/tram/destination_platform)
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!tram_part)
		return FALSE
	if(tram_part.controls_locked || tram_part.travelling) // someone else started already
		return FALSE
	if(!tram_part.tram_travel(destination_platform))
		return FALSE // lift_master failure
	say("The next station is: [destination_platform.name]")
	update_appearance()
	return TRUE

/obj/machinery/computer/tram_controls/proc/update_tram_display(obj/effect/landmark/tram/idle_platform, travelling)
	SIGNAL_HANDLER
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(travelling)
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_active"
	else
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_idle"
	update_appearance(UPDATE_ICON)
	return PROCESS_KILL

/obj/machinery/computer/tram_controls/power_change() // Change tram operating status on power loss/recovery
	. = ..()
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	update_operating()
	if(tram_part)
		if(!tram_part.travelling)
			if(is_operational)
				for(var/obj/machinery/crossing_signal/xing as anything in GLOB.tram_signals)
					xing.set_signal_state(XING_STATE_MALF, TRUE)
				for(var/obj/machinery/destination_sign/desto as anything in GLOB.tram_signs)
					desto.icon_state = "[desto.base_icon_state][DESTINATION_OFF]"
					desto.update_appearance()
			else
				for(var/obj/machinery/crossing_signal/xing as anything in GLOB.tram_signals)
					xing.set_signal_state(XING_STATE_MALF, TRUE)
				for(var/obj/machinery/destination_sign/desto as anything in GLOB.tram_signs)
					desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"
					desto.update_appearance()

/obj/machinery/computer/tram_controls/proc/update_operating() // Pass the operating status from the controls to the lift_master
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		if(machine_stat & NOPOWER)
			tram_part.is_operational = FALSE
		else
			tram_part.is_operational = TRUE

/obj/item/circuit_component/tram_controls
	display_name = "Tram Controls"

	/// The destination to go
	var/datum/port/input/new_destination

	/// The trigger to send the tram
	var/datum/port/input/trigger_move

	/// The current location
	var/datum/port/output/location

	/// Whether or not the tram is moving
	var/datum/port/output/travelling_output

	/// The tram controls computer (/obj/machinery/computer/tram_controls)
	var/obj/machinery/computer/tram_controls/computer

/obj/item/circuit_component/tram_controls/populate_ports()
	new_destination = add_input_port("Destination", PORT_TYPE_STRING, trigger = null)
	trigger_move = add_input_port("Send Tram", PORT_TYPE_SIGNAL)

	location = add_output_port("Location", PORT_TYPE_STRING)
	travelling_output = add_output_port("Travelling", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tram_controls/register_usb_parent(atom/movable/shell)
	. = ..()
	if (istype(shell, /obj/machinery/computer/tram_controls))
		computer = shell
		var/datum/lift_master/tram/tram_part = computer.tram_ref?.resolve()
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(on_tram_set_travelling))
		RegisterSignal(tram_part, COMSIG_TRAM_TRAVEL, PROC_REF(on_tram_travel))

/obj/item/circuit_component/tram_controls/unregister_usb_parent(atom/movable/shell)
	var/datum/lift_master/tram/tram_part = computer.tram_ref?.resolve()
	computer = null
	UnregisterSignal(tram_part, list(COMSIG_TRAM_SET_TRAVELLING, COMSIG_TRAM_TRAVEL))
	return ..()

/obj/item/circuit_component/tram_controls/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(trigger_move, port))
		return

	if (isnull(computer))
		return

	if (!computer.powered())
		return

	var/destination
	for(var/obj/effect/landmark/tram/possible_destination as anything in GLOB.tram_landmarks[computer.specific_lift_id])
		if(possible_destination.name == new_destination.value)
			destination = possible_destination
			break

	if (!destination)
		return

	computer.try_send_tram(destination)

/obj/item/circuit_component/tram_controls/proc/on_tram_set_travelling(datum/source, travelling)
	SIGNAL_HANDLER
	travelling_output.set_output(travelling)

/obj/item/circuit_component/tram_controls/proc/on_tram_travel(datum/source, obj/effect/landmark/tram/idle_platform, obj/effect/landmark/tram/destination_platform)
	SIGNAL_HANDLER
	location.set_output(destination_platform.name)

/// Pedestrian crossing signal for tram
/obj/machinery/crossing_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/crossing_signal.dmi'
	base_icon_state = "crossing-"
	plane = GAME_PLANE_UPPER
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.74
	anchored = TRUE
	density = FALSE
	// pointless if it only takes 2 seconds to cross but updates every 2 seconds
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	light_range = 1.5
	light_power = 3
	light_color = LIGHT_COLOR_BABY_BLUE
	luminosity = 1

	/// green, amber, or red for tram, blue if it's emag, tram missing, etc.
	var/signal_state = XING_STATE_MALF
	/// The ID of the tram we control
	var/tram_id = MAIN_STATION_TRAM
	/// Weakref to the tram piece we control
	var/datum/weakref/tram_ref

	/** Proximity thresholds for crossing signal states
	*
	* The proc that checks the distance between the tram and crossing signal uses these vars to determine the distance between tram and signal to change
	* colors. The numbers are specifically set for Tramstation. If we get another map with crossing signals we'll have to probably subtype it or something.
	* If the value is set too high, it will cause the lights to turn red when the tram arrives at another station. You want to optimize the amount of
	* warning without turning it red unnessecarily.
	*
	* Red: decent chance of getting hit, but if you're quick it's a decent gamble.
	* Amber: slow people may be in danger.
	*/
	var/amber_distance_threshold = XING_DISTANCE_AMBER
	var/red_distance_threshold = XING_DISTANCE_RED
	/// If the signal is facing east or west
	var/signal_direction
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// Is the signal malfunctioning?
	var/malfunctioning = FALSE

/** Crossing signal subtypes
 *
 *  Each map will have a different amount of tiles between stations, so adjust the signals here based on the map.
 *  The distance is calculated from the bottom left corner of the tram,
 *  so signals on the east side have their distance reduced by the tram length, in this case 10 for Tramstation.
*/
/obj/machinery/crossing_signal/northwest
	icon_state = "crossing-base-right"
	signal_direction = XING_SIGNAL_DIRECTION_WEST
	pixel_x = -32
	pixel_y = -1

/obj/machinery/crossing_signal/northeast
	icon_state = "crossing-base-left"
	signal_direction = XING_SIGNAL_DIRECTION_EAST
	pixel_x = -2
	pixel_y = -1

/obj/machinery/crossing_signal/southwest
	icon_state = "crossing-base-right"
	signal_direction = XING_SIGNAL_DIRECTION_WEST
	pixel_x = -32
	pixel_y = 20

/obj/machinery/crossing_signal/southeast
	icon_state = "crossing-base-left"
	signal_direction = XING_SIGNAL_DIRECTION_EAST
	pixel_x = -2
	pixel_y = 20

/obj/machinery/static_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/crossing_signal.dmi'
	icon_state = "static-left-on"
	base_icon_state = "static-left-"
	plane = GAME_PLANE_UPPER
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.74
	anchored = TRUE
	density = FALSE
	light_range = 1.5
	light_power = 3
	light_color = COLOR_VIBRANT_LIME
	luminosity = 1

/obj/machinery/static_signal/northwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = -1

/obj/machinery/static_signal/northeast
	pixel_x = -2
	pixel_y = -1

/obj/machinery/static_signal/southwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = 20

/obj/machinery/static_signal/southeast
	pixel_x = -2
	pixel_y = 20

/obj/machinery/crossing_signal/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/crossing_signal/LateInitialize()
	. = ..()
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(on_tram_travelling))
		GLOB.tram_signals += src

/obj/machinery/crossing_signal/Destroy()
	GLOB.tram_signals -= src
	. = ..()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		UnregisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING)

/obj/machinery/crossing_signal/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "disabled motion sensors")
	if(signal_state != XING_STATE_MALF)
		set_signal_state(XING_STATE_MALF)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/crossing_signal/proc/start_malfunction()
	if(signal_state != XING_STATE_MALF)
		malfunctioning = TRUE
		set_signal_state(XING_STATE_MALF)

/obj/machinery/crossing_signal/proc/end_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = FALSE
	process()

/obj/machinery/crossing_signal/proc/temp_malfunction()
	start_malfunction()
	addtimer(CALLBACK(src, PROC_REF(end_malfunction)), 15 SECONDS)

/**
 * Finds the tram, just like the tram computer
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/crossing_signal/proc/find_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/**
 * Only process if the tram is actually moving
 */
/obj/machinery/crossing_signal/proc/on_tram_travelling(datum/source, travelling)
	SIGNAL_HANDLER

	update_operating()

/obj/machinery/crossing_signal/on_set_is_operational()
	. = ..()

	update_operating()

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/crossing_signal/proc/update_operating()

	use_power(idle_power_usage)

	// Emagged crossing signals don't update
	if(obj_flags & EMAGGED)
		return
	// Malfunctioning signals don't update
	if(malfunctioning)
		return
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/crossing_signal/process()

	var/datum/lift_master/tram/tram = tram_ref?.resolve()

	// Check for stopped states.
	if(!tram || !is_operational || !tram.is_operational || !inbound || !outbound)
		// Tram missing, we lost power, or something isn't right
		// Throw the error message (blue)
		set_signal_state(XING_STATE_MALF, force = !is_operational)
		return PROCESS_KILL

	use_power(active_power_usage)

	var/obj/structure/industrial_lift/tram/tram_part = tram.return_closest_platform_to(src)

	if(QDELETED(tram_part))
		set_signal_state(XING_STATE_MALF, force = !is_operational)
		return PROCESS_KILL

	// Everything will be based on position and travel direction
	var/signal_pos
	var/tram_pos
	var/tram_velocity_sign // 1 for positive axis movement, -1 for negative
	// Try to be agnostic about N-S vs E-W movement
	if(tram.travel_direction & (NORTH|SOUTH))
		signal_pos = y
		tram_pos = tram_part.y
		tram_velocity_sign = tram.travel_direction & NORTH ? 1 : -1
	else
		signal_pos = x
		tram_pos = tram_part.x
		tram_velocity_sign = tram.travel_direction & EAST ? 1 : -1

	// How far away are we? negative if already passed.
	var/approach_distance = tram_velocity_sign * (signal_pos - (tram_pos + (XING_DEFAULT_TRAM_LENGTH * 0.5)))

	// Check for stopped state.
	// Will kill the process since tram starting up will restart process.
	if(!tram.travelling)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Check if tram is driving away from us.
	if(approach_distance < 0)
		// driving away. Green. In fact, in order to reverse, it'll have to stop, so let's go ahead and kill.
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Check the tram's terminus station.
	// INBOUND 1 < 2 < 3
	// OUTBOUND 1 > 2 > 3
	if(tram.travel_direction & WEST && inbound < tram.idle_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL
	if(tram.travel_direction & EAST && outbound > tram.idle_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Finally the interesting part where it's ACTUALLY approaching
	if(approach_distance <= red_distance_threshold)
		set_signal_state(XING_STATE_RED)
		return
	if(approach_distance <= amber_distance_threshold)
		set_signal_state(XING_STATE_AMBER)
		return
	set_signal_state(XING_STATE_GREEN)

/**
 * Set the signal state and update appearance.
 *
 * Arguments:
 * new_state - the new state (XING_STATE_RED, etc)
 * force_update - force appearance to update even if state didn't change.
 */
/obj/machinery/crossing_signal/proc/set_signal_state(new_state, force = FALSE)
	if(new_state == signal_state && !force)
		return

	signal_state = new_state
	update_appearance()

/obj/machinery/crossing_signal/update_appearance(updates)
	. = ..()

	if(!is_operational)
		set_light(l_on = FALSE)
		return

	var/new_color
	switch(signal_state)
		if(XING_STATE_MALF)
			new_color = LIGHT_COLOR_BABY_BLUE
		if(XING_STATE_GREEN)
			new_color = LIGHT_COLOR_VIVID_GREEN
		if(XING_STATE_AMBER)
			new_color = LIGHT_COLOR_BRIGHT_YELLOW
		else
			new_color = LIGHT_COLOR_FLARE

	set_light(l_on = TRUE, l_color = new_color)

/obj/machinery/crossing_signal/update_overlays()
	. = ..()

	if(!is_operational)
		return

	if(!signal_direction) //Base type doesnt have directions set
		return

	var/lights_overlay = "[base_icon_state][signal_direction][signal_state]"

	. += mutable_appearance(icon, lights_overlay)
	. += emissive_appearance(icon, "[lights_overlay]e", offset_spokesman = src, alpha = src.alpha)

/obj/machinery/static_signal/power_change()
	..()
	if(!is_operational)
		icon_state = "[base_icon_state]off"
		set_light(l_on = FALSE)
		return

	icon_state = "[base_icon_state]on"
	set_light(l_on = TRUE)

/obj/machinery/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	/// The ID of the tram we're indicating
	var/tram_id = MAIN_STATION_TRAM
	/// Weakref to the tram piece we indicate
	var/datum/weakref/tram_ref
	/// The last destination we were at
	var/previous_destination
	/// The light mask overlay we use
	var/light_mask
	/// Is this sign malfunctioning?
	var/malfunctioning = FALSE
	/// A default list of possible sign states
	var/static/list/sign_states = list()

/obj/machinery/destination_sign/north
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/south
	plane = WALL_PLANE_UPPER
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/indicator
	icon_state = "indicator_off"
	base_icon_state = "indicator_"
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE
	light_mask = "indicator_off_e"

/obj/machinery/destination_sign/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/destination_sign/LateInitialize()
	. = ..()
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(on_tram_travelling))
		GLOB.tram_signs += src

	sign_states = list(
		"[DESTINATION_WEST_ACTIVE]",
		"[DESTINATION_WEST_IDLE]",
		"[DESTINATION_EAST_ACTIVE]",
		"[DESTINATION_EAST_IDLE]",
		"[DESTINATION_CENTRAL_IDLE]",
		"[DESTINATION_CENTRAL_EASTBOUND_ACTIVE]",
		"[DESTINATION_CENTRAL_WESTBOUND_ACTIVE]",
	)

/obj/machinery/destination_sign/Destroy()
	GLOB.tram_signs -= src
	. = ..()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		UnregisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING)

/obj/machinery/destination_sign/proc/find_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/destination_sign/proc/on_tram_travelling(datum/source, travelling)
	SIGNAL_HANDLER
	update_sign()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, process))

/obj/machinery/destination_sign/proc/update_operating()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/destination_sign/proc/update_sign()
	var/datum/lift_master/tram/tram = tram_ref?.resolve()

	if(!tram || !tram.is_operational)
		icon_state = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]"
		light_mask = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]_e"
		update_appearance()
		return PROCESS_KILL

	use_power(active_power_usage)

	if(malfunctioning)
		icon_state = "[base_icon_state][pick(sign_states)]"
		light_mask = "[base_icon_state][pick(sign_states)]_e"
		update_appearance()
		return PROCESS_KILL

	if(!tram.travelling)
		if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/west))
			icon_state = "[base_icon_state][DESTINATION_WEST_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_WEST_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/central))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/east))
			icon_state = "[base_icon_state][DESTINATION_EAST_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_EAST_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

	if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/west))
		icon_state = "[base_icon_state][DESTINATION_WEST_ACTIVE]"
		light_mask = "[base_icon_state][DESTINATION_WEST_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/central))
		if(istype(previous_destination, /obj/effect/landmark/tram/platform/tramstation/west))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]_e"
		if(istype(previous_destination, /obj/effect/landmark/tram/platform/tramstation/east))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.idle_platform, /obj/effect/landmark/tram/platform/tramstation/east))
		icon_state = "[base_icon_state][DESTINATION_EAST_ACTIVE]"
		light_mask = "[base_icon_state][DESTINATION_EAST_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

/obj/machinery/destination_sign/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

/obj/machinery/button/tram
	name = "tram request"
	desc = "A button for calling the tram. It has a speakerbox in it with some internals."
	base_icon_state = "tram"
	icon_state = "tram"
	light_color = LIGHT_COLOR_DARK_BLUE
	can_alter_skin = FALSE
	device_type = /obj/item/assembly/control/tram
	req_access = list()
	id = 1
	/// The specific lift id of the tram we're calling.
	var/lift_id = MAIN_STATION_TRAM

/obj/machinery/button/tram/setup_device()
	var/obj/item/assembly/control/tram/tram_device = device
	tram_device.initial_id = id
	tram_device.specific_lift_id = lift_id
	return ..()

/obj/machinery/button/tram/examine(mob/user)
	. = ..()
	. += span_notice("There's a small inscription on the button...")
	. += span_notice("THIS CALLS THE TRAM! IT DOES NOT OPERATE IT! The console on the tram tells it where to go!")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/tram_controls, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/destination_sign/indicator, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/tram, 32)
