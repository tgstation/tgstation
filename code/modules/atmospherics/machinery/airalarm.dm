// A datum for dealing with threshold limit values
/datum/tlv
	var/warning_min
	var/warning_max
	var/hazard_min
	var/hazard_max

/datum/tlv/New(min2 as num, min1 as num, max1 as num, max2 as num)
	if(min2)
		hazard_min = min2
	if(min1)
		warning_min = min1
	if(max1)
		warning_max = max1
	if(max2)
		hazard_max = max2

/datum/tlv/proc/get_danger_level(val)
	if(hazard_max != TLV_DONT_CHECK && val >= hazard_max)
		return TLV_OUTSIDE_HAZARD_LIMIT
	if(hazard_min != TLV_DONT_CHECK && val <= hazard_min)
		return TLV_OUTSIDE_HAZARD_LIMIT
	if(warning_max != TLV_DONT_CHECK && val >= warning_max)
		return TLV_OUTSIDE_WARNING_LIMIT
	if(warning_min != TLV_DONT_CHECK && val <= warning_min)
		return TLV_OUTSIDE_WARNING_LIMIT

	return TLV_NO_DANGER

/datum/tlv/no_checks
	hazard_min = TLV_DONT_CHECK
	warning_min = TLV_DONT_CHECK
	warning_max = TLV_DONT_CHECK
	hazard_max = TLV_DONT_CHECK

