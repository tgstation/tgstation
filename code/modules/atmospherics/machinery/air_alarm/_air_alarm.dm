#define AIRALARM_WARNING_COOLDOWN (10 SECONDS)

/obj/machinery/airalarm
	name = "air alarm"
	desc = "A machine that monitors atmosphere levels. Goes off if the area is dangerous."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "alarmp"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 0.33
	armor_type = /datum/armor/machinery_airalarm
	resistance_flags = FIRE_PROOF

	/// Current alert level of our air alarm.
	/// [AIR_ALARM_ALERT_NONE], [AIR_ALARM_ALERT_MINOR], [AIR_ALARM_ALERT_SEVERE]
	var/danger_level = AIR_ALARM_ALERT_NONE

	/// Currently selected mode of the alarm. An instance of [/datum/air_alarm_mode].
	var/datum/air_alarm_mode/selected_mode
	///A reference to the area we are in
	var/area/my_area

	/// Boolean for whether the current air alarm can be tweaked by players or not.
	var/locked = TRUE
	/// Boolean to prevent AI from tampering with this alarm.
	var/aidisabled = FALSE
	/// Boolean of whether alarm is currently shorted. Mess up some functionalities.
	var/shorted = FALSE

	/// Current build stage. [AIRALARM_BUILD_COMPLETE], [AIRALARM_BUILD_NO_WIRES], [AIRALARM_BUILD_NO_CIRCUIT]
	var/buildstage = AIR_ALARM_BUILD_COMPLETE

	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/static/list/atmos_connections = list(COMSIG_TURF_EXPOSE = PROC_REF(check_danger))

	/// An assoc list of [datum/tlv]s, indexed by "pressure", "temperature", and [datum/gas] typepaths.
	var/list/datum/tlv/tlv_collection

	/// Used for air alarm helper called unlocked to make air alarm unlocked.
	var/unlocked = FALSE
	/// Used for air alarm helper called syndicate_access to make air alarm's required access syndicate_access.
	var/syndicate_access = FALSE
	/// Used for air alarm helper called away_general_access to make air alarm's required access away_general_access.
	var/away_general_access = FALSE
	/// Used for air alarm helper called engine_access to make air alarm's required access one of ACCESS_ATMOSPHERICS & ACCESS_ENGINEERING.
	var/engine_access = FALSE
	/// Used for air alarm helper called mixingchamber_access to make air alarm's required access one of ACCESS_ATMOSPHERICS & ACCESS_ORDNANCE.
	var/mixingchamber_access = FALSE
	/// Used for air alarm helper called all_access to remove air alarm's required access.
	var/all_access = FALSE

	/// Used for air alarm helper called tlv_cold_room to adjust alarm thresholds for cold room.
	var/tlv_cold_room = FALSE
	/// Used for air alarm helper called tlv_no_ckecks to remove alarm thresholds.
	var/tlv_no_checks = FALSE


	///Warning message spoken by air alarms
	var/warning_message = null

	//Stops the air alarm from talking about their atmos problems.
	var/speaker_enabled = TRUE

	///Cooldown on sending warning messages
	COOLDOWN_DECLARE(warning_cooldown)

	/// Used for connecting air alarm to a remote tile/zone via air sensor instead of the tile/zone of the air alarm
	var/obj/machinery/air_sensor/connected_sensor
	/// Used to link air alarm to air sensor via map helpers
	var/air_sensor_chamber_id = ""
	/// Whether it is possible to link/unlink this air alarm from a sensor
	var/allow_link_change = TRUE

GLOBAL_LIST_EMPTY_TYPED(air_alarms, /obj/machinery/airalarm)

