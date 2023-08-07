/// Pedestrian crossing signal for tram
/obj/machinery/icts/crossing_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/tram/crossing_signal.dmi'
	icon_state = "crossing-signal"
	base_icon_state = "crossing-"
	plane = GAME_PLANE_UPPER
	layer = TRAM_SIGNAL_LAYER
	max_integrity = 250
	integrity_failure = 0.25
	light_range = 2
	light_power = 0.7
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.74
	anchored = TRUE
	density = FALSE
	circuit = /obj/item/circuitboard/machine/crossing_signal
	// pointless if it only takes 2 seconds to cross but updates every 2 seconds
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	light_color = LIGHT_COLOR_BABY_BLUE
	luminosity = 1
	/// green, amber, or red for tram, blue if it's emag, tram missing, etc.
	var/signal_state = XING_STATE_MALF
	/// The ID of the tram we control
	var/tram_id = TRAMSTATION_LINE_1
	/// Weakref to the tram we're tracking
	var/datum/weakref/tram_ref
	/// the sensor we use
	var/obj/machinery/icts/guideway_sensor/linked_sensor
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// If us or anything else in the operation chain is broken
	var/operating_status = ICTS_SYSTEM_NORMAL
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
	var/amber_distance_threshold = AMBER_THRESHOLD_NORMAL
	var/red_distance_threshold = RED_THRESHOLD_NORMAL

/obj/machinery/icts/crossing_signal/attackby(obj/item/weapon, mob/living/user, params)
	if (!user.combat_mode)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
			return

		if(default_deconstruction_crowbar(weapon))
			return

	return ..()

/** Crossing signal subtypes
 *
 *  Each map will have a different amount of tiles between stations, so adjust the signals here based on the map.
 *  The distance is calculated from the bottom left corner of the tram,
 *  so signals on the east side have their distance reduced by the tram length, in this case 10 for Tramstation.
*/
/obj/machinery/icts/crossing_signal/northwest
	dir = WEST

/obj/machinery/icts/crossing_signal/northeast
	dir = EAST

/obj/machinery/icts/crossing_signal/southwest
	dir = WEST
	pixel_y = 20

/obj/machinery/icts/crossing_signal/southeast
	dir = EAST
	pixel_y = 20

/obj/machinery/static_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/machines/tram/crossing_signal.dmi'
	icon_state = "crossing-signal"
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
	dir = WEST

/obj/machinery/static_signal/northeast
	dir = EAST

/obj/machinery/static_signal/southwest
	dir = WEST
	pixel_y = 20

/obj/machinery/static_signal/southeast
	dir = EAST
	pixel_y = 20

/obj/machinery/icts/crossing_signal/Initialize(mapload)
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(wake_up))
	RegisterSignal(SSicts_transport, COMSIG_COMMS_STATUS, PROC_REF(comms_change))
	SSicts_transport.crossing_signals += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/icts/crossing_signal/LateInitialize(mapload)
	. = ..()
	find_tram()
	link_sensor(src)

/obj/machinery/icts/crossing_signal/Destroy()
	SSicts_transport.crossing_signals -= src
	. = ..()

/obj/machinery/icts/crossing_signal/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "disabled motion sensors")
	operating_status = ICTS_LOCAL_FAULT
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/icts/crossing_signal/proc/start_event_malfunction()
	if(operating_status == ICTS_SYSTEM_NORMAL)
		operating_status = ICTS_REMOTE_FAULT

/obj/machinery/icts/crossing_signal/proc/end_event_malfunction()
	if(operating_status == ICTS_REMOTE_FAULT)
		operating_status = ICTS_SYSTEM_NORMAL