/datum/tlv/dangerous
	hazard_min = TLV_DONT_CHECK
	warning_min = TLV_DONT_CHECK
	warning_max = 0.2
	hazard_max = 0.5

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
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 0.33
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 90, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/danger_level = 0
	var/mode = AALARM_MODE_SCRUBBING

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = AIRALARM_BUILD_COMPLETE // 2 = complete, 1 = no wires,  0 = circuit gone

	var/frequency = FREQ_ATMOS_CONTROL
	var/alarm_frequency = FREQ_ATMOS_ALARMS
	var/datum/radio_frequency/radio_connection
	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/static/list/atmos_connections = list(COMSIG_TURF_EXPOSE = .proc/check_air_dangerlevel)

	var/list/TLV = list( // Breathable air.
		"pressure" = new/datum/tlv(HAZARD_LOW_PRESSURE, WARNING_LOW_PRESSURE, WARNING_HIGH_PRESSURE, HAZARD_HIGH_PRESSURE), // kPa. Values are hazard_min, warning_min, warning_max, hazard_max
		"temperature" = new/datum/tlv(BODYTEMP_COLD_WARNING_1, BODYTEMP_COLD_WARNING_1+10, BODYTEMP_HEAT_WARNING_1-27, BODYTEMP_HEAT_WARNING_1),
		/datum/gas/oxygen = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen = new/datum/tlv(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide = new/datum/tlv(-1, -1, 5, 10),
		/datum/gas/miasma = new/datum/tlv/(-1, -1, 15, 30),
		/datum/gas/plasma = new/datum/tlv/dangerous,
		/datum/gas/nitrous_oxide = new/datum/tlv/dangerous,
		/datum/gas/bz = new/datum/tlv/dangerous,
		/datum/gas/hypernoblium = new/datum/tlv(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor = new/datum/tlv/dangerous,
		/datum/gas/tritium = new/datum/tlv/dangerous,
		/datum/gas/nitrium = new/datum/tlv/dangerous,
		/datum/gas/pluoxium = new/datum/tlv(-1, -1, 1000, 1000), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
		/datum/gas/freon = new/datum/tlv/dangerous,
		/datum/gas/hydrogen = new/datum/tlv/dangerous,
		/datum/gas/healium = new/datum/tlv/dangerous,
		/datum/gas/proto_nitrate = new/datum/tlv/dangerous,
		/datum/gas/zauker = new/datum/tlv/dangerous,
		/datum/gas/helium = new/datum/tlv/dangerous,
		/datum/gas/antinoblium = new/datum/tlv/dangerous,
		/datum/gas/halon = new/datum/tlv/dangerous
	)

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	wires = new /datum/wires/airalarm(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = AIRALARM_BUILD_NO_CIRCUIT
		panel_open = TRUE

	if(name == initial(name))
		name = "[get_area_name(src)] Air Alarm"

	alarm_manager = new(src)
	update_appearance()

	set_frequency(frequency)
	AddElement(/datum/element/connect_loc, atmos_connections)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/air_alarm,
	))

/obj/machinery/airalarm/Destroy()
	SSradio.remove_object(src, frequency)
	QDEL_NULL(wires)
	QDEL_NULL(alarm_manager)
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

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = (obj_flags & EMAGGED ? 1 : 0),
		"danger_level" = danger_level,
	)

	var/area/A = get_area(src)
	data["atmos_alarm"] = !!A.active_alarms[ALARM_ATMOS]
	data["fire_alarm"] = A.fire

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/datum/tlv/cur_tlv

	data["environment_data"] = list()
	var/pressure = environment.return_pressure()
	cur_tlv = TLV["pressure"]
	data["environment_data"] += list(list(
							"name" = "Pressure",
							"value" = pressure,
							"unit" = "kPa",
							"danger_level" = cur_tlv.get_danger_level(pressure)
	))
	var/temperature = environment.temperature
	cur_tlv = TLV["temperature"]
	data["environment_data"] += list(list(
							"name" = "Temperature",
							"value" = temperature,
							"unit" = "K ([round(temperature - T0C, 0.1)]C)",
							"danger_level" = cur_tlv.get_danger_level(temperature)
	))
	var/total_moles = environment.total_moles()
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume
	for(var/gas_id in environment.gases)
		if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
			continue
		cur_tlv = TLV[gas_id]
		data["environment_data"] += list(list(
								"name" = environment.gases[gas_id][GAS_META][META_GAS_NAME],
								"value" = environment.gases[gas_id][MOLES] / total_moles * 100,
								"unit" = "%",
								"danger_level" = cur_tlv.get_danger_level(environment.gases[gas_id][MOLES] * partial_pressure)
		))

	if(!locked || user.has_unlimited_silicon_privilege)
		data["vents"] = list()
		for(var/id_tag in A.air_vent_info)
			var/long_name = GLOB.air_vent_names[id_tag]
			var/list/info = A.air_vent_info[id_tag]
			if(!info || info["frequency"] != frequency)
				continue
			data["vents"] += list(list(
					"id_tag" = id_tag,
					"long_name" = sanitize(long_name),
					"power" = info["power"],
					"checks" = info["checks"],
					"excheck" = info["checks"]&1,
					"incheck" = info["checks"]&2,
					"direction" = info["direction"],
					"external" = info["external"],
					"internal" = info["internal"],
					"extdefault"= (info["external"] == ONE_ATMOSPHERE),
					"intdefault"= (info["internal"] == 0)
				))
		data["scrubbers"] = list()
		for(var/id_tag in A.air_scrub_info)
			var/long_name = GLOB.air_scrub_names[id_tag]
			var/list/info = A.air_scrub_info[id_tag]
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
		data["modes"] = list()
		data["modes"] += list(list("name" = "Filtering - Scrubs out contaminants", "mode" = AALARM_MODE_SCRUBBING, "selected" = mode == AALARM_MODE_SCRUBBING, "danger" = 0))
		data["modes"] += list(list("name" = "Contaminated - Scrubs out ALL contaminants quickly","mode" = AALARM_MODE_CONTAMINATED, "selected" = mode == AALARM_MODE_CONTAMINATED, "danger" = 0))
		data["modes"] += list(list("name" = "Draught - Siphons out air while replacing", "mode" = AALARM_MODE_VENTING, "selected" = mode == AALARM_MODE_VENTING, "danger" = 0))
		data["modes"] += list(list("name" = "Refill - Triple vent output", "mode" = AALARM_MODE_REFILL, "selected" = mode == AALARM_MODE_REFILL, "danger" = 1))
		data["modes"] += list(list("name" = "Cycle - Siphons air before replacing", "mode" = AALARM_MODE_REPLACEMENT, "selected" = mode == AALARM_MODE_REPLACEMENT, "danger" = 1))
		data["modes"] += list(list("name" = "Siphon - Siphons air out of the room", "mode" = AALARM_MODE_SIPHON, "selected" = mode == AALARM_MODE_SIPHON, "danger" = 1))
		data["modes"] += list(list("name" = "Panic Siphon - Siphons air out of the room quickly","mode" = AALARM_MODE_PANIC, "selected" = mode == AALARM_MODE_PANIC, "danger" = 1))
		data["modes"] += list(list("name" = "Off - Shuts off vents and scrubbers", "mode" = AALARM_MODE_OFF, "selected" = mode == AALARM_MODE_OFF, "danger" = 0))
		if(obj_flags & EMAGGED)
			data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents", "mode" = AALARM_MODE_FLOOD, "selected" = mode == AALARM_MODE_FLOOD, "danger" = 1))

		var/datum/tlv/selected
		var/list/thresholds = list()

		selected = TLV["pressure"]
		thresholds += list(list("name" = "Pressure", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "hazard_min", "selected" = selected.hazard_min))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "warning_min", "selected" = selected.warning_min))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "warning_max", "selected" = selected.warning_max))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "hazard_max", "selected" = selected.hazard_max))

		selected = TLV["temperature"]
		thresholds += list(list("name" = "Temperature", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "hazard_min", "selected" = selected.hazard_min))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "warning_min", "selected" = selected.warning_min))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "warning_max", "selected" = selected.warning_max))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "hazard_max", "selected" = selected.hazard_max))

		for(var/gas_id in GLOB.meta_gas_info)
			if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
				continue
			selected = TLV[gas_id]
			thresholds += list(list("name" = GLOB.meta_gas_info[gas_id][META_GAS_NAME], "settings" = list()))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "hazard_min", "selected" = selected.hazard_min))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "warning_min", "selected" = selected.warning_min))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "warning_max", "selected" = selected.warning_max))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "hazard_max", "selected" = selected.hazard_max))

		data["thresholds"] = thresholds
	return data

