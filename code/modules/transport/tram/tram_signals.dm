/// Pedestrian crossing signal for tram
/obj/machinery/transport/crossing_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks. Connects to sensors down the track."
	icon = 'icons/obj/tram/crossing_signal.dmi'
	icon_state = "crossing-inbound"
	base_icon_state = "crossing-inbound"
	layer = TRAM_SIGNAL_LAYER
	max_integrity = 250
	integrity_failure = 0.25
	light_range = 2
	light_power = 0.7
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 3.6
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.72
	anchored = TRUE
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OPEN
	circuit = /obj/item/circuitboard/machine/crossing_signal
	// pointless if it only takes 2 seconds to cross but updates every 2 seconds
	subsystem_type = /datum/controller/subsystem/processing/transport
	light_color = LIGHT_COLOR_BABY_BLUE
	/// green, amber, or red for tram, blue if it's emag, tram missing, etc.
	var/signal_state = XING_STATE_MALF
	/// the sensor we use
	var/datum/weakref/sensor_ref
	/// Inbound station
	var/inbound
	/// Outbound station
	var/outbound
	/// If us or anything else in the operation chain is broken
	var/operating_status = TRANSPORT_SYSTEM_NORMAL
	var/sign_dir = INBOUND
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
	var/amber_distance_threshold = XING_THRESHOLD_AMBER
	var/red_distance_threshold = XING_THRESHOLD_RED

/** Crossing signal subtypes
 *
 *  Each map will have a different amount of tiles between stations, so adjust the signals here based on the map.
 *  The distance is calculated from the bottom left corner of the tram,
 *  so signals on the east side have their distance reduced by the tram length, in this case 10 for Tramstation.
*/
/obj/machinery/transport/crossing_signal/northwest
	dir = NORTH
	sign_dir = INBOUND

/obj/machinery/transport/crossing_signal/northeast
	dir = NORTH
	sign_dir = OUTBOUND

/obj/machinery/transport/crossing_signal/southwest
	dir = SOUTH
	sign_dir = INBOUND
	pixel_y = 20

/obj/machinery/transport/crossing_signal/southeast
	dir = SOUTH
	sign_dir = OUTBOUND
	pixel_y = 20

/obj/machinery/static_signal
	name = "crossing signal"
	desc = "Indicates to pedestrians if it's safe to cross the tracks."
	icon = 'icons/obj/tram/crossing_signal.dmi'
	icon_state = "crossing-inbound"
	layer = TRAM_SIGNAL_LAYER
	max_integrity = 250
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 3.6
	anchored = TRUE
	density = FALSE
	light_range = 1.5
	light_power = 3
	light_color = COLOR_VIBRANT_LIME
	var/sign_dir = INBOUND

/obj/machinery/static_signal/northwest
	dir = NORTH
	sign_dir = INBOUND

/obj/machinery/static_signal/northeast
	dir = NORTH
	sign_dir = OUTBOUND

/obj/machinery/static_signal/southwest
	dir = SOUTH
	sign_dir = INBOUND
	pixel_y = 20

/obj/machinery/static_signal/southeast
	dir = SOUTH
	sign_dir = OUTBOUND
	pixel_y = 20

/obj/machinery/transport/crossing_signal/Initialize(mapload)
	. = ..()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(wake_up))
	RegisterSignal(SStransport, COMSIG_COMMS_STATUS, PROC_REF(comms_change))
	SStransport.crossing_signals += src
	register_context()

/obj/machinery/transport/crossing_signal/post_machine_initialize()
	. = ..()
	link_tram()
	link_sensor()
	find_uplink()

/obj/machinery/transport/crossing_signal/Destroy()
	SStransport.crossing_signals -= src
	. = ..()

/obj/machinery/transport/crossing_signal/attackby(obj/item/weapon, mob/living/user, params)
	if(!user.combat_mode)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
			return

		if(default_deconstruction_crowbar(weapon))
			return

	return ..()

