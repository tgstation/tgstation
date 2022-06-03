#define AALARM_MODE_SCRUBBING 1
#define AALARM_MODE_VENTING 2 //makes draught
#define AALARM_MODE_PANIC 3 //like siphon, but stronger (enables widenet)
#define AALARM_MODE_REPLACEMENT 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF 5
#define AALARM_MODE_FLOOD 6 //Emagged mode; turns off scrubbers and pressure checks on vents
#define AALARM_MODE_SIPHON 7 //Scrubbers suck air
#define AALARM_MODE_CONTAMINATED 8 //Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_REFILL 9 //just like normal, but with triple the air output

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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 90, ACID = 30)
	resistance_flags = FIRE_PROOF

	/// Danger level of this particular air alarm. See [/datum/alarm_threshold/proc/check_value] for the possible values.
	var/danger_level = 0
	/// The current operating mode of the air alarm.
	var/mode = AALARM_MODE_SCRUBBING

	var/locked = TRUE
	var/ai_disabled = 0
	var/shorted = 0
	var/build_stage = AIRALARM_BUILD_COMPLETE // 2 = complete, 1 = no wires,  0 = circuit gone

	var/frequency = FREQ_ATMOS_CONTROL
	var/datum/radio_frequency/radio_connection

	var/alarm_frequency = FREQ_ATMOS_ALARMS
	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/static/list/atmos_connections = list(COMSIG_TURF_EXPOSE = .proc/check_air_danger_level)
	
	/// Our [alarm_threshold][/datum/alarm_threshold] list manager.
	/// References the global datum [alarm_threshold_collection] for most cases. Read more on [/datum/alarm_threshold_collection]
	/// Will instantiate a new one if modified.
	var/datum/alarm_threshold_collection/alarm_thresholds

	///A reference to the area we are in. Not really necessary but saves us from having to fetch the area every time.
	var/area/my_area

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	wires = new /datum/wires/airalarm(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		build_stage = AIRALARM_BUILD_NO_CIRCUIT
		panel_open = TRUE

	if(name == initial(name))
		name = "[get_area_name(src)] Air Alarm"

	alarm_manager = new(src)
	my_area = get_area(src)
	update_appearance()

	set_frequency(frequency)
	AddElement(/datum/element/connect_loc, atmos_connections)

	alarm_thresholds = GLOB.alarm_threshold_collection

/obj/machinery/airalarm/Destroy()
	my_area = null
	SSradio.remove_object(src, frequency)
	QDEL_NULL(wires)
	QDEL_NULL(alarm_manager)
	alarm_thresholds = null
	return ..()

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	switch(build_stage)
		if(AIRALARM_BUILD_NO_CIRCUIT)
			. += span_notice("It is missing air alarm electronics.")
		if(AIRALARM_BUILD_NO_WIRES)
			. += span_notice("It is missing wiring.")
		if(AIRALARM_BUILD_COMPLETE)
			. += span_notice("Right-click to [locked ? "unlock" : "lock"] the interface.")

/obj/machinery/airalarm/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_appearance()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				ai_disabled = FALSE


/obj/machinery/airalarm/proc/shock(mob/user, prb)
	if((machine_stat & (NOPOWER))) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src, 1, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/airalarm/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/airalarm/proc/send_signal(target, list/command, atom/user)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new(command)
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"
	signal.data["user"] = user
	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)

	return TRUE

/obj/machinery/airalarm/proc/get_mode_name(mode_value)
	switch(mode_value)
		if(AALARM_MODE_SCRUBBING)
			return "Filtering"
		if(AALARM_MODE_CONTAMINATED)
			return "Contaminated"
		if(AALARM_MODE_VENTING)
			return "Draught"
		if(AALARM_MODE_REFILL)
			return "Refill"
		if(AALARM_MODE_PANIC)
			return "Panic Siphon"
		if(AALARM_MODE_REPLACEMENT)
			return "Cycle"
		if(AALARM_MODE_SIPHON)
			return "Siphon"
		if(AALARM_MODE_OFF)
			return "Off"
		if(AALARM_MODE_FLOOD)
			return "Flood"

