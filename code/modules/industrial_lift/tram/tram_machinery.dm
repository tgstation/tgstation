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
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/datum/lift_master/tram/tram_lift = tram_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_lift?.travelling
	data["broken"] = tram_lift ? FALSE : TRUE
	var/obj/effect/landmark/tram/current_loc = tram_lift?.from_where
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
		this_destination["id"] = destination.destination_id
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			var/obj/effect/landmark/tram/to_where
			for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[specific_lift_id])
				if(destination.destination_id == params["destination"])
					to_where = destination
					break

			if (!to_where)
				return FALSE

			return try_send_tram(to_where)

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(obj/effect/landmark/tram/to_where)
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!tram_part)
		return FALSE
	if(tram_part.controls_locked || tram_part.travelling) // someone else started already
		return FALSE
	tram_part.tram_travel(to_where)
	say("The next station is: [to_where.name]")
	update_appearance()
	return TRUE

/obj/machinery/computer/tram_controls/proc/update_tram_display(obj/effect/landmark/tram/from_where, travelling)
	SIGNAL_HANDLER
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(travelling)
		icon_screen = "[base_icon_state][tram_part.from_where.name]_active"
	else
		icon_screen = "[base_icon_state][tram_part.from_where.name]_idle"
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
					xing.set_signal_state(XING_STATE_AMBER, TRUE)
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

/obj/item/circuit_component/tram_controls/proc/on_tram_travel(datum/source, obj/effect/landmark/tram/from_where, obj/effect/landmark/tram/to_where)
	SIGNAL_HANDLER
	location.set_output(to_where.name)

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
	light_color = COLOR_VIBRANT_LIME
	luminosity = 1

	/// green, amber, or red.
	var/signal_state = XING_STATE_GREEN
	/// The ID of the tram we control
	var/tram_id = MAIN_STATION_TRAM
	/// Weakref to the tram piece we control
	var/datum/weakref/tram_ref
	/// Proximity threshold for amber warning (slow people may be in danger).
	/// This is specific to Tramstation and may need to be adjusted if the map changes in the distance between tram stops.
	var/amber_distance_threshold = 45
	/** Proximity threshold for red warning (running people will likely not be able to cross) This is specific to Tramstation and may need to be adjusted if the map changes in the distance between tram stops.
	* This checks the distance between the tram and the signal, and based on the current Tramstation map this is the optimal number to prevent the lights from turning red for no reason for a few moments.
	* If the value is set too high, it will cause the lights to turn red when the tram arrives at another station. You want to optimize the amount of warning without turning it red unnessecarily.
	*/
	var/red_distance_threshold = 33
	/// If the signal is facing east or west
	var/signal_direction
	/// Are we malfunctioning?
	var/malfunctioning = FALSE

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

/obj/machinery/crossing_signal/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	balloon_alert(user, "disabled motion sensors")
	if(signal_state != XING_STATE_MALF)
		set_signal_state(XING_STATE_MALF)
	obj_flags |= EMAGGED

/obj/machinery/crossing_signal/proc/start_malfunction()
	if(signal_state != XING_STATE_MALF)
		malfunctioning = TRUE
		set_signal_state(XING_STATE_MALF)

/obj/machinery/crossing_signal/proc/end_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = FALSE
	process()

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
	if(!tram || !is_operational || !tram.is_operational)
		// Tram missing, or we lost power.
		// Tram missing throw the error message (blue)
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
	var/approach_distance = tram_velocity_sign * (signal_pos - tram_pos)

	// Check for stopped state.
	// Will kill the process since tram starting up will restart process.
	if(!tram.travelling)
		// If super close, show red anyway since tram could suddenly start moving. If the tram could be approaching, show amber.
		if(abs(approach_distance) < red_distance_threshold)
			set_signal_state(XING_STATE_RED)
			return PROCESS_KILL
		if(abs(approach_distance) < amber_distance_threshold)
			set_signal_state(XING_STATE_AMBER)
			return PROCESS_KILL
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Check if tram is driving away from us.
	if(approach_distance < 0)
		// driving away. Green. In fact, in order to reverse, it'll have to stop, so let's go ahead and kill.
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// OK so finally the interesting part where it's ACTUALLY approaching
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
			new_color = COLOR_BRIGHT_BLUE
		if(XING_STATE_GREEN)
			new_color = COLOR_VIBRANT_LIME
		if(XING_STATE_AMBER)
			new_color = COLOR_YELLOW
		else
			new_color = COLOR_RED

	set_light(l_on = TRUE, l_color = new_color)

/obj/machinery/crossing_signal/update_overlays()
	. = ..()

	if(!is_operational)
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

/// Shifted to NE corner for east side of northern passage.
/obj/machinery/crossing_signal/northeast
	icon_state = "crossing-base-left"
	signal_direction = XING_SIGNAL_DIRECTION_EAST
	amber_distance_threshold = 35
	pixel_x = -2
	pixel_y = -1

/// Shifted to NW corner for west side of northern passage.
/obj/machinery/crossing_signal/northwest
	icon_state = "crossing-base-right"
	signal_direction = XING_SIGNAL_DIRECTION_WEST
	pixel_x = -32
	pixel_y = -1

/// Shifted to SE corner for east side of northern passage.
/obj/machinery/crossing_signal/southeast
	icon_state = "crossing-base-left"
	signal_direction = XING_SIGNAL_DIRECTION_EAST
	amber_distance_threshold = 35
	pixel_x = -2
	pixel_y = 20