/**
 * Finds the tram, just like the tram computer
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/icts/crossing_signal/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/icts/crossing_signal/proc/link_sensor()
	linked_sensor = return_closest_sensor(src)
	RegisterSignal(linked_sensor, COMSIG_QDELETING, PROC_REF(unlink_sensor))

/obj/machinery/icts/crossing_signal/proc/unlink_sensor()
	SIGNAL_HANDLER

	linked_sensor = null
	if(operating_status < ICTS_REMOTE_WARNING)
		operating_status = ICTS_REMOTE_WARNING
		degraded_response()

/obj/machinery/icts/crossing_signal/proc/wake_sensor()
	if(operating_status > ICTS_REMOTE_WARNING)
		degraded_response()
		return

	if(!linked_sensor)
		operating_status = ICTS_REMOTE_WARNING
		degraded_response()

	else if(linked_sensor.trigger_sensor())
		operating_status = ICTS_SYSTEM_NORMAL
		normal_response()

	else
		operating_status = ICTS_REMOTE_WARNING
		degraded_response()

/obj/machinery/icts/crossing_signal/proc/normal_response()
	amber_distance_threshold = AMBER_THRESHOLD_NORMAL
	red_distance_threshold = RED_THRESHOLD_NORMAL

/obj/machinery/icts/crossing_signal/proc/degraded_response()
	amber_distance_threshold = AMBER_THRESHOLD_DEGRADED
	red_distance_threshold = RED_THRESHOLD_DEGRADED

/**
 * Only process if the tram is actually moving
 */
/obj/machinery/icts/crossing_signal/proc/wake_up(datum/source, transport_controller, controller_active)
	SIGNAL_HANDLER

	if(machine_stat & BROKEN || machine_stat & NOPOWER)
		return

	if(prob(0.0175))
		local_fault()
		return

	operating_status = ICTS_SYSTEM_NORMAL

	var/datum/transport_controller/linear/tram/tram = tram_ref?.resolve()

	if(!tram || tram.controller_status & COMM_ERROR)
		operating_status = ICTS_REMOTE_FAULT

	if(!linked_sensor)
		link_sensor()
	wake_sensor()
	update_operating()

/obj/machinery/icts/crossing_signal/on_set_machine_stat()
	. = ..()
	if(machine_stat & BROKEN)
		operating_status = ICTS_REMOTE_FAULT
	else
		operating_status = ICTS_SYSTEM_NORMAL

/obj/machinery/icts/crossing_signal/on_set_is_operational()
	. = ..()

	update_operating()