/datum/armor/machinery_airalarm
	energy = 100
	fire = 90
	acid = 30

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	set_wires(new /datum/wires/airalarm(src))
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = AIR_ALARM_BUILD_NO_CIRCUIT
		set_panel_open(TRUE)

	if(name == initial(name))
		name = "[get_area_name(src)] Air Alarm"

	tlv_collection = list()
	tlv_collection["pressure"] = new /datum/tlv/pressure
	tlv_collection["temperature"] = new /datum/tlv/temperature
	var/list/meta_info = GLOB.meta_gas_info // shorthand
	for(var/gas_path in meta_info)
		if(ispath(gas_path, /datum/gas/oxygen))
			tlv_collection[gas_path] = new /datum/tlv/oxygen
		else if(ispath(gas_path, /datum/gas/carbon_dioxide))
			tlv_collection[gas_path] = new /datum/tlv/carbon_dioxide
		else if(meta_info[gas_path][META_GAS_DANGER])
			tlv_collection[gas_path] = new /datum/tlv/dangerous
		else
			tlv_collection[gas_path] = new /datum/tlv/no_checks

	my_area = connected_sensor ? get_area(connected_sensor) : get_area(src)
	alarm_manager = new(src)
	select_mode(src, /datum/air_alarm_mode/filtering, should_apply = FALSE)

	AddElement(/datum/element/connect_loc, atmos_connections)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/air_alarm_general,
		/obj/item/circuit_component/air_alarm,
		/obj/item/circuit_component/air_alarm_scrubbers,
		/obj/item/circuit_component/air_alarm_vents
	))

	GLOB.air_alarms += src
	update_appearance()
	find_and_hang_on_wall()
	register_context()

/obj/machinery/airalarm/process()
	if(!COOLDOWN_FINISHED(src, warning_cooldown))
		return

	speak(warning_message)
	COOLDOWN_START(src, warning_cooldown, AIRALARM_WARNING_COOLDOWN)

/obj/machinery/airalarm/Destroy()
	if(my_area)
		my_area = null
	QDEL_NULL(alarm_manager)
	GLOB.air_alarms -= src
	return ..()

/obj/machinery/airalarm/proc/check_enviroment()
	var/turf/our_turf = connected_sensor ? get_turf(connected_sensor) : get_turf(src)
	var/datum/gas_mixture/environment = our_turf.return_air()
	if(isnull(environment))
		return
	check_danger(our_turf, environment, environment.temperature)

/obj/machinery/airalarm/proc/get_enviroment()
	var/turf/our_turf = connected_sensor ? get_turf(connected_sensor) : get_turf(src)
	return our_turf.return_air()

/obj/machinery/airalarm/power_change()
	check_enviroment()
	return ..()

/obj/machinery/airalarm/on_enter_area(datum/source, area/area_to_register)
	//were already registered to an area. exit from here first before entering into an new area
	if(!isnull(my_area))
		return
	. = ..()

	my_area = connected_sensor ? get_area(connected_sensor) : area_to_register
	update_appearance()

/obj/machinery/airalarm/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] Air Alarm"

/obj/machinery/airalarm/on_exit_area(datum/source, area/area_to_unregister)
	//we cannot unregister from an area we never registered to in the first place
	if(my_area != area_to_unregister)
		return
	. = ..()

	my_area = connected_sensor ? get_area(connected_sensor) : null

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AIR_ALARM_BUILD_NO_CIRCUIT)
			. += span_notice("It is missing air alarm electronics.")
		if(AIR_ALARM_BUILD_NO_WIRES)
			. += span_notice("It is missing wiring.")
		if(AIR_ALARM_BUILD_COMPLETE)
			. += span_notice("Right-click to [locked ? "unlock" : "lock"] the interface.")

