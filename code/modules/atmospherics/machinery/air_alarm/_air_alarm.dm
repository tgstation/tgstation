#define AALARM_REPORT_TIMEOUT 100

/obj/machinery/airalarm
	name = "air alarm"
	desc = "A machine that monitors atmosphere levels. Goes off if the area is dangerous."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarmp"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 0.33
	armor_type = /datum/armor/machinery_airalarm
	resistance_flags = FIRE_PROOF

	/// Current alert level, found in code/__DEFINES/atmospherics/atmos_machinery.dm
	/// AIR_ALARM_ALERT_NONE, AIR_ALARM_ALERT_MINOR, AIR_ALARM_ALERT_SEVERE
	var/danger_level = AIR_ALARM_ALERT_NONE

	var/datum/air_alarm_mode/selected_mode
	///A reference to the area we are in
	var/area/my_area

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = AIRALARM_BUILD_COMPLETE // 2 = complete, 1 = no wires,  0 = circuit gone

	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/static/list/atmos_connections = list(COMSIG_TURF_EXPOSE = PROC_REF(check_air_dangerlevel))

	// An assoc list of [datum/tlv]s, indexed by "pressure", "temperature", and [datum/gas] typepaths.
	var/list/datum/tlv/tlv_collection

GLOBAL_LIST_EMPTY_TYPED(air_alarms, /obj/machinery/airalarm)

/datum/armor/machinery_airalarm
	energy = 100
	fire = 90
	acid = 30

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	wires = new /datum/wires/airalarm(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = AIRALARM_BUILD_NO_CIRCUIT
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

	selected_mode = GLOB.air_alarm_modes[/datum/air_alarm_mode/filtering]

	alarm_manager = new(src)
	my_area = get_area(src)
	update_appearance()

	AddElement(/datum/element/connect_loc, atmos_connections)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/air_alarm_general,
		/obj/item/circuit_component/air_alarm,
		/obj/item/circuit_component/air_alarm_scrubbers,
		/obj/item/circuit_component/air_alarm_vents
	))

	GLOB.air_alarms += src

/obj/machinery/airalarm/Destroy()
	if(my_area)
		my_area = null
	QDEL_NULL(wires)
	QDEL_NULL(alarm_manager)
	GLOB.air_alarms -= src
	return ..()

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AIRALARM_BUILD_NO_CIRCUIT)
			. += span_notice("It is missing air alarm electronics.")
		if(AIRALARM_BUILD_NO_WIRES)
			. += span_notice("It is missing wiring.")
		if(AIRALARM_BUILD_COMPLETE)
			. += span_notice("Right-click to [locked ? "unlock" : "lock"] the interface.")