/obj/machinery/icts/crossing_signal/proc/comms_change(source, controller, new_status)
	SIGNAL_HANDLER

	switch(new_status)
		if(TRUE)
			if(operating_status == ICTS_REMOTE_FAULT)
				operating_status = ICTS_SYSTEM_NORMAL
		if(FALSE)
			if(operating_status == ICTS_SYSTEM_NORMAL)
				operating_status = ICTS_REMOTE_FAULT

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/icts/crossing_signal/proc/update_operating()
	use_power(idle_power_usage)
	update_appearance()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/icts/crossing_signal/process()

	var/datum/transport_controller/linear/tram/tram = tram_ref?.resolve()

	// Check for stopped states.
	if(!tram || !tram.controller_operational || !is_operational || !inbound || !outbound)
		// Tram missing, we lost power, or something isn't right
		// Throw the error message (blue)
		set_signal_state(XING_STATE_MALF, force = !is_operational)
		return PROCESS_KILL

	use_power(active_power_usage)

	var/obj/structure/transport/linear/tram_part = tram.return_closest_platform_to(src)

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
	var/approach_distance = tram_velocity_sign * (signal_pos - (tram_pos + (DEFAULT_TRAM_LENGTH * 0.5)))

	// Check for stopped state.
	// Will kill the process since tram starting up will restart process.
	if(!tram.controller_active)
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
	if(tram.travel_direction & WEST && inbound < tram.destination_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL
	if(tram.travel_direction & EAST && outbound > tram.destination_platform.platform_code)
		set_signal_state(XING_STATE_GREEN)
		return PROCESS_KILL

	// Finally the interesting part where it's ACTUALLY approaching
	if(approach_distance <= red_distance_threshold)
		if(operating_status != ICTS_SYSTEM_NORMAL)
			set_signal_state(XING_STATE_MALF)
		else
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
/obj/machinery/icts/crossing_signal/proc/set_signal_state(new_state, force = FALSE)
	if(new_state == signal_state && !force)
		return

	signal_state = new_state
	flick_overlay()
	update_appearance()

/obj/machinery/icts/crossing_signal/update_appearance(updates)
	. = ..()

	if(machine_stat & NOPOWER)
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

/obj/machinery/icts/crossing_signal/update_overlays()
	. = ..()

	if(machine_stat & NOPOWER)
		return

	if(machine_stat & BROKEN)
		operating_status = ICTS_LOCAL_FAULT

	var/lights_overlay = "[base_icon_state][signal_state]"
	var/status_overlay = "status-[operating_status]"

	. += mutable_appearance(icon, lights_overlay)
	. += mutable_appearance(icon, status_overlay)
	. += emissive_appearance(icon, lights_overlay, offset_spokesman = src, alpha = src.alpha)
	. += emissive_appearance(icon, status_overlay, offset_spokesman = src, alpha = src.alpha)

/obj/machinery/static_signal/power_change()
	..()

	if(!is_operational)
		set_light(l_on = FALSE)
		return

	set_light(l_on = TRUE)

/obj/machinery/static_signal/update_overlays()
	. = ..()

	if(!is_operational)
		return

	. += mutable_appearance(icon, "crossing-0")
	. += mutable_appearance(icon, "status-0")
	. += emissive_appearance(icon, "crossing-0", offset_spokesman = src, alpha = src.alpha)
	. += emissive_appearance(icon, "status-0", offset_spokesman = src, alpha = src.alpha)

/obj/machinery/icts/guideway_sensor
	name = "guideway sensor"
	icon = 'icons/obj/machines/tram/tram_sensor.dmi'
	icon_state = "sensor-base"
	layer = TRAM_RAIL_LAYER
	use_power = 0
	circuit = /obj/item/circuitboard/machine/guideway_sensor
	/// Keeps track of the signal's scanning equipment
	var/obj/item/stock_parts/scanning_module/attached_scanner = new /obj/item/stock_parts/scanning_module/adv()
	/// Sensors work in a married pair
	var/datum/weakref/paired_sensor

/obj/machinery/icts/guideway_sensor/Initialize(mapload)
	. = ..()
	SSicts_transport.sensors += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/icts/guideway_sensor/LateInitialize(mapload)
	. = ..()
	pair_sensor()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(wake_up))

/obj/machinery/icts/guideway_sensor/attackby(obj/item/weapon, mob/living/user, params)
	if (!user.combat_mode)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
			return

		if(default_deconstruction_crowbar(weapon))
			return

	return ..()

/obj/machinery/icts/guideway_sensor/proc/pair_sensor()
	set_machine_stat(machine_stat | MAINT)
	if(paired_sensor)
		var/obj/machinery/icts/guideway_sensor/divorcee = paired_sensor?.resolve()
		divorcee.set_machine_stat(machine_stat | MAINT)
		divorcee.paired_sensor = null
		divorcee.update_appearance()
		paired_sensor = null

	for(var/obj/machinery/icts/guideway_sensor/potential_sensor in SSicts_transport.sensors)
		if(potential_sensor == src)
			continue
		switch(potential_sensor.dir)
			if(NORTH, SOUTH)
				if(potential_sensor.x == src.x)
					paired_sensor = WEAKREF(potential_sensor)
					set_machine_stat(machine_stat & ~MAINT)
					break
			if(EAST, WEST)
				if(potential_sensor.y == src.y)
					paired_sensor = WEAKREF(potential_sensor)
					set_machine_stat(machine_stat & ~MAINT)
					break

	update_appearance()

	var/obj/machinery/icts/guideway_sensor/new_partner = paired_sensor?.resolve()
	new_partner.paired_sensor = WEAKREF(src)
	new_partner.set_machine_stat(machine_stat & ~MAINT)
	new_partner.update_appearance()
	playsound(src, 'sound/machines/synth_yes.ogg', 75, vary = FALSE, use_reverb = TRUE)

