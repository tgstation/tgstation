#define XING_STATE_GREEN 0
#define XING_STATE_AMBER 1
#define XING_STATE_RED 2
#define XING_STATE_MALF 3
#define XING_SIGNAL_DIRECTION_WEST "west-"
#define XING_SIGNAL_DIRECTION_EAST "east-"

GLOBAL_LIST_EMPTY(tram_signals)

/// Pedestrian crossing signal for tram
/obj/machinery/crossing_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/crossing_signal.dmi'
	base_icon_state = "crossing-"
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	anchored = TRUE
	density = FALSE
	// pointless if it only takes 2 seconds to cross but updates every 2 seconds
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	light_range = 1.5
	light_power = 1
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
	var/amber_distance_threshold = 60
	/** Proximity threshold for red warning (running people will likely not be able to cross) This is specific to Tramstation and may need to be adjusted if the map changes in the distance between tram stops.
	* This checks the distance between the tram and the signal, and based on the current Tramstation map this is the optimal number to prevent the lights from turning red for no reason for a few moments.
	* If the value is set too high, it will cause the lights to turn red when the tram arrives at another station. You want to optimize the amount of warning without turning it red unnessecarily.
	*/
	var/red_distance_threshold = 33
	/// If the signal is facing east or west
	var/signal_direction
	/// Are we malfunctioning?
	var/malfunctioning = FALSE

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
	if(!tram || !is_operational)
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

/// Shifted to NE corner for east side of northern passage.
/obj/machinery/crossing_signal/northeast
	icon_state = "crossing-base-left"
	signal_direction = XING_SIGNAL_DIRECTION_EAST
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
	pixel_x = -2
	pixel_y = 20

/// Shifted to SW corner for west side of northern passage.
/obj/machinery/crossing_signal/southwest
	icon_state = "crossing-base-right"
	signal_direction = XING_SIGNAL_DIRECTION_WEST
	pixel_x = -32
	pixel_y = 20

#undef XING_STATE_GREEN
#undef XING_STATE_AMBER
#undef XING_STATE_RED