/obj/machinery/transport/crossing_signal/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(panel_open)
		if(held_item?.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_ALT_LMB] = "rotate signal"
			context[SCREENTIP_CONTEXT_RMB] = "flip signal"

	if(istype(held_item, /obj/item/card/emag) && !(obj_flags & EMAGGED))
		context[SCREENTIP_CONTEXT_LMB] = "disable sensors"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/transport/crossing_signal/examine(mob/user)
	. = ..()
	. += span_notice("The maintenance panel is [panel_open ? "open" : "closed"].")
	if(panel_open)
		. += span_notice("It can be flipped or rotated with a [EXAMINE_HINT("wrench.")]")
	switch(operating_status)
		if(TRANSPORT_REMOTE_WARNING)
			. += span_notice("The orange [EXAMINE_HINT("remote warning")] light is on.")
			. += span_notice("The status display reads: Check track sensor.")
		if(TRANSPORT_REMOTE_FAULT)
			. += span_notice("The blue [EXAMINE_HINT("remote fault")] light is on.")
			. += span_notice("The status display reads: Check tram controller.")
		if(TRANSPORT_LOCAL_FAULT)
			. += span_notice("The red [EXAMINE_HINT("local fault")] light is on.")
			. += span_notice("The status display reads: Repair required.")
	switch(dir)
		if(NORTH, SOUTH)
			. += span_notice("The tram configuration display shows EAST/WEST.")
		if(EAST, WEST)
			. += span_notice("The tram configuration display shows NORTH/SOUTH.")

/obj/machinery/transport/crossing_signal/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "disabled motion sensors")
	operating_status = TRANSPORT_LOCAL_FAULT
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/transport/crossing_signal/click_alt(mob/living/user)
	var/obj/item/tool = user.get_active_held_item()
	if(!panel_open || tool?.tool_behaviour != TOOL_WRENCH)
		return CLICK_ACTION_BLOCKING

	tool.play_tool_sound(src, 50)
	setDir(turn(dir,-90))
	balloon_alert(user, "rotated")
	find_uplink()
	return CLICK_ACTION_SUCCESS

/obj/machinery/transport/crossing_signal/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()

	if(weapon.tool_behaviour == TOOL_WRENCH && panel_open)
		switch(sign_dir)
			if(INBOUND)
				sign_dir = OUTBOUND
			if(OUTBOUND)
				sign_dir = INBOUND

		to_chat(user, span_notice("You flip directions on [src]."))
		update_appearance()

		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/transport/crossing_signal/proc/link_sensor()
	sensor_ref = WEAKREF(find_closest_valid_sensor())
	update_appearance()

/obj/machinery/transport/crossing_signal/proc/unlink_sensor()
	sensor_ref = null
	if(operating_status < TRANSPORT_REMOTE_WARNING)
		operating_status = TRANSPORT_REMOTE_WARNING
	update_appearance()

/obj/machinery/transport/crossing_signal/proc/wake_sensor()
	var/obj/machinery/transport/guideway_sensor/linked_sensor = sensor_ref?.resolve()
	if(isnull(linked_sensor))
		operating_status = TRANSPORT_REMOTE_WARNING

	else if(linked_sensor.trigger_sensor())
		operating_status = TRANSPORT_SYSTEM_NORMAL

	else
		operating_status = TRANSPORT_REMOTE_WARNING

/obj/machinery/transport/crossing_signal/proc/clear_uplink()
	inbound = null
	outbound = null
	update_appearance()

/**
 * Only process if the tram is actually moving
 */