/obj/machinery/icts/guideway_sensor/Destroy()
	SSicts_transport.sensors -= src
	if(paired_sensor)
		var/obj/machinery/icts/guideway_sensor/divorcee = paired_sensor?.resolve()
		divorcee.set_machine_stat(machine_stat & ~MAINT)
		divorcee.paired_sensor = null
		divorcee.update_appearance()
		playsound(src, 'sound/machines/synth_no.ogg', 75, vary = FALSE, use_reverb = TRUE)
		paired_sensor = null
	. = ..()

/obj/machinery/icts/guideway_sensor/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return

	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "sensor-[ICTS_LOCAL_FAULT]")
		. += emissive_appearance(icon, "sensor-[ICTS_LOCAL_FAULT]", src, alpha = src.alpha)
		return

	if(machine_stat & MAINT)
		. += mutable_appearance(icon, "sensor-[ICTS_REMOTE_FAULT]")
		. += emissive_appearance(icon, "sensor-[ICTS_REMOTE_FAULT]", src, alpha = src.alpha)
		return

	var/obj/machinery/icts/guideway_sensor/buddy = paired_sensor?.resolve()
	if(buddy)
		if(!buddy.is_operational)
			. += mutable_appearance(icon, "sensor-[ICTS_REMOTE_WARNING]")
			. += emissive_appearance(icon, "sensor-[ICTS_REMOTE_WARNING]", src, alpha = src.alpha)
		else
			. += mutable_appearance(icon, "sensor-[ICTS_SYSTEM_NORMAL]")
			. += emissive_appearance(icon, "sensor-[ICTS_SYSTEM_NORMAL]", src, alpha = src.alpha)
			return

	else
		. += mutable_appearance(icon, "sensor-[ICTS_REMOTE_FAULT]")
		. += emissive_appearance(icon, "sensor-[ICTS_REMOTE_FAULT]", src, alpha = src.alpha)

/obj/machinery/icts/guideway_sensor/proc/trigger_sensor()
	var/obj/machinery/icts/guideway_sensor/buddy = paired_sensor?.resolve()
	if(!buddy)
		return FALSE

	if(!is_operational || !buddy.is_operational)
		return FALSE

	return TRUE

/obj/machinery/icts/guideway_sensor/proc/wake_up()
	SIGNAL_HANDLER

	if(machine_stat & BROKEN)
		return

	if(prob(0.0175))
		local_fault()

	var/obj/machinery/icts/guideway_sensor/buddy = paired_sensor?.resolve()

	if(buddy)
		set_machine_stat(machine_stat & ~MAINT)

	update_appearance()

/obj/machinery/icts/guideway_sensor/on_set_is_operational()
	. = ..()

	var/obj/machinery/icts/guideway_sensor/buddy = paired_sensor?.resolve()
	buddy.update_appearance()
	update_appearance()

/obj/machinery/icts/crossing_signal/proc/return_closest_sensor(obj/machinery/icts/crossing_signal/comparison, allow_multiple_answers = FALSE)
	if(!istype(comparison) || !comparison.z)
		return FALSE

	var/list/obj/machinery/icts/guideway_sensor/candidate_sensors = list()

	for(var/obj/machinery/icts/guideway_sensor/sensor in SSicts_transport.sensors)
		if(sensor.z == comparison.z)
			if((sensor.x == comparison.x && sensor.dir & NORTH|SOUTH) || (sensor.y == comparison.y && sensor.dir & EAST|WEST))
				candidate_sensors += sensor

	var/obj/machinery/icts/guideway_sensor/winner = candidate_sensors[1]
	var/winner_distance = get_dist(comparison, winner)

	for(var/obj/machinery/icts/guideway_sensor/sensor_to_sort as anything in candidate_sensors)
		var/sensor_distance = get_dist(comparison, sensor_to_sort)

		if(sensor_distance < winner_distance)
			winner = sensor_to_sort
			winner_distance = sensor_distance

	if(winner_distance <= DEFAULT_TRAM_LENGTH)
		return winner

	return FALSE
