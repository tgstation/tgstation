/obj/item/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A fire alarm circuit. Can handle heat levels up to 40 degrees celsius."

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm
	pixel_shift = 26

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "Pull this in case of emergency. Thus, keep pulling it forever."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "fire0"
	max_integrity = 250
	integrity_failure = 0.4
	armor_type = /datum/armor/machinery_firealarm
	mouse_over_pointer = MOUSE_HAND_POINTER
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_ENVIRON
	resistance_flags = FIRE_PROOF

	light_power = 1
	light_range = 1.6
	light_color = LIGHT_COLOR_ELECTRIC_CYAN

	//We want to use area sensitivity, let us
	always_area_sensitive = TRUE
	///Buildstate for contruction steps
	var/buildstage = FIRE_ALARM_BUILD_SECURED
	///Our home area, set in Init. Due to loading step order, this seems to be null very early in the server setup process, which is why some procs use `my_area?` for var or list checks.
	var/area/my_area = null
	///looping sound datum for our fire alarm siren.
	var/datum/looping_sound/firealarm/soundloop

	// Set by wires, not meant for subtypes
	/// If FALSE, the fire alarm can never be reset().
	VAR_FINAL/can_reset = TRUE
	/// If FALSE, the fire alarm can never be alarm()ed.
	VAR_FINAL/can_trigger = TRUE
	/// If FALSE, a multitool or borg can't disable the sensor.
	VAR_FINAL/can_toggle_detection = TRUE

/datum/armor/machinery_firealarm
	fire = 90
	acid = 30

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	id_tag = assign_random_name()
	if(building)
		buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
		set_panel_open(TRUE)
	if(name == initial(name))
		update_name()
	my_area = get_area(src)
	LAZYADD(my_area.firealarms, src)

	AddElement(/datum/element/atmos_sensitive, mapload)
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(check_security_level))
	soundloop = new(src, FALSE)
	set_wires(new /datum/wires/firealarm(src))

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/firealarm,
	))

	AddComponent( \
		/datum/component/redirect_attack_hand_from_turf, \
		screentip_texts = list( \
			lmb_text = "Turn on alarm", \
			rmb_text = "Turn off alarm", \
		), \
	)

	register_context()
	find_and_hang_on_wall()
	update_appearance()


/obj/machinery/firealarm/Destroy()
	if(my_area)
		LAZYREMOVE(my_area.firealarms, src)
		my_area = null
	QDEL_NULL(soundloop)
	return ..()