/obj/machinery/airalarm/ui_status(mob/user, datum/ui_state/state)
	if(HAS_SILICON_ACCESS(user) && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE

/obj/machinery/airalarm/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	.= ..()

	if (!istype(multi_tool) || locked)
		return .

	if(istype(multi_tool.buffer, /obj/machinery/air_sensor))
		if(!allow_link_change)
			balloon_alert(user, "linking disabled")
			return ITEM_INTERACT_BLOCKING
		connect_sensor(multi_tool.buffer)
		balloon_alert(user, "connected sensor")
		return ITEM_INTERACT_SUCCESS

/obj/machinery/airalarm/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm", name)
		ui.open()

/obj/machinery/airalarm/ui_static_data(mob/user)
	var/list/data = list()
	data["thresholdTypeMap"] = list(
		"warning_min" = TLV_VAR_WARNING_MIN,
		"hazard_min" = TLV_VAR_HAZARD_MIN,
		"warning_max" = TLV_VAR_WARNING_MAX,
		"hazard_max" = TLV_VAR_HAZARD_MAX,
		"all" = TLV_VAR_ALL,
	)
	return data

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list()

	data["locked"] = locked
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["emagged"] = (obj_flags & EMAGGED ? 1 : 0)
	data["dangerLevel"] = danger_level
	data["atmosAlarm"] = !!my_area.active_alarms[ALARM_ATMOS]
	data["fireAlarm"] = my_area.fire
	data["faultStatus"] = my_area.fault_status
	data["faultLocation"] = my_area.fault_location
	data["sensor"] = !!connected_sensor
	data["allowLinkChange"] = allow_link_change

	var/datum/gas_mixture/environment = get_enviroment()
	var/total_moles = environment.total_moles()
	var/temp = environment.temperature
	var/pressure = environment.return_pressure()

	data["envData"] = list()
	if(connected_sensor)
		data["envData"] += list(list(
			"name" = "Linked area",
			"value" = my_area.name
		))
	data["envData"] += list(list(
		"name" = "Pressure",
		"value" = "[round(pressure, 0.01)] kPa",
		"danger" = tlv_collection["pressure"].check_value(pressure)
	))
	data["envData"] += list(list(
		"name" = "Temperature",
		"value" = "[round(temp, 0.01)] Kelvin / [round(temp, 0.01) - T0C] Celcius",
		"danger" = tlv_collection["temperature"].check_value(temp),
	))
	if(total_moles)
		for(var/gas_path in environment.gases)
			var/moles = environment.gases[gas_path][MOLES]
			var/portion = moles / total_moles
			data["envData"] += list(list(
				"name" = GLOB.meta_gas_info[gas_path][META_GAS_NAME],
				"value" = "[round(moles, 0.01)] moles / [round(100 * portion, 0.01)] % / [round(portion * pressure, 0.01)] kPa",
				"danger" = tlv_collection[gas_path].check_value(portion * pressure),
			))

	data["tlvSettings"] = list()
	for(var/threshold in tlv_collection)
		var/datum/tlv/tlv = tlv_collection[threshold]
		var/list/singular_tlv = list()
		if(threshold == "pressure")
			singular_tlv["name"] = "Pressure"
			singular_tlv["unit"] = "kPa"
		else if (threshold == "temperature")
			singular_tlv["name"] = "Temperature"
			singular_tlv["unit"] = "K"
		else
			singular_tlv["name"] = GLOB.meta_gas_info[threshold][META_GAS_NAME]
			singular_tlv["unit"] = "kPa"
		singular_tlv["id"] = threshold
		singular_tlv["warning_min"] = tlv.warning_min
		singular_tlv["hazard_min"] = tlv.hazard_min
		singular_tlv["warning_max"] = tlv.warning_max
		singular_tlv["hazard_max"] = tlv.hazard_max
		data["tlvSettings"] += list(singular_tlv)

	if(!locked || HAS_SILICON_ACCESS(user))
		data["vents"] = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
			data["vents"] += list(list(
				"refID" = REF(vent),
				"long_name" = sanitize(vent.name),
				"power" = vent.on,
				"overclock" = vent.fan_overclocked,
				"integrity" = vent.get_integrity_percentage(),
				"checks" = vent.pressure_checks,
				"excheck" = vent.pressure_checks & ATMOS_EXTERNAL_BOUND,
				"incheck" = vent.pressure_checks & ATMOS_INTERNAL_BOUND,
				"direction" = vent.pump_direction,
				"external" = vent.external_pressure_bound,
				"internal" = vent.internal_pressure_bound,
				"extdefault" = (vent.external_pressure_bound == ONE_ATMOSPHERE),
				"intdefault" = (vent.internal_pressure_bound == 0)
			))
		data["scrubbers"] = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
			var/list/filter_types = list()
			for (var/path in GLOB.meta_gas_info)
				var/list/gas = GLOB.meta_gas_info[path]
				filter_types += list(list("gas_id" = gas[META_GAS_ID], "gas_name" = gas[META_GAS_NAME], "enabled" = (path in scrubber.filter_types)))
			data["scrubbers"] += list(list(
				"refID" = REF(scrubber),
				"long_name" = sanitize(scrubber.name),
				"power" = scrubber.on,
				"scrubbing" = scrubber.scrubbing,
				"widenet" = scrubber.widenet,
				"filter_types" = filter_types,
			))

		data["selectedModePath"] = selected_mode.type
		data["modes"] = list()
		for(var/mode_path in GLOB.air_alarm_modes)
			var/datum/air_alarm_mode/mode = GLOB.air_alarm_modes[mode_path]
			if(!(obj_flags & EMAGGED) && mode.emag)
				continue
			data["modes"] += list(list(
				"name" = mode.name,
				"desc" = mode.desc,
				"danger" = mode.danger,
				"path" = mode.type
			))

		// forgive me holy father
		data["panicSiphonPath"] = /datum/air_alarm_mode/panic_siphon
		data["filteringPath"] = /datum/air_alarm_mode/filtering

	return data

/obj/machinery/airalarm/ui_act(action, params)
	. = ..()

	if(. || buildstage != AIR_ALARM_BUILD_COMPLETE)
		return
	if((locked && !HAS_SILICON_ACCESS(usr)) || (HAS_SILICON_ACCESS(usr) && aidisabled))
		return

	var/mob/user = usr
	var/area/area = connected_sensor ? get_area(connected_sensor) : get_area(src)

	ASSERT(!isnull(area))

	var/ref = params["ref"]
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber
	if(!isnull(ref))
		scrubber = locate(ref) in area.air_scrubbers
		vent = locate(ref) in area.air_vents

	switch (action)
		if ("power")
			var/obj/machinery/atmospherics/components/powering = vent || scrubber
			powering.on = !!params["val"]
			powering.atmos_conditions_changed()
			powering.update_appearance(UPDATE_ICON)

		if("overclock")
			if(isnull(vent))
				return TRUE
			vent.toggle_overclock(source = key_name(user))
			vent.update_appearance(UPDATE_ICON)
			return TRUE

		if ("direction")
			if (isnull(vent))
				return TRUE

			var/value = params["val"]

			if (value == ATMOS_DIRECTION_SIPHONING || value == ATMOS_DIRECTION_RELEASING)
				vent.pump_direction = value
				vent.update_appearance(UPDATE_ICON)
		if ("incheck")
			if (isnull(vent))
				return TRUE

			var/new_checks = clamp((text2num(params["val"]) || 0) ^ ATMOS_INTERNAL_BOUND, NONE, ATMOS_BOUND_MAX)
			vent.pressure_checks = new_checks
			vent.update_appearance(UPDATE_ICON)
		if ("excheck")
			if (isnull(vent))
				return TRUE

			var/new_checks = clamp((text2num(params["val"]) || 0) ^ ATMOS_EXTERNAL_BOUND, NONE, ATMOS_BOUND_MAX)
			vent.pressure_checks = new_checks
			vent.update_appearance(UPDATE_ICON)
		if ("set_internal_pressure")
			if (isnull(vent))
				return TRUE

			var/old_pressure = vent.internal_pressure_bound
			var/new_pressure = clamp(text2num(params["value"]), 0, ATMOS_PUMP_MAX_PRESSURE)
			vent.internal_pressure_bound = new_pressure
			if (old_pressure != new_pressure)
				vent.investigate_log("internal pressure was set to [new_pressure] by [key_name(user)]", INVESTIGATE_ATMOS)
		if ("reset_internal_pressure")
			if (isnull(vent))
				return TRUE

			if (vent.internal_pressure_bound != 0)
				vent.internal_pressure_bound = 0
				vent.investigate_log("internal pressure was reset by [key_name(user)]", INVESTIGATE_ATMOS)
		if ("set_external_pressure")
			if (isnull(vent))
				return TRUE

			var/old_pressure = vent.external_pressure_bound
			var/new_pressure = clamp(text2num(params["value"]), 0, ATMOS_PUMP_MAX_PRESSURE)

			if (old_pressure == new_pressure)
				return TRUE

			vent.external_pressure_bound = new_pressure
			vent.investigate_log("external pressure was set to [new_pressure] by [key_name(user)]", INVESTIGATE_ATMOS)
			vent.update_appearance(UPDATE_ICON)
		if ("reset_external_pressure")
			if (isnull(vent))
				return TRUE

			if (vent.external_pressure_bound == ATMOS_PUMP_MAX_PRESSURE)
				return TRUE

			vent.external_pressure_bound = ATMOS_PUMP_MAX_PRESSURE
			vent.investigate_log("internal pressure was reset by [key_name(user)]", INVESTIGATE_ATMOS)
			vent.update_appearance(UPDATE_ICON)
		if ("scrubbing")
			if (isnull(scrubber))
				return TRUE

			scrubber.set_scrubbing(!!params["val"], user)
		if ("widenet")
			if (isnull(scrubber))
				return TRUE

			scrubber.set_widenet(!!params["val"])
		if ("toggle_filter")
			if (isnull(scrubber))
				return TRUE

			scrubber.toggle_filters(params["val"])
		if ("mode")
			select_mode(user, text2path(params["mode"]))
			investigate_log("was turned to [selected_mode.name] mode by [key_name(user)]", INVESTIGATE_ATMOS)

		if ("set_threshold")
			var/threshold = text2path(params["threshold"]) || params["threshold"]
			var/datum/tlv/tlv = tlv_collection[threshold]
			if(isnull(tlv))
				return
			var/threshold_type = params["threshold_type"]
			var/value = params["value"]
			tlv.set_value(threshold_type, value)
			investigate_log("threshold value for [threshold]:[threshold_type] was set to [value] by [key_name(usr)]", INVESTIGATE_ATMOS)

			check_enviroment()

		if("reset_threshold")
			var/threshold = text2path(params["threshold"]) || params["threshold"]
			var/datum/tlv/tlv = tlv_collection[threshold]
			if(isnull(tlv))
				return
			var/threshold_type = params["threshold_type"]
			tlv.reset_value(threshold_type)
			investigate_log("threshold value for [threshold]:[threshold_type] was reset by [key_name(usr)]", INVESTIGATE_ATMOS)

			check_enviroment()

		if ("alarm")
			if (alarm_manager.send_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_HAZARD

		if ("reset")
			if (alarm_manager.clear_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_NONE

		if ("disconnect_sensor")
			if(allow_link_change)
				disconnect_sensor()

		if ("lock")
			togglelock(usr)
			return TRUE

	update_appearance()

	return TRUE

/obj/machinery/airalarm/update_appearance(updates)
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		set_light(0)
		return

	var/color
	if(danger_level == AIR_ALARM_ALERT_HAZARD)
		color = "#FF0022" // red
	else if(danger_level == AIR_ALARM_ALERT_WARNING || my_area.active_alarms[ALARM_ATMOS])
		color = "#FFAA00" // yellow
	else
		color = "#00FFCC" // teal

	set_light(1.5, 1, color)

/obj/machinery/airalarm/update_icon_state()
	if(panel_open)
		switch(buildstage)
			if(AIR_ALARM_BUILD_COMPLETE)
				icon_state = "alarmx"
			if(AIR_ALARM_BUILD_NO_WIRES)
				icon_state = "alarm_b2"
			if(AIR_ALARM_BUILD_NO_CIRCUIT)
				icon_state = "alarm_b1"
		return ..()

	icon_state = isnull(connected_sensor) ? "alarmp" : "alarmp_remote"
	return ..()

/obj/machinery/airalarm/update_overlays()
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/state
	if(danger_level == AIR_ALARM_ALERT_HAZARD)
		state = "alarm1"
	else if(danger_level == AIR_ALARM_ALERT_WARNING || my_area.active_alarms[ALARM_ATMOS])
		state = "alarm2"
	else
		state = "alarm0"

	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, src, alpha = src.alpha)

/// Check the current air and update our danger level.
/// [/obj/machinery/airalarm/var/danger_level]
/obj/machinery/airalarm/proc/check_danger(turf/location, datum/gas_mixture/environment, exposed_temperature)
	SIGNAL_HANDLER
	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	if(!environment)
		return

	var/old_danger = danger_level
	danger_level = AIR_ALARM_ALERT_NONE

	var/total_moles = environment.total_moles()
	var/pressure = environment.return_pressure()
	var/temp = environment.return_temperature()

	danger_level = max(danger_level, tlv_collection["pressure"].check_value(pressure))
	danger_level = max(danger_level, tlv_collection["temperature"].check_value(temp))
	if(total_moles)
		for(var/gas_path in environment.gases)
			var/moles = environment.gases[gas_path][MOLES]
			danger_level = max(danger_level, tlv_collection[gas_path].check_value(pressure * moles / total_moles))

	if(danger_level)
		alarm_manager.send_alarm(ALARM_ATMOS)
		if(pressure <= WARNING_LOW_PRESSURE && temp <= BODYTEMP_COLD_WARNING_1+10)
			warning_message = "Danger! Low pressure and temperature detected."
			return
		if(pressure <= WARNING_LOW_PRESSURE && temp >= BODYTEMP_HEAT_WARNING_1-27)
			warning_message = "Danger! Low pressure and high temperature detected."
			return
		if(pressure >= WARNING_HIGH_PRESSURE && temp >= BODYTEMP_HEAT_WARNING_1-27)
			warning_message = "Danger! High pressure and temperature detected."
			return
		if(pressure >= WARNING_HIGH_PRESSURE && temp <= BODYTEMP_COLD_WARNING_1+10)
			warning_message = "Danger! High pressure and low temperature detected."
			return
		if(pressure <= WARNING_LOW_PRESSURE)
			warning_message = "Danger! Low pressure detected."
			return
		if(pressure >= WARNING_HIGH_PRESSURE)
			warning_message = "Danger! High pressure detected."
			return
		if(temp <= BODYTEMP_COLD_WARNING_1+10)
			warning_message = "Danger! Low temperature detected."
			return
		if(temp >= BODYTEMP_HEAT_WARNING_1-27)
			warning_message = "Danger! High temperature detected."
			return
		else
			warning_message = null

	else
		alarm_manager.clear_alarm(ALARM_ATMOS)
		warning_message = null

	if(old_danger != danger_level)
		update_appearance()

	selected_mode.replace(my_area, pressure)

/obj/machinery/airalarm/proc/select_mode(atom/source, datum/air_alarm_mode/mode_path, should_apply = TRUE)
	var/datum/air_alarm_mode/new_mode = GLOB.air_alarm_modes[mode_path]
	if(!new_mode)
		return
	if(new_mode.emag && !(obj_flags & EMAGGED))
		return
	selected_mode = new_mode
	if(should_apply)
		selected_mode.apply(my_area)
	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, source)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 27)