/obj/machinery/airalarm/proc/apply_mode(atom/signal_source)
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = 1,
					"widenet" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_CONTAMINATED)
			var/list/gas_to_scrub = list(subtypesof(/datum/gas))
			gas_to_scrub -= list(/datum/gas/oxygen, /datum/gas/nitrogen)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = gas_to_scrub,
					"scrubbing" = 1,
					"widenet" = 1
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_VENTING)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				), signal_source)
		if(AALARM_MODE_REFILL)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = 1,
					"widenet" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE * 3
				), signal_source)
		if(AALARM_MODE_PANIC, AALARM_MODE_REPLACEMENT)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 1,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_SIPHON)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)

		if(AALARM_MODE_OFF)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_FLOOD)
			for(var/device_id in my_area.air_scrub_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in my_area.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 2,
					"set_internal_pressure" = 0
				), signal_source)

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
		switch(build_stage)
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
		if(AIR_ALARM_THRESHOLD_SAFE)
			state = "alarm0"
		if(AIR_ALARM_THRESHOLD_WARNING)
			state = "alarm2" //yes, alarm2 is yellow alarm
		if(AIR_ALARM_THRESHOLD_HAZARDOUS)
			state = "alarm1"

	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, alpha = src.alpha)

/**
 * Main proc for throwing a shitfit if the air isnt right.
 * Goes into warning mode if gas parameters are beyond the tlv warning bounds, goes into hazard mode if gas parameters are beyond tlv hazard bounds
 */
/obj/machinery/airalarm/proc/check_air_danger_level(turf/location, datum/gas_mixture/environment, exposed_temperature)
	SIGNAL_HANDLER
	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		return	
	
	var/danger_info = alarm_thresholds.check_value(environment)
	var/new_danger = AIR_ALARM_THRESHOLD_SAFE
	for(var/entry in danger_info)
		if(danger_info[entry] > new_danger)
			new_danger = danger_info[entry]

	if(new_danger != danger_level)
		danger_level = new_danger
		INVOKE_ASYNC(src, .proc/change_area_danger_level)

	if(mode == AALARM_MODE_REPLACEMENT && environment.return_pressure() < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		INVOKE_ASYNC(src, .proc/apply_mode, src)

/**
 * Changes the danger level of the area.
 * 
 * Arguments: 
 * * forced_value - Optional arg. Setting this will override the actual danger value of the environment.
 */
/obj/machinery/airalarm/proc/change_area_danger_level(forced_value)
	var/new_area_danger_level = 0
	
	if(isnull(forced_value))
		for(var/obj/machinery/airalarm/air_alarm in my_area)
			if (air_alarm.machine_stat & (NOPOWER|BROKEN))
				continue
			if (air_alarm.shorted)
				continue
			new_area_danger_level = max(air_alarm.danger_level, new_area_danger_level)
	else
		new_area_danger_level = forced_value

	var/did_anything_happen
	if(new_area_danger_level != AIR_ALARM_THRESHOLD_SAFE)
		did_anything_happen = alarm_manager.send_alarm(ALARM_ATMOS)
	else
		did_anything_happen = alarm_manager.clear_alarm(ALARM_ATMOS)

	if(did_anything_happen) //if something actually changed
		post_alert(new_area_danger_level)

	update_appearance()

/obj/machinery/airalarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency)
		return

	var/datum/signal/alert_signal = new(list(
		"zone" = get_area_name(src, TRUE),
		"type" = "Atmospheric"
	))
	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal, range = -1)