/obj/machinery/airalarm/ui_act(action, params)
	. = ..()

	if(. || buildstage != AIRALARM_BUILD_COMPLETE)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return
	var/device_id = params["id_tag"]
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				. = TRUE
		if("power", "toggle_filter", "widenet", "scrubbing", "direction")
			send_signal(device_id, list("[action]" = params["val"]), usr)
			. = TRUE
		if("excheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^1), usr)
			. = TRUE
		if("incheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^2), usr)
			. = TRUE
		if("set_external_pressure", "set_internal_pressure")
			var/target = params["value"]
			if(!isnull(target))
				send_signal(device_id, list("[action]" = target), usr)
				. = TRUE
		if("reset_external_pressure")
			send_signal(device_id, list("reset_external_pressure"), usr)
			. = TRUE
		if("reset_internal_pressure")
			send_signal(device_id, list("reset_internal_pressure"), usr)
			. = TRUE
		if("threshold")
			var/env = params["env"]
			if(text2path(env))
				env = text2path(env)

			var/name = params["var"]
			var/datum/tlv/tlv = TLV[env]
			if(isnull(tlv))
				return
			var/value = input("New [name] for [env]:", name, tlv.vars[name]) as num|null
			if(!isnull(value) && !..())
				if(value < 0)
					tlv.vars[name] = -1
				else
					tlv.vars[name] = round(value, 0.01)
				investigate_log(" treshold value for [env]:[name] was set to [value] by [key_name(usr)]",INVESTIGATE_ATMOS)
				var/turf/our_turf = get_turf(src)
				var/datum/gas_mixture/environment = our_turf.return_air()
				check_air_dangerlevel(our_turf, environment, environment.temperature)
				. = TRUE
		if("mode")
			mode = text2num(params["mode"])
			investigate_log("was turned to [get_mode_name(mode)] mode by [key_name(usr)]",INVESTIGATE_ATMOS)
			apply_mode(usr)
			. = TRUE
		if("alarm")
			if(alarm_manager.send_alarm(ALARM_ATMOS))
				post_alert(2)
			. = TRUE
		if("reset")
			if(alarm_manager.clear_alarm(ALARM_ATMOS))
				post_alert(0)
			. = TRUE
	update_appearance()


/obj/machinery/airalarm/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_appearance()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE


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
	var/area/A = get_area(src)
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = 1,
					"widenet" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_CONTAMINATED)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(
						/datum/gas/carbon_dioxide,
						/datum/gas/miasma,
						/datum/gas/plasma,
						/datum/gas/water_vapor,
						/datum/gas/hypernoblium,
						/datum/gas/nitrous_oxide,
						/datum/gas/nitrium,
						/datum/gas/tritium,
						/datum/gas/bz,
						/datum/gas/pluoxium,
						/datum/gas/freon,
						/datum/gas/hydrogen,
						/datum/gas/healium,
						/datum/gas/proto_nitrate,
						/datum/gas/zauker,
						/datum/gas/helium,
						/datum/gas/antinoblium,
						/datum/gas/halon,
					),
					"scrubbing" = 1,
					"widenet" = 1
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_VENTING)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				), signal_source)
		if(AALARM_MODE_REFILL)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = 1,
					"widenet" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE * 3
				), signal_source)
		if(AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 1,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_SIPHON)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)

		if(AALARM_MODE_OFF)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_FLOOD)
			for(var/device_id in A.air_scrub_info)
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in A.air_vent_info)
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
	. += emissive_appearance(icon, state, alpha = src.alpha)

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
	var/list/cached_tlv = TLV

	var/list/env_gases = environment.gases
	var/partial_pressure = R_IDEAL_GAS_EQUATION * exposed_temperature / environment.volume

	current_tlv = cached_tlv["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = current_tlv.get_danger_level(environment_pressure)

	current_tlv = cached_tlv["temperature"]
	var/temperature_dangerlevel = current_tlv.get_danger_level(exposed_temperature)

	var/gas_dangerlevel = 0
	for(var/gas_id in env_gases)
		if(!(gas_id in cached_tlv)) // We're not interested in this gas, it seems.
			continue
		current_tlv = cached_tlv[gas_id]
		gas_dangerlevel = max(gas_dangerlevel, current_tlv.get_danger_level(env_gases[gas_id][MOLES] * partial_pressure))

	environment.garbage_collect()

	var/old_danger_level = danger_level
	danger_level = max(pressure_dangerlevel, temperature_dangerlevel, gas_dangerlevel)

	if(old_danger_level != danger_level)
		INVOKE_ASYNC(src, .proc/apply_danger_level)
	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		INVOKE_ASYNC(src, .proc/apply_mode, src)


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

/obj/machinery/airalarm/proc/apply_danger_level()
	var/area/A = get_area(src)

	var/new_area_danger_level = 0
	for(var/obj/machinery/airalarm/AA in A)
		if (!(AA.machine_stat & (NOPOWER|BROKEN)) && !AA.shorted)
			new_area_danger_level = clamp(max(new_area_danger_level, AA.danger_level), 0, 1)

	var/did_anything_happen
	if(new_area_danger_level)
		did_anything_happen = alarm_manager.send_alarm(ALARM_ATMOS)
	else
		did_anything_happen = alarm_manager.clear_alarm(ALARM_ATMOS)
	if(did_anything_happen) //if something actually changed
		post_alert(new_area_danger_level)

	update_appearance()

/obj/machinery/airalarm/crowbar_act(mob/living/user, obj/item/tool)
	if(buildstage != AIRALARM_BUILD_NO_WIRES)
		return
	user.visible_message(span_notice("[user.name] removes the electronics from [name]."), \
						span_notice("You start prying out the circuit..."))
	tool.play_tool_sound(src)
	if (tool.use_tool(src, user, 20))
		if (buildstage == AIRALARM_BUILD_NO_WIRES)
			to_chat(user, span_notice("You remove the air alarm electronics."))
			new /obj/item/electronics/airalarm(drop_location())
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			buildstage = AIRALARM_BUILD_NO_CIRCUIT
			update_appearance()
	return TRUE

/obj/machinery/airalarm/screwdriver_act(mob/living/user, obj/item/tool)
	if(buildstage != AIRALARM_BUILD_COMPLETE)
		return
	tool.play_tool_sound(src)
	panel_open = !panel_open
	to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
	update_appearance()
	return TRUE

/obj/machinery/airalarm/wirecutter_act(mob/living/user, obj/item/tool)
	if(!(buildstage == AIRALARM_BUILD_COMPLETE && panel_open && wires.is_all_cut()))
		return
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You cut the final wires."))
	var/obj/item/stack/cable_coil/cables = new(drop_location(), 5)
	user.put_in_hands(cables)
	buildstage = AIRALARM_BUILD_NO_WIRES
	update_appearance()
	return TRUE

/obj/machinery/airalarm/wrench_act(mob/living/user, obj/item/tool)
	if(buildstage != AIRALARM_BUILD_NO_CIRCUIT)
		return
	to_chat(user, span_notice("You detach \the [src] from the wall."))
	tool.play_tool_sound(src)
	var/obj/item/wallframe/airalarm/alarm_frame = new(drop_location())
	user.put_in_hands(alarm_frame)
	qdel(src)
	return TRUE

/obj/machinery/airalarm/attackby(obj/item/W, mob/user, params)
	update_last_used(user)
	switch(buildstage)
		if(AIRALARM_BUILD_COMPLETE)
			if(W.GetID())// trying to unlock the interface with an ID card
				togglelock(user)
				return
			else if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
		if(AIRALARM_BUILD_NO_WIRES)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					to_chat(user, span_warning("You need five lengths of cable to wire the air alarm!"))
					return
				user.visible_message(span_notice("[user.name] wires the air alarm."), \
									span_notice("You start wiring the air alarm..."))
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == AIRALARM_BUILD_NO_WIRES)
						cable.use(5)
						to_chat(user, span_notice("You wire the air alarm."))
						wires.repair()
						aidisabled = 0
						locked = FALSE
						mode = 1
						shorted = 0
						post_alert(0)
						buildstage = AIRALARM_BUILD_COMPLETE
						update_appearance()
				return
		if(AIRALARM_BUILD_NO_CIRCUIT)
			if(istype(W, /obj/item/electronics/airalarm))
				if(user.temporarilyRemoveItemFromInventory(W))
					to_chat(user, span_notice("You insert the circuit."))
					buildstage = AIRALARM_BUILD_NO_WIRES
					update_appearance()
					qdel(W)
				return

			if(istype(W, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = W
				if(!P.adapt_circuit(user, 25))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt an air alarm circuit and slot it into the assembly."))
				buildstage = AIRALARM_BUILD_NO_WIRES
				update_appearance()
				return

	return ..()

/obj/machinery/airalarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == AIRALARM_BUILD_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/machinery/airalarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt an air alarm circuit and slot it into the assembly."))
			buildstage = AIRALARM_BUILD_NO_WIRES
			update_appearance()
			return TRUE
	return FALSE

/obj/machinery/airalarm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/airalarm/proc/togglelock(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("It does nothing!"))
	else
		if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the air alarm interface."))
			updateUsrDialog()
		else
			to_chat(user, span_danger("Access denied."))
	return

/obj/machinery/airalarm/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	visible_message(span_warning("Sparks fly out of [src]!"), span_notice("You emag [src], disabling its safeties."))
	playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/airalarm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		var/obj/item/I = new /obj/item/electronics/airalarm(loc)
		if(!disassembled)
			I.take_damage(I.max_integrity * 0.5, sound_effect=FALSE)
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/airalarm/server // No checks here.
	TLV = list(
		"pressure" = new/datum/tlv/no_checks,
		"temperature" = new/datum/tlv/no_checks,
		/datum/gas/oxygen = new/datum/tlv/no_checks,
		/datum/gas/nitrogen = new/datum/tlv/no_checks,
		/datum/gas/carbon_dioxide = new/datum/tlv/no_checks,
		/datum/gas/miasma = new/datum/tlv/no_checks,
		/datum/gas/plasma = new/datum/tlv/no_checks,
		/datum/gas/nitrous_oxide = new/datum/tlv/no_checks,
		/datum/gas/bz = new/datum/tlv/no_checks,
		/datum/gas/hypernoblium = new/datum/tlv/no_checks,
		/datum/gas/water_vapor = new/datum/tlv/no_checks,
		/datum/gas/tritium = new/datum/tlv/no_checks,
		/datum/gas/nitrium = new/datum/tlv/no_checks,
		/datum/gas/pluoxium = new/datum/tlv/no_checks,
		/datum/gas/freon = new/datum/tlv/no_checks,
		/datum/gas/hydrogen = new/datum/tlv/no_checks,
		/datum/gas/healium = new/datum/tlv/dangerous,
		/datum/gas/proto_nitrate = new/datum/tlv/dangerous,
		/datum/gas/zauker = new/datum/tlv/dangerous,
		/datum/gas/helium = new/datum/tlv/dangerous,
		/datum/gas/antinoblium = new/datum/tlv/dangerous,
		/datum/gas/halon = new/datum/tlv/dangerous,
	)

/obj/machinery/airalarm/kitchen_cold_room // Kitchen cold rooms start off at -14°C or 259.15K.
	TLV = list(
		"pressure" = new/datum/tlv(ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE *  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2), // kPa
		"temperature" = new/datum/tlv(COLD_ROOM_TEMP-40, COLD_ROOM_TEMP-20, COLD_ROOM_TEMP+20, COLD_ROOM_TEMP+40),
		/datum/gas/oxygen = new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen = new/datum/tlv(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide = new/datum/tlv(-1, -1, 5, 10),
		/datum/gas/miasma = new/datum/tlv/(-1, -1, 2, 5),
		/datum/gas/plasma = new/datum/tlv/dangerous,
		/datum/gas/nitrous_oxide = new/datum/tlv/dangerous,
		/datum/gas/bz = new/datum/tlv/dangerous,
		/datum/gas/hypernoblium = new/datum/tlv(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor = new/datum/tlv/dangerous,
		/datum/gas/tritium = new/datum/tlv/dangerous,
		/datum/gas/nitrium = new/datum/tlv/dangerous,
		/datum/gas/pluoxium = new/datum/tlv(-1, -1, 1000, 1000), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
		/datum/gas/freon = new/datum/tlv/dangerous,
		/datum/gas/hydrogen = new/datum/tlv/dangerous,
		/datum/gas/healium = new/datum/tlv/dangerous,
		/datum/gas/proto_nitrate = new/datum/tlv/dangerous,
		/datum/gas/zauker = new/datum/tlv/dangerous,
		/datum/gas/helium = new/datum/tlv/dangerous,
		/datum/gas/antinoblium = new/datum/tlv/dangerous,
		/datum/gas/halon = new/datum/tlv/dangerous,
	)

/obj/machinery/airalarm/unlocked
	locked = FALSE

/obj/machinery/airalarm/engine
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

/obj/machinery/airalarm/mixingchamber
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ORDNANCE)

/obj/machinery/airalarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

/obj/machinery/airalarm/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/airalarm/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 24)

/obj/item/circuit_component/air_alarm
	display_name = "Air Alarm"
	desc = "Controls levels of gases and their temperature as well as all vents and scrubbers in the room."

	var/datum/port/input/option/air_alarm_options

	var/datum/port/input/min_2
	var/datum/port/input/min_1
	var/datum/port/input/max_1
	var/datum/port/input/max_2

	var/datum/port/input/request_data

	var/datum/port/output/pressure
	var/datum/port/output/temperature
	var/datum/port/output/gas_amount

	var/obj/machinery/airalarm/connected_alarm
	var/list/options_map

/obj/item/circuit_component/air_alarm/populate_ports()
	min_2 = add_input_port("Min 2", PORT_TYPE_NUMBER)
	min_1 = add_input_port("Min 1", PORT_TYPE_NUMBER)
	max_1 = add_input_port("Max 1", PORT_TYPE_NUMBER)
	max_2 = add_input_port("Max 2", PORT_TYPE_NUMBER)
	request_data = add_input_port("Request Atmosphere Data", PORT_TYPE_SIGNAL)

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)
	gas_amount = add_output_port("Chosen Gas Amount", PORT_TYPE_NUMBER)

/obj/item/circuit_component/air_alarm/populate_options()
	var/static/list/component_options

	if(!component_options)
		component_options = list(
			"Pressure" = "pressure",
			"Temperature" = "temperature"
		)

		for(var/gas_id in GLOB.meta_gas_info)
			component_options[GLOB.meta_gas_info[gas_id][META_GAS_NAME]] = gas_id2path(gas_id)

	air_alarm_options = add_option_port("Air Alarm Options", component_options)
	options_map = component_options

/obj/item/circuit_component/air_alarm/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell

/obj/item/circuit_component/air_alarm/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/input_received(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/current_option = air_alarm_options.value

	if(COMPONENT_TRIGGERED_BY(request_data, port))
		var/turf/alarm_turf = get_turf(connected_alarm)
		var/datum/gas_mixture/environment = alarm_turf.return_air()
		pressure.set_output(round(environment.return_pressure()))
		temperature.set_output(round(environment.temperature))
		if(ispath(options_map[current_option]))
			gas_amount.set_output(round(environment.gases[options_map[current_option]][MOLES]))
		return

	var/datum/tlv/settings = connected_alarm.TLV[options_map[current_option]]
	settings.hazard_min = min_2
	settings.warning_min = min_1
	settings.warning_max = max_1
	settings.hazard_max = max_2

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