// Area sensitivity is traditionally tied directly to power use, as an optimization
// But since we want it for fire reacting, we disregard that
/obj/machinery/firealarm/setup_area_power_relationship()
	. = ..()
	if(!.)
		return
	var/area/our_area = get_area(src)
	RegisterSignal(our_area, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(our_area, our_area.fire)

/obj/machinery/firealarm/on_enter_area(datum/source, area/area_to_register)
	//were already registered to an area. exit from here first before entering into an new area
	if(!isnull(my_area))
		return
	. = ..()

	my_area = area_to_register
	LAZYADD(my_area.firealarms, src)

	RegisterSignal(area_to_register, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(area_to_register, area_to_register.fire)
	update_appearance()

/obj/machinery/firealarm/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] [initial(name)] [id_tag]"

/obj/machinery/firealarm/on_exit_area(datum/source, area/area_to_unregister)
	//we cannot unregister from an area we never registered to in the first place
	if(my_area != area_to_unregister)
		return
	. = ..()

	UnregisterSignal(area_to_unregister, COMSIG_AREA_FIRE_CHANGED)
	LAZYREMOVE(my_area.firealarms, src)
	my_area = null

/obj/machinery/firealarm/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	set_status()

/**
 * Sets the sound state, and then calls update_icon()
 *
 * This proc exists to be called by areas and firelocks
 * so that it may update its icon and start or stop playing
 * the alarm sound based on the state of an area variable.
 */
/obj/machinery/firealarm/proc/set_status()
	if(!(my_area.fire || LAZYLEN(my_area.active_firelocks)) || (obj_flags & EMAGGED))
		soundloop.stop()
	update_appearance()

/obj/machinery/firealarm/update_appearance(updates)
	. = ..()
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		set_light(l_on = FALSE)
	else if((my_area?.fire || LAZYLEN(my_area?.active_firelocks)) && !(obj_flags & EMAGGED) && !(machine_stat & (BROKEN|NOPOWER)))
		set_light(l_on = TRUE, l_range = 2.5, l_power = 1.5)
	else
		set_light(l_on = TRUE, l_range = 1.6, l_power = 1)

/obj/machinery/firealarm/update_icon_state()
	if(panel_open)
		icon_state = "fire_b[buildstage]"
		return ..()
	if(machine_stat & BROKEN)
		icon_state = "firex"
		return ..()
	icon_state = "fire0"
	return ..()

/obj/machinery/firealarm/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return

	if(panel_open)
		return

	if(obj_flags & EMAGGED)
		. += mutable_appearance(icon, "fire_emag")
		. += emissive_appearance(icon, "fire_emag_e", src, alpha = src.alpha)
		set_light(l_color = LIGHT_COLOR_BLUE)

	else if(!(my_area?.fire || LAZYLEN(my_area?.active_firelocks)))
		if(my_area?.fire_detect) //If this is false, someone disabled it. Leave the light missing, a good hint to anyone paying attention.
			if(is_station_level(z))
				var/current_level = SSsecurity_level.get_current_level_as_number()
				. += mutable_appearance(icon, "fire_[current_level]")
				. += emissive_appearance(icon, "fire_level_e", src, alpha = src.alpha)
				set_light(l_color = SSsecurity_level?.current_security_level?.fire_alarm_light_color || LIGHT_COLOR_BLUEGREEN)
			else
				. += mutable_appearance(icon, "fire_offstation")
				. += emissive_appearance(icon, "fire_level_e", src, alpha = src.alpha)
				set_light(l_color = LIGHT_COLOR_FAINT_BLUE)
		else
			. += mutable_appearance(icon, "fire_disabled")
			. += emissive_appearance(icon, "fire_level_e", src, alpha = src.alpha)
			set_light(l_color = COLOR_WHITE)

	else if(my_area?.fire_detect && my_area?.fire)
		. += mutable_appearance(icon, "fire_alerting")
		. += emissive_appearance(icon, "fire_alerting_e", src, alpha = src.alpha)
		set_light(l_color = LIGHT_COLOR_INTENSE_RED)
	else
		. += mutable_appearance(icon, "fire_alerting")
		. += emissive_appearance(icon, "fire_alerting_e", src, alpha = src.alpha)
		set_light(l_color = LIGHT_COLOR_INTENSE_RED)

/obj/machinery/firealarm/emp_act(severity)
	. = ..()

	if (. & EMP_PROTECT_SELF)
		return

	if(prob(50 / severity))
		alarm()

// Stops AI from toggling auto-fire detection, also disables the sound and lighting
/obj/machinery/firealarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	update_appearance()
	visible_message(span_warning("Sparks fly out of [src]!"))
	if(user)
		balloon_alert(user, "circuitry fried")
		user.log_message("emagged [src].", LOG_ATTACK)
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	set_status()
	return TRUE

/**
 * Signal handler for checking if we should update fire alarm appearance accordingly to a newly set security level
 *
 * Arguments:
 * * source The datum source of the signal
 * * new_level The new security level that is in effect
 */
/obj/machinery/firealarm/proc/check_security_level(datum/source, new_level)
	SIGNAL_HANDLER

	if(is_station_level(z))
		update_appearance()

/**
 * Sounds the fire alarm and closes all firelocks in the area. Also tells the area to color the lights red.
 *
 * Arguments:
 * * mob/user is the user that pulled the alarm.
 */
/obj/machinery/firealarm/proc/alarm(mob/user, silent = FALSE)
	if(!is_operational || !can_trigger || my_area?.fire)
		return
	my_area.alarm_manager.send_alarm(ALARM_FIRE, my_area)
	// This'll setup our visual effects, so we only need to worry about the alarm
	for(var/obj/machinery/door/firedoor/firelock in my_area.firedoors)
		firelock.activate(FIRELOCK_ALARM_TYPE_GENERIC)
	if(user)
		if(!silent)
			balloon_alert(user, "triggered alarm!")
		user.log_message("triggered a fire alarm.", LOG_GAME)
	my_area.fault_status = AREA_FAULT_MANUAL
	my_area.fault_location = name
	soundloop.start() //Manually pulled fire alarms will make the sound, rather than the doors.
	SEND_SIGNAL(src, COMSIG_FIREALARM_ON_TRIGGER)
	update_use_power(ACTIVE_POWER_USE)

/**
 * Resets all firelocks in the area. Also tells the area to disable alarm lighting, if it was enabled.
 *
 * Arguments:
 * * mob/user is the user that reset the alarm.
 */
/obj/machinery/firealarm/proc/reset(mob/user, silent = FALSE)
	if(!is_operational || !can_reset)
		return
	my_area.alarm_manager.clear_alarm(ALARM_FIRE, my_area)
	// Clears all fire doors and their effects for now
	// They'll reclose if there's a problem
	for(var/obj/machinery/door/firedoor/firelock in my_area.firedoors)
		firelock.crack_open()
	if(user)
		if(!silent)
			balloon_alert(user, "reset alarm")
		user.log_message("reset a fire alarm.", LOG_GAME)
	soundloop.stop()
	SEND_SIGNAL(src, COMSIG_FIREALARM_ON_RESET)
	update_use_power(IDLE_POWER_USE)

/obj/machinery/firealarm/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || buildstage != FIRE_ALARM_BUILD_SECURED)
		return .
	alarm(user)
	return TRUE