/obj/machinery/airalarm/ui_status(mob/user)
	if(user.has_unlimited_silicon_privilege && ai_disabled)
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
	data["warning_min"] = AIR_ALARM_THRESHOLD_WARNING_MIN
	data["hazard_min"] = AIR_ALARM_THRESHOLD_HAZARD_MIN
	data["warning_max"] = AIR_ALARM_THRESHOLD_WARNING_MAX
	data["hazard_max"] = AIR_ALARM_THRESHOLD_HAZARD_MAX
	return data

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = (obj_flags & EMAGGED ? 1 : 0),
		"danger_level" = danger_level,
	)

	data["atmos_alarm"] = !!my_area.active_alarms[ALARM_ATMOS]
	data["fire_alarm"] = my_area.fire

	/// List of pressure, temperature, and all gas present.
	var/list/sensor_reading = list()

	var/turf/our_turf = get_turf(src)
	var/datum/gas_mixture/environment = our_turf.return_air()

	// We want the value param to be formatted and turned into strings here, since we put multiple info in the gas one.
	var/pressure = environment.return_pressure()
	sensor_reading["pressure"] = list(
		"name" = "Pressure",
		"value" = "[round(environment.return_pressure(), 0.01)] kPa",
	)
	sensor_reading["temperature"] = list(
		"name" = "Temperature",
		"value" = "[round(environment.return_temperature(), 0.01)] K",
	)
	var/total_moles = environment.total_moles()
	for(var/gas_path in environment.gases)
		var/moles = environment.gases[gas_path][MOLES]
		var/percentage = moles / total_moles
		var/partial_pressure = percentage * pressure
		sensor_reading[gas_path] = list(
			"name" = environment.gases[gas_path][GAS_META][META_GAS_NAME],
			"value" = "[round(moles, 0.01)] moles ([round(percentage * 100, 0.01)]%)  ([round(partial_pressure, 0.01)] kPa)"
		)
	var/list/threshold_status = alarm_thresholds.check_value(environment) // Inefficient
	for (var/entry in sensor_reading)
		sensor_reading[entry]["status"] = threshold_status[entry] || AIR_ALARM_THRESHOLD_SAFE

	data["sensor_reading"] = sensor_reading

	if(!locked || user.has_unlimited_silicon_privilege)
		data["vents"] = list()
		for(var/id_tag in my_area.air_vent_info)
			var/long_name = GLOB.air_vent_names[id_tag]
			var/list/info = my_area.air_vent_info[id_tag]
			if(!info || info["frequency"] != frequency)
				continue
			data["vents"] += list(list(
					"id_tag" = id_tag,
					"long_name" = sanitize(long_name),
					"power" = info["power"],
					"checks" = info["checks"],
					"direction" = info["direction"],
					"external" = info["external"],
					"internal" = info["internal"],
					"extdefault"= (info["external"] == ONE_ATMOSPHERE),
					"intdefault"= (info["internal"] == 0),
					"incheck" = info["checks"] & VENT_PUMP_INT_BOUND,
					"excheck" = info["checks"] & VENT_PUMP_EXT_BOUND,
				))
		data["scrubbers"] = list()
		for(var/id_tag in my_area.air_scrub_info)
			var/long_name = GLOB.air_scrub_names[id_tag]
			var/list/info = my_area.air_scrub_info[id_tag]
			if(!info || info["frequency"] != frequency)
				continue
			data["scrubbers"] += list(list(
					"id_tag" = id_tag,
					"long_name" = sanitize(long_name),
					"power" = info["power"],
					"scrubbing" = info["scrubbing"],
					"widenet" = info["widenet"],
					"filter_types" = info["filter_types"]
				))
		data["mode"] = mode

		data["modes"] = list(
			list("name" = "Filtering - Scrubs out contaminants", "mode" = AALARM_MODE_SCRUBBING, "danger" = FALSE),
			list("name" = "Contaminated - Scrubs out ALL contaminants quickly","mode" = AALARM_MODE_CONTAMINATED, "danger" = FALSE),
			list("name" = "Draught - Siphons out air while replacing", "mode" = AALARM_MODE_VENTING, "danger" = FALSE),
			list("name" = "Refill - Triple vent output", "mode" = AALARM_MODE_REFILL, "danger" = TRUE),
			list("name" = "Cycle - Siphons air before replacing", "mode" = AALARM_MODE_REPLACEMENT, "danger" = TRUE),
			list("name" = "Siphon - Siphons air out of the room", "mode" = AALARM_MODE_SIPHON, "danger" = TRUE),
			list("name" = "Panic Siphon - Siphons air out of the room quickly","mode" = AALARM_MODE_PANIC, "danger" = TRUE),
			list("name" = "Off - Shuts off vents and scrubbers", "mode" = AALARM_MODE_OFF, "danger" = FALSE),
		)
		if(obj_flags & EMAGGED)
			data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents", "mode" = AALARM_MODE_FLOOD, "selected" = mode == AALARM_MODE_FLOOD, "danger" = 1))

		data["thresholds"] = alarm_thresholds.return_info()
	return data