/obj/machinery/airalarm/ui_status(mob/user)
	if(user.has_unlimited_silicon_privilege && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE


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
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["emagged"] = (obj_flags & EMAGGED ? 1 : 0)
	data["dangerLevel"] = danger_level
	data["atmosAlarm"] = !!my_area.active_alarms[ALARM_ATMOS]
	data["fireAlarm"] = my_area.fire

	var/turf/turf = get_turf(src)
	var/datum/gas_mixture/environment = turf.return_air()
	var/total_moles = environment.total_moles()
	var/temp = environment.temperature
	var/pressure = total_moles * R_IDEAL_GAS_EQUATION * temp / environment.volume

	data["envData"] = list()
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
			singular_tlv += list(
				"name" = "Pressure",
				"unit" = "kPa",
			)
		else if (threshold == "temperature")
			singular_tlv += list(
				"name" = "Temperature",
				"unit" = "K",
			)
		else
			singular_tlv += list(
				"name" = GLOB.meta_gas_info[threshold][META_GAS_NAME],
				"unit" = "kPa",
			)
		singular_tlv += list(
			"id" = threshold,
			"warning_min" = tlv.warning_min,
			"hazard_min" = tlv.hazard_min,
			"warning_max" = tlv.warning_max,
			"hazard_max" = tlv.hazard_max,
		)
		data["tlvSettings"] += list(singular_tlv)

	if(!locked || user.has_unlimited_silicon_privilege)
		data["vents"] = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
			data["vents"] += list(list(
				"refID" = REF(vent),
				"long_name" = sanitize(vent.name),
				"power" = vent.on,
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

	if(. || buildstage != AIRALARM_BUILD_COMPLETE)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return

	var/mob/user = usr
	var/area/area = get_area(src)
	ASSERT(!isnull(area))

	var/ref = params["ref"]

	// Possible machines this can refer to
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = isnull(ref) ? null : locate(ref) in area.air_vents
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = isnull(ref) ? null : locate(ref) in area.air_scrubbers

	switch (action)
		if ("power")
			if (!isnull(vent))
				vent.on = !!params["val"]
				vent.update_appearance(UPDATE_ICON)
				vent.check_atmos_process()
			else if (!isnull(scrubber))
				scrubber.on = !!params["val"]
				scrubber.update_appearance(UPDATE_ICON)
				scrubber.check_atmos_process()
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

			var/turf/our_turf = get_turf(src)
			var/datum/gas_mixture/environment = our_turf.return_air()
			check_air_dangerlevel(our_turf, environment, environment.temperature)

		if("reset_threshold")
			var/threshold = text2path(params["threshold"]) || params["threshold"]
			var/datum/tlv/tlv = tlv_collection[threshold]
			if(isnull(tlv))
				return
			var/threshold_type = params["threshold_type"]
			tlv.reset_value(threshold_type)
			investigate_log("threshold value for [threshold]:[threshold_type] was reset by [key_name(usr)]", INVESTIGATE_ATMOS)

			var/turf/our_turf = get_turf(src)
			var/datum/gas_mixture/environment = our_turf.return_air()
			check_air_dangerlevel(our_turf, environment, environment.temperature)

		if ("alarm")
			if (alarm_manager.send_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_SEVERE

		if ("reset")
			if (alarm_manager.clear_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_NONE

	update_appearance()

	return TRUE

/obj/machinery/airalarm/update_appearance(updates)
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		set_light(0)
		return

	var/area/our_area = get_area(src)
	var/color
	switch(max(danger_level, !!our_area.active_alarms[ALARM_ATMOS]))
		if(0)
			color = "#03A728" // green
		if(1)
			color = "#EC8B2F" // yellow
		if(2)
			color = "#DA0205" // red

	set_light(1.4, 1, color)

/obj/machinery/airalarm/update_icon_state()
	if(panel_open)
		switch(buildstage)
			if(AIRALARM_BUILD_COMPLETE)
				icon_state = "alarmx"
			if(AIRALARM_BUILD_NO_WIRES)
				icon_state = "alarm_b2"
			if(AIRALARM_BUILD_NO_CIRCUIT)
				icon_state = "alarm_b1"
		return ..()

	icon_state = "alarmp"
	return ..()

/obj/machinery/airalarm/update_overlays()
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/area/our_area = get_area(src)
	var/state
	switch(max(danger_level, !!our_area.active_alarms[ALARM_ATMOS]))
		if(0)
			state = "alarm0"
		if(1)
			state = "alarm2" //yes, alarm2 is yellow alarm
		if(2)
			state = "alarm1"

	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, src, alpha = src.alpha)

/**
 * main proc for throwing a shitfit if the air isnt right.
 * goes into warning mode if gas parameters are beyond the tlv warning bounds, goes into hazard mode if gas parameters are beyond tlv hazard bounds
 *
 */
/obj/machinery/airalarm/proc/check_air_dangerlevel(turf/location, datum/gas_mixture/environment, exposed_temperature)
	SIGNAL_HANDLER
	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/datum/tlv/current_tlv
	//cache for sanic speed (lists are references anyways)
	var/list/cached_tlv = tlv_collection

	var/list/env_gases = environment.gases
	var/partial_pressure = R_IDEAL_GAS_EQUATION * exposed_temperature / environment.volume

	current_tlv = cached_tlv["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = current_tlv.check_value(environment_pressure)

	current_tlv = cached_tlv["temperature"]
	var/temperature_dangerlevel = current_tlv.check_value(exposed_temperature)

	var/gas_dangerlevel = 0
	for(var/gas_id in env_gases)
		current_tlv = cached_tlv[gas_id]
		if(!current_tlv) // We're not interested in this gas, it seems.
			continue
		gas_dangerlevel = max(gas_dangerlevel, current_tlv.check_value(env_gases[gas_id][MOLES] * partial_pressure))

	environment.garbage_collect()

	var/old_danger_level = danger_level
	danger_level = max(pressure_dangerlevel, temperature_dangerlevel, gas_dangerlevel)

	if(old_danger_level != danger_level)
		INVOKE_ASYNC(src, PROC_REF(apply_danger_level))
	if(istype(selected_mode, /datum/air_alarm_mode/cycle) && environment_pressure < ONE_ATMOSPHERE * 0.05)
		var/datum/air_alarm_mode/cycle/typed_mode = selected_mode
		typed_mode.replace(my_area)

/obj/machinery/airalarm/proc/apply_danger_level()

	var/new_area_danger_level = 0
	for(var/obj/machinery/airalarm/AA in my_area)
		if (!(AA.machine_stat & (NOPOWER|BROKEN)) && !AA.shorted)
			new_area_danger_level = clamp(max(new_area_danger_level, AA.danger_level), 0, 1)

	var/did_anything_happen
	if(new_area_danger_level)
		did_anything_happen = alarm_manager.send_alarm(ALARM_ATMOS)
	else
		did_anything_happen = alarm_manager.clear_alarm(ALARM_ATMOS)
	if(did_anything_happen) //if something actually changed
		danger_level = new_area_danger_level

	update_appearance()

/obj/machinery/airalarm/proc/select_mode(atom/source, datum/air_alarm_mode/mode_path)
	var/datum/air_alarm_mode/new_mode = GLOB.air_alarm_modes[mode_path]
	if(!new_mode)
		return
	if(new_mode.emag && !(obj_flags & EMAGGED))
		return
	selected_mode = new_mode
	selected_mode.apply(my_area)
	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, source)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 24)

/proc/extract_id_tags(list/objects)
	var/list/tags = list()

	for (var/obj/object as anything in objects)
		tags += object.id_tag

	return tags

/proc/find_by_id_tag(list/objects, id_tag)
	for (var/obj/object as anything in objects)
		if (object.id_tag == id_tag)
			return object

	return null