/obj/machinery/transport/crossing_signal/proc/wake_up(datum/source, transport_controller, controller_active)
	SIGNAL_HANDLER

	if(machine_stat & BROKEN || machine_stat & NOPOWER)
		operating_status = TRANSPORT_LOCAL_FAULT
		update_appearance()
		return

	if(prob(TRANSPORT_BREAKDOWN_RATE))
		operating_status = TRANSPORT_LOCAL_FAULT
		local_fault()
		return

	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	var/obj/machinery/transport/guideway_sensor/linked_sensor = sensor_ref?.resolve()

	if(malfunctioning)
		operating_status = TRANSPORT_LOCAL_FAULT
	else if(isnull(tram) || tram.controller_status & COMM_ERROR)
		operating_status = TRANSPORT_REMOTE_FAULT
	else
		operating_status = TRANSPORT_SYSTEM_NORMAL

	if(isnull(linked_sensor))
		link_sensor()
	wake_sensor()
	update_operating()

/obj/machinery/transport/crossing_signal/on_set_machine_stat()
	. = ..()
	if(machine_stat & BROKEN || machine_stat & NOPOWER)
		operating_status = TRANSPORT_LOCAL_FAULT
	else
		operating_status = TRANSPORT_SYSTEM_NORMAL

/obj/machinery/transport/crossing_signal/on_set_is_operational()
	. = ..()
	if(!is_operational)
		operating_status = TRANSPORT_LOCAL_FAULT
	else
		operating_status = TRANSPORT_SYSTEM_NORMAL
	update_operating()

/obj/machinery/transport/crossing_signal/proc/comms_change(source, controller, new_status)
	SIGNAL_HANDLER

	var/datum/transport_controller/linear/tram/updated_controller = controller

	if(updated_controller.specific_transport_id != configured_transport_id)
		return

	switch(new_status)
		if(TRUE)
			if(operating_status == TRANSPORT_REMOTE_FAULT)
				operating_status = TRANSPORT_SYSTEM_NORMAL
		if(FALSE)
			if(operating_status == TRANSPORT_SYSTEM_NORMAL)
				operating_status = TRANSPORT_REMOTE_FAULT

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/transport/crossing_signal/proc/update_operating()
	update_appearance()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		update_use_power(ACTIVE_POWER_USE)
		begin_processing()
		return
	update_use_power(IDLE_POWER_USE)
	end_processing()

/obj/machinery/transport/crossing_signal/process()
	// idle aspect is green or blue depending on the signal status
	// degraded signal operating conditions of any type show blue
	var/idle_aspect = operating_status == TRANSPORT_SYSTEM_NORMAL ? XING_STATE_GREEN : XING_STATE_MALF
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()

	// Check for stopped states. Will kill the process since tram starting up will restart process.
	if(!tram || !tram.controller_operational || !tram.controller_active || !is_operational || !inbound || !outbound)
		// Tram missing, we lost power, or something isn't right
		// Set idle and stop processing, since the tram won't be moving
		set_signal_state(idle_aspect, force = !is_operational)
		return PROCESS_KILL

	var/obj/structure/transport/linear/tram_part = tram.return_closest_platform_to(src)

	// The structure is gone, so we're done here.
	if(QDELETED(tram_part))
		set_signal_state(idle_aspect, force = !is_operational)
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
	var/approach_distance = tram_velocity_sign * (signal_pos - (tram_pos + DEFAULT_TRAM_MIDPOINT))

	// Check if tram is driving away from us.
	if(approach_distance < -abs(DEFAULT_TRAM_MIDPOINT))
		// driving away. Green. In fact, in order to reverse, it'll have to stop, so let's go ahead and kill.
		set_signal_state(idle_aspect)
		return PROCESS_KILL

	// Check the tram's terminus station.
	// INBOUND 1 < 2 < 3
	// OUTBOUND 1 > 2 > 3
	if(tram.travel_direction & WEST && inbound < tram.destination_platform.platform_code)
		set_signal_state(idle_aspect)
		return PROCESS_KILL
	if(tram.travel_direction & EAST && outbound > tram.destination_platform.platform_code)
		set_signal_state(idle_aspect)
		return PROCESS_KILL

	// Finally the interesting part where it's ACTUALLY approaching
	if(approach_distance <= red_distance_threshold)
		set_signal_state(XING_STATE_RED)
		return
	if(approach_distance <= amber_distance_threshold && operating_status == TRANSPORT_SYSTEM_NORMAL)
		set_signal_state(XING_STATE_AMBER)
		return
	set_signal_state(idle_aspect)

