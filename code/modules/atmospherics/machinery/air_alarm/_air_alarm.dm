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
#define AALARM_MODE_MAX AALARM_MODE_REFILL
#define NO_BOUND 3

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

	var/mode = AALARM_MODE_SCRUBBING
	///A reference to the area we are in
	var/area/my_area

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = AIRALARM_BUILD_COMPLETE // 2 = complete, 1 = no wires,  0 = circuit gone

	///Represents a signel source of atmos alarms, complains to all the listeners if one of our thresholds is violated
	var/datum/alarm_handler/alarm_manager

	var/static/list/atmos_connections = list(COMSIG_TURF_EXPOSE = PROC_REF(check_air_dangerlevel))

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

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = (obj_flags & EMAGGED ? 1 : 0),
		"danger_level" = danger_level,
	)

	data["atmos_alarm"] = !!my_area.active_alarms[ALARM_ATMOS]
	data["fire_alarm"] = my_area.fire

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
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
			data["vents"] += list(list(
				"ref" = REF(vent),
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
				"ref" = REF(scrubber),
				"long_name" = sanitize(scrubber.name),
				"power" = scrubber.on,
				"scrubbing" = scrubber.scrubbing,
				"widenet" = scrubber.widenet,
				"filter_types" = filter_types,
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
			mode = clamp(round(text2num(params["mode"])), AALARM_MODE_SCRUBBING, AALARM_MODE_MAX)
			investigate_log("was turned to [get_mode_name(mode)] mode by [key_name(user)]", INVESTIGATE_ATMOS)
			apply_mode(user)
		if ("threshold")
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
				investigate_log("threshold value for [env]:[name] was set to [value] by [key_name(usr)]",INVESTIGATE_ATMOS)
				var/turf/our_turf = get_turf(src)
				var/datum/gas_mixture/environment = our_turf.return_air()
				check_air_dangerlevel(our_turf, environment, environment.temperature)
		if ("mode")
			if (alarm_manager.send_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_SEVERE
		if ("reset")
			if (alarm_manager.clear_alarm(ALARM_ATMOS))
				danger_level = AIR_ALARM_ALERT_NONE

	update_appearance()

	return TRUE

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

/obj/machinery/airalarm/proc/apply_mode(atom/source)
	switch (mode)
		if (AALARM_MODE_SCRUBBING)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.filter_types = list(/datum/gas/carbon_dioxide)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
				scrubber.set_widenet(FALSE)
		if (AALARM_MODE_CONTAMINATED)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.filter_types = list(
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
				)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
				scrubber.set_widenet(TRUE)
		if (AALARM_MODE_VENTING)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE * 2
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_REFILL)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE * 3
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE

				scrubber.filter_types = list(/datum/gas/carbon_dioxide)
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
		if (AALARM_MODE_PANIC, AALARM_MODE_REPLACEMENT)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(TRUE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_SIPHON)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_OFF)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = FALSE
				scrubber.update_appearance(UPDATE_ICON)
		if (AALARM_MODE_FLOOD)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_INTERNAL_BOUND
				vent.internal_pressure_bound = 0
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = FALSE
				scrubber.update_appearance(UPDATE_ICON)

	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, source)

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
		INVOKE_ASYNC(src, PROC_REF(apply_danger_level))
	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		INVOKE_ASYNC(src, PROC_REF(apply_mode), src)

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

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/airalarm, 24)

/datum/armor/machinery_airalarm
	energy = 100
	fire = 90
	acid = 30

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