/// Shifted to SW corner for west side of northern passage.
/obj/machinery/crossing_signal/southwest
	icon_state = "crossing-base-right"
	signal_direction = XING_SIGNAL_DIRECTION_WEST
	pixel_x = -32
	pixel_y = 20

/obj/machinery/static_signal/northeast
	icon_state = "static-left-on"
	pixel_x = -2
	pixel_y = -1

/// Shifted to NW corner for west side of northern passage.
/obj/machinery/static_signal/northwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = -1

/// Shifted to SE corner for east side of northern passage.
/obj/machinery/static_signal/southeast
	icon_state = "static-left-on"
	pixel_x = -2
	pixel_y = 20

/// Shifted to SW corner for west side of northern passage.
/obj/machinery/static_signal/southwest
	icon_state = "static-right-on"
	base_icon_state = "static-right-"
	pixel_x = -32
	pixel_y = 20

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

/obj/machinery/destination_sign/north
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/south
	plane = WALL_PLANE_UPPER
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/indicator
	icon_state = "indicator_central_idle"
	base_icon_state = "indicator_"

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
	process()

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
		update_appearance()
		return PROCESS_KILL

	use_power(active_power_usage)

	if(!tram.travelling)
		if(istype(tram.from_where, /obj/effect/landmark/tram/left_part))
			icon_state = "[base_icon_state][DESTINATION_WEST_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.from_where, /obj/effect/landmark/tram/middle_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.from_where, /obj/effect/landmark/tram/right_part))
			icon_state = "[base_icon_state][DESTINATION_EAST_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/left_part))
		icon_state = "[base_icon_state][DESTINATION_WEST_ACTIVE]"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/middle_part))
		if(istype(previous_destination, /obj/effect/landmark/tram/left_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]"
		if(istype(previous_destination, /obj/effect/landmark/tram/right_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/right_part))
		icon_state = "[base_icon_state][DESTINATION_EAST_ACTIVE]"
		update_appearance()
		return PROCESS_KILL

/obj/machinery/door/window/tram
	name = "tram door"
	desc = "Probably won't crush you if you try to rush them as they close. But we know you live on that danger, try and beat the tram!"
	icon = 'icons/obj/doors/tramdoor.dmi'
	var/associated_lift = MAIN_STATION_TRAM
	var/datum/weakref/tram_ref
	/// Directions the tram door can be forced open in an emergency
	var/space_dir = null
	var/malfunctioning = FALSE

/obj/machinery/door/window/tram/left
	icon_state = "left"
	base_state = "left"

/obj/machinery/door/window/tram/left/directional/south
	plane = WALL_PLANE_UPPER

/obj/machinery/door/window/tram/right
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/tram/hilbert
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	associated_lift = HILBERT_TRAM
	icon_state = "windoor"
	base_state = "windoor"

/obj/machinery/door/window/tram/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	balloon_alert(user, "disabled motion sensors")
	obj_flags |= EMAGGED

/obj/machinery/door/window/tram/proc/start_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = TRUE
	process()

/obj/machinery/door/window/tram/proc/end_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = FALSE
	process()

/obj/machinery/door/window/tram/proc/cycle_doors(command, forced=FALSE)
	if(command == "open" && icon_state == "[base_state]open")
		if(!forced)
			if(!hasPower())
				return 0
		return 1
	if(command == "close" && icon_state == base_state)
		return 1
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	switch(command)
		if("open")
			do_animate("opening")
			icon_state ="[base_state]open"
			sleep(7 DECISECONDS)
			set_density(FALSE)
			air_update_turf(TRUE, FALSE)
		if("close")
			if(obj_flags & EMAGGED | malfunctioning)
				flick("[base_state]spark", src)
				playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				sleep(6 DECISECONDS)
			do_animate("closing")
			icon_state = base_state
			sleep(19 DECISECONDS)
			if(obj_flags & EMAGGED | malfunctioning)
				if(malfunctioning && prob(85))
					return
				for(var/i=1 to 3)
					for(var/mob/living/crushee in get_turf(src))
						crush()
					sleep(2 DECISECONDS)
			air_update_turf(TRUE, TRUE)
			operating = FALSE
			set_density(TRUE)

	update_freelook_sight()
	return 1

//When the tram is in station, the doors are locked to engineering and command only.
/obj/machinery/door/window/tram/lock()
	req_access = list("engineering")

/obj/machinery/door/window/tram/unlock()
	req_access = null

/obj/machinery/door/window/tram/right/directional/south
	plane = WALL_PLANE_UPPER

/obj/machinery/door/window/tram/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == associated_lift)
			tram_ref = WEAKREF(lift)

/obj/machinery/door/window/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	INVOKE_ASYNC(src, PROC_REF(open))
	GLOB.tram_doors += src
	find_tram()

/obj/machinery/door/window/tram/Destroy()
	GLOB.tram_doors -= src
	return ..()

/obj/machinery/door/window/tram/examine(mob/user)
	. = ..()
	. += span_notice("It has labels indicating that it has an emergency mechanism to open from the inside using <b>just your hands</b> in the event of an emergency.")

/obj/machinery/door/window/tram/try_safety_unlock(mob/user)
	if(!hasPower()  && density)
		to_chat(user, span_notice("You begin pulling the tram emergency exit handle..."))
		if(do_after(user, 15 SECONDS, target = src))
			try_to_crowbar(null, user, TRUE)
			return TRUE

/obj/machinery/door/window/tram/open_and_close()
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!open())
		return
	if(tram_part.travelling) //making a daring exit midtravel? make sure the doors don't go in the wrong state on arrival.
		return PROCESS_KILL

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/right, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/tram_controls, 0)