/**
 * Set the signal state and update appearance.
 *
 * Arguments:
 * new_state - the new state (XING_STATE_RED, etc)
 * force_update - force appearance to update even if state didn't change.
 */
/obj/machinery/transport/crossing_signal/proc/set_signal_state(new_state, force = FALSE)
	if(new_state == signal_state && !force)
		return

	signal_state = new_state
	flick_overlay()
	update_appearance()

/obj/machinery/transport/crossing_signal/update_icon_state()
	switch(dir)
		if(SOUTH, EAST)
			pixel_y = 20
		if(NORTH, WEST)
			pixel_y = 0

	switch(sign_dir)
		if(INBOUND)
			icon_state = "crossing-inbound"
			base_icon_state = "crossing-inbound"
		if(OUTBOUND)
			icon_state = "crossing-outbound"
			base_icon_state = "crossing-outbound"

	return ..()

/obj/machinery/static_signal/update_icon_state()
	switch(dir)
		if(SOUTH, EAST)
			pixel_y = 20
		if(NORTH, WEST)
			pixel_y = 0

	switch(sign_dir)
		if(INBOUND)
			icon_state = "crossing-inbound"
			base_icon_state = "crossing-inbound"
		if(OUTBOUND)
			icon_state = "crossing-outbound"
			base_icon_state = "crossing-outbound"

	return ..()

/obj/machinery/transport/crossing_signal/update_appearance(updates)
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

/obj/machinery/transport/crossing_signal/update_overlays()
	. = ..()

	if(machine_stat & NOPOWER)
		return

	if(machine_stat & BROKEN)
		operating_status = TRANSPORT_LOCAL_FAULT

	var/lights_overlay = "[base_icon_state]-l[signal_state]"
	var/status_overlay = "[base_icon_state]-s[operating_status]"

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

	. += mutable_appearance(icon, "[base_icon_state]-l0")
	. += mutable_appearance(icon, "[base_icon_state]-s0")
	. += emissive_appearance(icon, "[base_icon_state]-l0", offset_spokesman = src, alpha = src.alpha)
	. += emissive_appearance(icon, "[base_icon_state]-s0", offset_spokesman = src, alpha = src.alpha)

/obj/machinery/transport/guideway_sensor
	name = "guideway sensor"
	icon = 'icons/obj/tram/tram_sensor.dmi'
	icon_state = "sensor-base"
	desc = "Uses an infrared beam to detect passing trams. Works when paired with a sensor on the other side of the track."
	layer = TRAM_RAIL_LAYER
	plane = FLOOR_PLANE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/guideway_sensor
	/// Sensors work in a married pair
	var/datum/weakref/paired_sensor
	/// If us or anything else in the operation chain is broken
	var/operating_status = TRANSPORT_SYSTEM_NORMAL

/obj/machinery/transport/guideway_sensor/Initialize(mapload)
	. = ..()
	SStransport.sensors += src

/obj/machinery/transport/guideway_sensor/post_machine_initialize()
	. = ..()
	pair_sensor()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(wake_up))

/obj/machinery/transport/guideway_sensor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(panel_open)
		if(held_item?.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_RMB] = "rotate sensor"

	if(istype(held_item, /obj/item/card/emag) && !(obj_flags & EMAGGED))
		context[SCREENTIP_CONTEXT_LMB] = "disable sensor"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/transport/guideway_sensor/examine(mob/user)
	. = ..()
	. += span_notice("The maintenance panel is [panel_open ? "open" : "closed"].")
	if(panel_open)
		. += span_notice("It can be rotated with a [EXAMINE_HINT("wrench.")]")
	switch(operating_status)
		if(TRANSPORT_REMOTE_WARNING)
			. += span_notice("The orange [EXAMINE_HINT("remote warning")] light is on.")
			. += span_notice("The status display reads: Check paired sensor.")
		if(TRANSPORT_REMOTE_FAULT)
			. += span_notice("The blue [EXAMINE_HINT("remote fault")] light is on.")
			. += span_notice("The status display reads: Paired sensor not found.")
		if(TRANSPORT_LOCAL_FAULT)
			. += span_notice("The red [EXAMINE_HINT("local fault")] light is on.")
			. += span_notice("The status display reads: Repair required.")