/obj/machinery/firealarm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || buildstage != FIRE_ALARM_BUILD_SECURED)
		return .
	add_fingerprint(user)
	reset(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/firealarm/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/firealarm/attack_ai_secondary(mob/user)
	return attack_hand_secondary(user)

/obj/machinery/firealarm/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/firealarm/attack_robot_secondary(mob/user)
	return attack_hand_secondary(user)

/obj/machinery/firealarm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(issilicon(user))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle automatic fire detection"
		return CONTEXTUAL_SCREENTIP_SET

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Turn on"
		context[SCREENTIP_CONTEXT_RMB] = "Turn off"
		return CONTEXTUAL_SCREENTIP_SET

	switch(held_item.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			if(buildstage == FIRE_ALARM_BUILD_SECURED)
				context[SCREENTIP_CONTEXT_RMB] = "[panel_open ? "Unexpose" : "Expose"] wires"
				. = CONTEXTUAL_SCREENTIP_SET
		if(TOOL_WELDER)
			if(panel_open)
				context[SCREENTIP_CONTEXT_LMB] = "Repair"
				. = CONTEXTUAL_SCREENTIP_SET
		if(TOOL_WIRECUTTER)
			if(panel_open && buildstage == FIRE_ALARM_BUILD_SECURED)
				context[SCREENTIP_CONTEXT_LMB] = "Examine wires"
				context[SCREENTIP_CONTEXT_RMB] = "Remove wires"
				. = CONTEXTUAL_SCREENTIP_SET
		if(TOOL_MULTITOOL)
			if(panel_open && buildstage == FIRE_ALARM_BUILD_SECURED)
				context[SCREENTIP_CONTEXT_LMB] = "Examine wires"
				. = CONTEXTUAL_SCREENTIP_SET
		if(TOOL_CROWBAR)
			if(panel_open && buildstage == FIRE_ALARM_BUILD_NO_WIRES)
				context[SCREENTIP_CONTEXT_RMB] = "Remove circuit"
				. = CONTEXTUAL_SCREENTIP_SET
		if(TOOL_WRENCH)
			if(panel_open && buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT)
				context[SCREENTIP_CONTEXT_RMB] = "Remove fire alarm"
				. = CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/stack/cable_coil) && panel_open && buildstage == FIRE_ALARM_BUILD_NO_WIRES)
		context[SCREENTIP_CONTEXT_LMB] = "Install wires"
		. = CONTEXTUAL_SCREENTIP_SET

	if((istype(held_item, /obj/item/electronics/firealarm) || istype(held_item, /obj/item/electroadaptive_pseudocircuit)) && panel_open && buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT)
		context[SCREENTIP_CONTEXT_LMB] = "Install circuit"
		. = CONTEXTUAL_SCREENTIP_SET

	return .