/obj/machinery/airalarm/proc/speak(warning_message)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!speaker_enabled)
		return
	if(!warning_message)
		return

	say(warning_message)

/// Used for unlocked air alarm helper, which unlocks the air alarm.
/obj/machinery/airalarm/proc/unlock()
	locked = FALSE

/// Used for syndicate_access air alarm helper, which sets air alarm's required access to syndicate_access.
/obj/machinery/airalarm/proc/give_syndicate_access()
	req_access = list(ACCESS_SYNDICATE)

///Used for away_general_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_away_general_access()
	req_access = list(ACCESS_AWAY_GENERAL)

///Used for engine_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_engine_access()
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINEERING)

///Used for mixingchamber_access air alarm helper, which set air alarm's required access to away_general_access.
/obj/machinery/airalarm/proc/give_mixingchamber_access()
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ORDNANCE)

///Used for all_access air alarm helper, which set air alarm's required access to null.
/obj/machinery/airalarm/proc/give_all_access()
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

///Used for air alarm cold room tlv helper, which sets cold room temperature and pressure alarm thresholds
/obj/machinery/airalarm/proc/set_tlv_cold_room()
	tlv_collection["temperature"] = new /datum/tlv/cold_room_temperature
	tlv_collection["pressure"] = new /datum/tlv/cold_room_pressure