/obj/machinery/transport/guideway_sensor/attackby(obj/item/weapon, mob/living/user, params)
	if (!user.combat_mode)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
			return

		if(default_deconstruction_crowbar(weapon))
			return

	return ..()

/obj/machinery/transport/guideway_sensor/proc/pair_sensor()
	set_machine_stat(machine_stat | MAINT)
	if(paired_sensor)
		var/obj/machinery/transport/guideway_sensor/divorcee = paired_sensor?.resolve()
		divorcee.set_machine_stat(machine_stat | MAINT)
		divorcee.paired_sensor = null
		divorcee.update_appearance()
		paired_sensor = null

	for(var/obj/machinery/transport/guideway_sensor/potential_sensor in SStransport.sensors)
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

	var/obj/machinery/transport/guideway_sensor/new_partner = paired_sensor?.resolve()
	if(isnull(new_partner))
		return

	new_partner.paired_sensor = WEAKREF(src)
	new_partner.set_machine_stat(machine_stat & ~MAINT)
	new_partner.update_appearance()
	playsound(src, 'sound/machines/synth_yes.ogg', 75, vary = FALSE, use_reverb = TRUE)

/obj/machinery/transport/guideway_sensor/Destroy()
	SStransport.sensors -= src
	if(paired_sensor)
		var/obj/machinery/transport/guideway_sensor/divorcee = paired_sensor?.resolve()
		divorcee.set_machine_stat(machine_stat & ~MAINT)
		divorcee.paired_sensor = null
		divorcee.update_appearance()
		playsound(src, 'sound/machines/synth_no.ogg', 75, vary = FALSE, use_reverb = TRUE)
		paired_sensor = null
	. = ..()

/obj/machinery/transport/guideway_sensor/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_change_direction_wrench(user, tool))
		pair_sensor()
		return TRUE

/obj/machinery/transport/guideway_sensor/update_overlays()
	. = ..()

	if(machine_stat & BROKEN || machine_stat & NOPOWER || malfunctioning)
		operating_status = TRANSPORT_LOCAL_FAULT
		. += mutable_appearance(icon, "sensor-[TRANSPORT_LOCAL_FAULT]")
		. += emissive_appearance(icon, "sensor-[TRANSPORT_LOCAL_FAULT]", src, alpha = src.alpha)
		return

	if(machine_stat & MAINT)
		operating_status = TRANSPORT_REMOTE_FAULT
		. += mutable_appearance(icon, "sensor-[TRANSPORT_REMOTE_FAULT]")
		. += emissive_appearance(icon, "sensor-[TRANSPORT_REMOTE_FAULT]", src, alpha = src.alpha)
		return

	var/obj/machinery/transport/guideway_sensor/buddy = paired_sensor?.resolve()
	if(buddy)
		if(!buddy.is_operational)
			operating_status = TRANSPORT_REMOTE_WARNING
			. += mutable_appearance(icon, "sensor-[TRANSPORT_REMOTE_WARNING]")
			. += emissive_appearance(icon, "sensor-[TRANSPORT_REMOTE_WARNING]", src, alpha = src.alpha)
		else
			operating_status = TRANSPORT_SYSTEM_NORMAL
			. += mutable_appearance(icon, "sensor-[TRANSPORT_SYSTEM_NORMAL]")
			. += emissive_appearance(icon, "sensor-[TRANSPORT_SYSTEM_NORMAL]", src, alpha = src.alpha)
			return

	else
		operating_status = TRANSPORT_REMOTE_FAULT
		. += mutable_appearance(icon, "sensor-[TRANSPORT_REMOTE_FAULT]")
		. += emissive_appearance(icon, "sensor-[TRANSPORT_REMOTE_FAULT]", src, alpha = src.alpha)