/obj/machinery/firealarm/screwdriver_act(mob/living/user, obj/item/tool)
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		return NONE
	toggle_panel_open()
	tool.play_tool_sound(src)
	balloon_alert_to_viewers("wires [panel_open ? "exposed" : "unexposed"]")
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return screwdriver_act(user, tool)

/obj/machinery/firealarm/welder_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "already in good condition!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume = 50, extra_checks = CALLBACK(src, PROC_REF(state_callback), null, TRUE)))
		return ITEM_INTERACT_BLOCKING
	repair_damage(INFINITY)
	balloon_alert_to_viewers("repaired")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		balloon_alert(user, "no wires to cut!")
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)
	new /obj/item/stack/cable_coil(user.loc, 5)
	balloon_alert_to_viewers("wires removed")
	buildstage = FIRE_ALARM_BUILD_NO_WIRES
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	if(buildstage != FIRE_ALARM_BUILD_NO_WIRES)
		return NONE

	loc.balloon_alert_to_viewers("removing circuit...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50, extra_checks = CALLBACK(src, PROC_REF(state_callback), FIRE_ALARM_BUILD_NO_WIRES, TRUE)))
		return ITEM_INTERACT_BLOCKING
	if(machine_stat & BROKEN)
		balloon_alert_to_viewers("broken circuit removed")
		set_machine_stat(machine_stat & ~BROKEN)
	else
		balloon_alert_to_viewers("circuit removed")
		new /obj/item/electronics/firealarm(user.drop_location())
	buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return crowbar_act(user, tool)

/obj/machinery/firealarm/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return NONE
	if(buildstage != FIRE_ALARM_BUILD_NO_CIRCUIT)
		balloon_alert(user, "remove [buildstage == FIRE_ALARM_BUILD_SECURED ? "wires" : "circuit"] first!")
		return ITEM_INTERACT_BLOCKING

	loc.balloon_alert_to_viewers("[/obj/item/wallframe/firealarm::name] removed")
	new /obj/item/wallframe/firealarm(user.drop_location())
	tool.play_tool_sound(loc)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/wrench_act_secondary(mob/living/user, obj/item/tool)
	return wrench_act(user, tool)

/obj/machinery/firealarm/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_wire_tool(tool))
		return NONE
	if(!panel_open)
		balloon_alert(user, "expose wires first!")
		return ITEM_INTERACT_BLOCKING
	wires.interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/proc/cable_act(mob/living/user, obj/item/stack/cable_coil/coil)
	if(buildstage != FIRE_ALARM_BUILD_NO_WIRES)
		return NONE
	if(!coil.use(5))
		balloon_alert(user, "need 5 cables!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert_to_viewers("wires installed")
	buildstage = FIRE_ALARM_BUILD_SECURED
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/proc/electronics_act(mob/living/user, obj/item/electronics/firealarm/circuit)
	if(buildstage != FIRE_ALARM_BUILD_NO_CIRCUIT)
		return NONE
	if(!user.transferItemToLoc(circuit, src))
		balloon_alert(user, "can't install!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert_to_viewers("circuit installed")
	qdel(circuit)
	buildstage = FIRE_ALARM_BUILD_NO_WIRES
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/proc/pseudocircuit_act(mob/living/user, obj/item/electroadaptive_pseudocircuit/pseudocircuit)
	if(buildstage != FIRE_ALARM_BUILD_NO_CIRCUIT)
		return NONE
	if(!pseudocircuit.adapt_circuit(user, circuit_cost = 0.015 * STANDARD_CELL_CHARGE))
		return ITEM_INTERACT_BLOCKING

	balloon_alert_to_viewers("circuit installed")
	buildstage = FIRE_ALARM_BUILD_NO_WIRES
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/firealarm/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!panel_open)
		return NONE

	if(istype(tool, /obj/item/stack/cable_coil))
		return cable_act(user, tool)

	if(istype(tool, /obj/item/electronics/firealarm))
		return electronics_act(user, tool)

	if(istype(tool, /obj/item/electroadaptive_pseudocircuit))
		return pseudocircuit_act(user, tool)

	return NONE

/obj/machinery/firealarm/proc/state_callback(desired_build_state, desired_panel_state)
	return (isnull(desired_build_state) || buildstage == desired_build_state) \
		&& (isnull(desired_panel_state) || panel_open == desired_panel_state)

/obj/machinery/firealarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT) && (the_rcd.construction_upgrades & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("delay" = 2 SECONDS, "cost" = 1)
	return FALSE

/obj/machinery/firealarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_WALLFRAME)
			balloon_alert_to_viewers("circuit installed")
			buildstage = FIRE_ALARM_BUILD_NO_WIRES
			update_appearance()
			return TRUE
	return FALSE