/obj/machinery/airalarm/ui_act(action, params)
	. = ..()

	if(. || build_stage != AIRALARM_BUILD_COMPLETE)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && ai_disabled))
		return
	var/device_id = params["id_tag"]
	switch(action)
		if("lock")
			if(!usr.has_unlimited_silicon_privilege || wires.is_cut(WIRE_IDSCAN))
				return FALSE
			locked = !locked
		if("power", "toggle_filter", "widenet", "scrubbing", "direction")
			send_signal(device_id, list("[action]" = params["val"]), usr)
		if("excheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^1), usr)
		if("incheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^2), usr)
		if("set_external_pressure", "set_internal_pressure")
			var/target = params["value"]
			if(isnull(target))
				return FALSE
			send_signal(device_id, list("[action]" = target), usr)
		if("reset_external_pressure")
			send_signal(device_id, list("set_external_pressure" = ONE_ATMOSPHERE), usr)
		if("reset_internal_pressure")
			send_signal(device_id, list("set_internal_pressure" = 0), usr)
		if("mode")
			mode = text2num(params["mode"])
			investigate_log("was turned to [get_mode_name(mode)] mode by [key_name(usr)]",INVESTIGATE_ATMOS)
			apply_mode(usr)
		if("alarm")
			change_area_danger_level(AIR_ALARM_THRESHOLD_HAZARDOUS)
		if("reset")
			change_area_danger_level(AIR_ALARM_THRESHOLD_SAFE)
		if("set_threshold")
			var/value = params["new_threshold"]
			if(!isnum(value))
				return FALSE
			value = max(value, AIR_ALARM_THRESHOLD_IGNORE)
			var/threshold_criteria = params["threshold_criteria"]
			threshold_criteria = text2path(threshold_criteria) || threshold_criteria
			var/threshold_type = params["threshold_type"]
			alarm_thresholds = alarm_thresholds.set_value(threshold_criteria, threshold_type, value)
			
			var/turf/location = get_turf(src)
			var/datum/gas_mixture/air = location.return_air()
			check_air_danger_level(location, air, air.temperature)
		if("kill_threshold")
			var/threshold_criteria = params["threshold_criteria"]
			threshold_criteria = text2path(threshold_criteria) || threshold_criteria
			alarm_thresholds = alarm_thresholds.kill_criteria(threshold_criteria)
			
			var/turf/location = get_turf(src)
			var/datum/gas_mixture/air = location.return_air()
			check_air_danger_level(location, air, air.temperature)
		if("reset_threshold")
			var/threshold_criteria = params["threshold_criteria"]
			threshold_criteria = text2path(threshold_criteria) || threshold_criteria
			alarm_thresholds = alarm_thresholds.reset_criteria(threshold_criteria)
			
			var/turf/location = get_turf(src)
			var/datum/gas_mixture/air = location.return_air()
			check_air_danger_level(location, air, air.temperature)
	update_appearance()
	return TRUE

#undef AALARM_MODE_SCRUBBING
#undef AALARM_MODE_VENTING
#undef AALARM_MODE_PANIC
#undef AALARM_MODE_REPLACEMENT
#undef AALARM_MODE_OFF
#undef AALARM_MODE_FLOOD
#undef AALARM_MODE_SIPHON
#undef AALARM_MODE_CONTAMINATED
#undef AALARM_MODE_REFILL
#undef AALARM_REPORT_TIMEOUT

/obj/item/electronics/airalarm
	name = "air alarm electronics"
	icon_state = "airalarm_electronics"

/obj/item/wallframe/airalarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/machinery/airalarm
	pixel_shift = 24