///Used for air alarm no tlv helper, which removes alarm thresholds
/obj/machinery/airalarm/proc/set_tlv_no_checks()
	tlv_collection["temperature"] = new /datum/tlv/no_checks
	tlv_collection["pressure"] = new /datum/tlv/no_checks

///Used for air alarm link helper, which connects air alarm to a sensor with corresponding chamber_id
/obj/machinery/airalarm/proc/setup_chamber_link()
	var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[GLOB.map_loaded_sensors[air_sensor_chamber_id]]
	if(isnull(sensor))
		log_mapping("[src] at [AREACOORD(src)] tried to connect to a sensor, but no sensor with chamber_id:[air_sensor_chamber_id] found!")
		return
	connect_sensor(sensor)

///Used to connect air alarm with a sensor
/obj/machinery/airalarm/proc/connect_sensor(obj/machinery/air_sensor/sensor)
	if(!isnull(connected_sensor))
		UnregisterSignal(connected_sensor, COMSIG_QDELETING)
	connected_sensor = sensor
	RegisterSignal(connected_sensor, COMSIG_QDELETING, PROC_REF(disconnect_sensor))
	my_area = get_area(connected_sensor)

	check_enviroment()

	update_appearance()
	update_name()

///Used to reset the air alarm to default configuration after disconnecting from air sensor
/obj/machinery/airalarm/proc/disconnect_sensor()
	UnregisterSignal(connected_sensor, COMSIG_QDELETING)
	connected_sensor = null
	my_area = get_area(src)

	check_enviroment()

	update_appearance()
	update_name()

#undef AIRALARM_WARNING_COOLDOWN