// Taking melee damage always triggers the alarm if panel is open
/obj/machinery/firealarm/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!. || !panel_open || buildstage != FIRE_ALARM_BUILD_SECURED)
		return
	alarm()

// Taking any damage has a rng chance of triggering the alarm regardless of panel state
/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(!.) // no damage received
		return
	if(atom_integrity <= 0 || buildstage != FIRE_ALARM_BUILD_SECURED)
		return
	if(prob(damage_amount * 3))
		alarm()

/obj/machinery/firealarm/singularity_pull(atom/singularity, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	return ..()

/obj/machinery/firealarm/atom_break(damage_flag)
	if(buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT) //can't break the electronics if there isn't any inside.
		return
	return ..()

/obj/machinery/firealarm/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/iron(loc)
	if(buildstage > FIRE_ALARM_BUILD_NO_CIRCUIT)
		var/obj/item/item = new /obj/item/electronics/firealarm(loc)
		if(!disassembled)
			item.update_integrity(item.max_integrity * 0.5)
	if(buildstage > FIRE_ALARM_BUILD_NO_WIRES)
		new /obj/item/stack/cable_coil(loc, 3)

// Allows users to examine the state of the thermal sensor
/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	if((my_area?.fire || LAZYLEN(my_area?.active_firelocks)))
		. += "The local area hazard light is flashing."
		. += "The fault location display is [my_area.fault_location] ([my_area.fault_status == AREA_FAULT_AUTOMATIC ? "Automatic Detection" : "Manual Trigger"])."
		if(is_station_level(z))
			. += "The station security alert level is [SSsecurity_level.get_current_level_as_text()]."
		. += "<b>Left-Click</b> to activate all firelocks in this area."
		. += "<b>Right-Click</b> to reset firelocks in this area."
	else
		if(is_station_level(z))
			. += "The station security alert level is [SSsecurity_level.get_current_level_as_text()]."
		. += "The local area thermal detection light is [my_area.fire_detect ? "lit" : "unlit"]."
		. += "<b>Left-Click</b> to activate all firelocks in this area."

// Allows Silicons to disable thermal sensor
/obj/machinery/firealarm/BorgCtrlClick(mob/living/silicon/robot/user)
	if(get_dist(src,user) <= user.interaction_range && !(user.control_disabled))
		AICtrlClick(user)
		return
	return ..()

/obj/machinery/firealarm/AICtrlClick(mob/living/silicon/robot/user)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "control circuitry malfunctioning!")
		return
	toggle_fire_detect(user)