/obj/machinery/transport/guideway_sensor/proc/trigger_sensor()
	var/obj/machinery/transport/guideway_sensor/buddy = paired_sensor?.resolve()
	if(!buddy)
		return FALSE

	if(!is_operational || !buddy.is_operational)
		return FALSE

	return TRUE

/obj/machinery/transport/guideway_sensor/proc/wake_up()
	SIGNAL_HANDLER

	if(machine_stat & BROKEN)
		update_appearance()
		return

	if(prob(TRANSPORT_BREAKDOWN_RATE))
		operating_status = TRANSPORT_LOCAL_FAULT
		local_fault()

	var/obj/machinery/transport/guideway_sensor/buddy = paired_sensor?.resolve()

	if(buddy)
		set_machine_stat(machine_stat & ~MAINT)

	update_appearance()

/obj/machinery/transport/guideway_sensor/on_set_is_operational()
	. = ..()

	var/obj/machinery/transport/guideway_sensor/buddy = paired_sensor?.resolve()
	if(buddy)
		buddy.update_appearance()

	update_appearance()

/obj/machinery/transport/crossing_signal/proc/find_closest_valid_sensor()
	if(!istype(src) || !src.z)
		return FALSE

	var/list/obj/machinery/transport/guideway_sensor/sensor_candidates = list()

	for(var/obj/machinery/transport/guideway_sensor/sensor in SStransport.sensors)
		if(sensor.z == src.z)
			if((sensor.x == src.x && sensor.dir & NORTH|SOUTH) || (sensor.y == src.y && sensor.dir & EAST|WEST))
				sensor_candidates += sensor

	var/obj/machinery/transport/guideway_sensor/selected_sensor = get_closest_atom(/obj/machinery/transport/guideway_sensor, sensor_candidates, src)
	var/sensor_distance = get_dist(src, selected_sensor)
	if(sensor_distance <= DEFAULT_TRAM_LENGTH)
		return selected_sensor

	return FALSE

/obj/machinery/transport/crossing_signal/proc/find_uplink()
	if(!istype(src) || !src.z)
		return FALSE

	var/list/obj/effect/landmark/transport/nav_beacon/tram/platform/inbound_candidates = list()
	var/list/obj/effect/landmark/transport/nav_beacon/tram/platform/outbound_candidates = list()

	inbound = null
	outbound = null

	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/beacon in SStransport.nav_beacons[configured_transport_id])
		if(beacon.z != src.z)
			continue

		switch(src.dir)
			if(NORTH, SOUTH)
				if(abs((beacon.y - src.y)) <= DEFAULT_TRAM_LENGTH)
					if(beacon.x < src.x)
						inbound_candidates += beacon
					else
						outbound_candidates += beacon
			if(EAST, WEST)
				if(abs((beacon.x - src.x)) <= DEFAULT_TRAM_LENGTH)
					if(beacon.y < src.y)
						inbound_candidates += beacon
					else
						outbound_candidates += beacon

	var/obj/effect/landmark/transport/nav_beacon/tram/platform/selected_inbound = get_closest_atom(/obj/effect/landmark/transport/nav_beacon/tram/platform, inbound_candidates, src)
	if(isnull(selected_inbound))
		return FALSE

	inbound = selected_inbound.platform_code

	var/obj/effect/landmark/transport/nav_beacon/tram/platform/selected_outbound = get_closest_atom(/obj/effect/landmark/transport/nav_beacon/tram/platform, outbound_candidates, src)
	if(isnull(selected_outbound))
		return FALSE

	outbound = selected_outbound.platform_code

	update_appearance()