/// Toggles automatic fire detection on or off
/obj/machinery/firealarm/proc/toggle_fire_detect(mob/user, silent = FALSE)
	if(!can_toggle_detection)
		if(user && !silent)
			balloon_alert(user, "thermal sensors unresponsive!")
		return
	if(my_area.fire_detect)
		disable_fire_detect(user)
	else
		enable_fire_detect(user)
	if (user && !silent)
		balloon_alert(user, "thermal sensors [my_area.fire_detect ? "enabled" : "disabled"]")

/// Stops the area from automatically activating firelocks
/obj/machinery/firealarm/proc/disable_fire_detect(mob/user)
	if(!my_area.fire_detect)
		return
	my_area.fire_detect = FALSE
	for(var/obj/machinery/firealarm/fire_panel in my_area.firealarms)
		fire_panel.update_appearance()
	// Used to force all the firelocks to update, if the zone is not manually activated
	if(my_area.fault_status != AREA_FAULT_MANUAL)
		reset()
	user?.log_message("disabled firelock sensors using [src].", LOG_GAME)

/// Enables the area to automatically activate firelocks
/obj/machinery/firealarm/proc/enable_fire_detect(mob/user)
	if(my_area.fire_detect)
		return
	my_area.fire_detect = TRUE
	for(var/obj/machinery/firealarm/fire_panel in my_area.firealarms)
		fire_panel.update_appearance()
	// See above
	if(my_area.fault_status != AREA_FAULT_MANUAL)
		reset()
	user?.log_message("enabled firelock sensors using [src].", LOG_GAME)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/firealarm, 26)

/*
 * Return of Party button
 */

/area
	var/party = FALSE

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	var/static/party_overlay

/obj/machinery/firealarm/partyalarm/reset(mob/user, silent = FALSE)
	if (!is_operational || !can_reset)
		return
	my_area.party = FALSE
	my_area.cut_overlay(party_overlay)

/obj/machinery/firealarm/partyalarm/alarm(mob/user, silent = FALSE)
	if (!is_operational || !can_trigger)
		return
	if (my_area.party || is_area_nearby_station(my_area))
		return
	party_overlay ||= iconstate2appearance('icons/area/areas_misc.dmi', "party")
	my_area.party = TRUE
	my_area.add_overlay(party_overlay)

/obj/item/circuit_component/firealarm
	display_name = "Fire Alarm"
	desc = "Allows you to interface with the Fire Alarm."

	var/datum/port/input/alarm_trigger
	var/datum/port/input/reset_trigger

	/// Returns a boolean value of 0 or 1 if the fire alarm is on or not.
	var/datum/port/output/is_on
	/// Returns when the alarm is turned on
	var/datum/port/output/triggered
	/// Returns when the alarm is turned off
	var/datum/port/output/reset

	var/obj/machinery/firealarm/attached_alarm

/obj/item/circuit_component/firealarm/populate_ports()
	alarm_trigger = add_input_port("Set", PORT_TYPE_SIGNAL)
	reset_trigger = add_input_port("Reset", PORT_TYPE_SIGNAL)

	is_on = add_output_port("Is On", PORT_TYPE_NUMBER)
	triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	reset = add_output_port("Reset", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/firealarm/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/firealarm))
		attached_alarm = parent
		RegisterSignal(parent, COMSIG_FIREALARM_ON_TRIGGER, PROC_REF(on_firealarm_triggered))
		RegisterSignal(parent, COMSIG_FIREALARM_ON_RESET, PROC_REF(on_firealarm_reset))

/obj/item/circuit_component/firealarm/unregister_usb_parent(atom/movable/parent)
	attached_alarm = null
	UnregisterSignal(parent, COMSIG_FIREALARM_ON_TRIGGER)
	UnregisterSignal(parent, COMSIG_FIREALARM_ON_RESET)
	return ..()

/obj/item/circuit_component/firealarm/proc/on_firealarm_triggered(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(1)
	triggered.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/firealarm/proc/on_firealarm_reset(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(0)
	reset.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/firealarm/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(alarm_trigger, port))
		attached_alarm?.alarm()

	if(COMPONENT_TRIGGERED_BY(reset_trigger, port))
		attached_alarm?.reset()
