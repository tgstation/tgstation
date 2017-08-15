/datum/tlv
	var/min2
	var/min1
	var/max1
	var/max2

/datum/tlv/New(min2 as num, min1 as num, max1 as num, max2 as num)
	src.min2 = min2
	src.min1 = min1
	src.max1 = max1
	src.max2 = max2

/datum/tlv/proc/get_danger_level(val as num)
	if(max2 != -1 && val >= max2)
		return 2
	if(min2 != -1 && val <= min2)
		return 2
	if(max1 != -1 && val >= max1)
		return 1
	if(min1 != -1 && val <= min1)
		return 1
	return 0

/obj/item/weapon/electronics/airalarm
	name = "air alarm electronics"
	icon_state = "airalarm_electronics"

/obj/item/wallframe/airalarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/machinery/airalarm

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
	icon_state = "alarm0"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 80
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	resistance_flags = FIRE_PROOF

	var/danger_level = 0
	var/mode = AALARM_MODE_SCRUBBING

	var/locked = TRUE
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

	var/frequency = 1439
	var/alarm_frequency = 1437
	var/datum/radio_frequency/radio_connection

	var/list/TLV = list( // Breathable air.
		"pressure"		= new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE*  0.90, ONE_ATMOSPHERE * 1.10, ONE_ATMOSPHERE * 1.20), // kPa
		"temperature"	= new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66), // K
		"o2"			= new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		"n2"			= new/datum/tlv(-1, -1, 1000, 1000), // Partial pressure, kpa
		"co2" 			= new/datum/tlv(-1, -1, 5, 10), // Partial pressure, kpa
		"plasma"		= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"n2o"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"bz"			= new/datum/tlv(-1, -1, 0.2, 0.5),
		"freon"			= new/datum/tlv(-1, -1, 0.2, 0.5),
		"water_vapor"	= new/datum/tlv(-1, -1, 0.2, 0.5)
	)

/obj/machinery/airalarm/server // No checks here.
	TLV = list(
		"pressure"		= new/datum/tlv(-1, -1, -1, -1),
		"temperature"	= new/datum/tlv(-1, -1, -1, -1),
		"o2"			= new/datum/tlv(-1, -1, -1, -1),
		"n2"			= new/datum/tlv(-1, -1, -1, -1),
		"co2"			= new/datum/tlv(-1, -1, -1, -1),
		"plasma"		= new/datum/tlv(-1, -1, -1, -1),
		"n2o"			= new/datum/tlv(-1, -1, -1, -1),
		"bz"			= new/datum/tlv(-1, -1, -1, -1),
		"freon"			= new/datum/tlv(-1, -1, -1, -1),
		"water_vapor"	= new/datum/tlv(-1, -1, -1, -1)
	)

/obj/machinery/airalarm/kitchen_cold_room // Copypasta: to check temperatures.
	TLV = list(
		"pressure"		= new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE*  0.90, ONE_ATMOSPHERE * 1.10, ONE_ATMOSPHERE * 1.20), // kPa
		"temperature"	= new/datum/tlv(200,210,273.15,283.15), // K
		"o2"			= new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		"n2"			= new/datum/tlv(-1, -1, 1000, 1000), // Partial pressure, kpa
		"co2" 			= new/datum/tlv(-1, -1, 5, 10), // Partial pressure, kpa
		"plasma"		= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"n2o"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"bz"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"freon"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"water_vapor"	= new/datum/tlv(-1, -1, 0.2, 0.5)
	)

/obj/machinery/airalarm/engine
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

/obj/machinery/airalarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

//all air alarms in area are connected via magic
/area
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/airalarm/New(loc, ndir, nbuild)
	..()
	wires = new /datum/wires/airalarm(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = 0
		panel_open = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir == 1 ? -24 : 24) : 0

	var/area/A = get_area(src)
	if(name == initial(name))
		name = "[A.name] Air Alarm"

	update_icon()

/obj/machinery/airalarm/Destroy()
	SSradio.remove_object(src, frequency)
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/airalarm/Initialize(mapload)
	..()
	set_frequency(frequency)

/obj/machinery/airalarm/ui_status(mob/user)
	if(user.has_unlimited_silicon_privilege && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE

/obj/machinery/airalarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airalarm", name, 440, 650, master_ui, state)
		ui.open()

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = emagged,
		"danger_level" = danger_level,
	)

	var/area/A = get_area(src)
	data["atmos_alarm"] = A.atmosalm
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
		for(var/id_tag in A.air_vent_names)
			var/long_name = A.air_vent_names[id_tag]
			var/list/info = A.air_vent_info[id_tag]
			if(!info || info["frequency"] != frequency)
				continue
			data["vents"] += list(list(
					"id_tag"	= id_tag,
					"long_name" = sanitize(long_name),
					"power"		= info["power"],
					"checks"	= info["checks"],
					"excheck"	= info["checks"]&1,
					"incheck"	= info["checks"]&2,
					"direction"	= info["direction"],
					"external"	= info["external"],
					"extdefault"= (info["external"] == ONE_ATMOSPHERE)
				))
		data["scrubbers"] = list()
		for(var/id_tag in A.air_scrub_names)
			var/long_name = A.air_scrub_names[id_tag]
			var/list/info = A.air_scrub_info[id_tag]
			if(!info || info["frequency"] != frequency)
				continue
			data["scrubbers"] += list(list(
					"id_tag"				= id_tag,
					"long_name" 			= sanitize(long_name),
					"power"					= info["power"],
					"scrubbing"				= info["scrubbing"],
					"widenet"				= info["widenet"],
					"filter_co2"			= info["filter_co2"],
					"filter_toxins"			= info["filter_toxins"],
					"filter_n2o"			= info["filter_n2o"],
					"filter_bz"				= info["filter_bz"],
					"filter_freon"			= info["filter_freon"],
					"filter_water_vapor"	= info["filter_water_vapor"]
				))
		data["mode"] = mode
		data["modes"] = list()
		data["modes"] += list(list("name" = "Filtering - Scrubs out contaminants", 				"mode" = AALARM_MODE_SCRUBBING,		"selected" = mode == AALARM_MODE_SCRUBBING, 	"danger" = 0))
		data["modes"] += list(list("name" = "Contaminated - Scrubs out ALL contaminants quickly","mode" = AALARM_MODE_CONTAMINATED,	"selected" = mode == AALARM_MODE_CONTAMINATED,	"danger" = 0))
		data["modes"] += list(list("name" = "Draught - Siphons out air while replacing",		"mode" = AALARM_MODE_VENTING,		"selected" = mode == AALARM_MODE_VENTING,		"danger" = 0))
		data["modes"] += list(list("name" = "Refill - Triple vent output",						"mode" = AALARM_MODE_REFILL,		"selected" = mode == AALARM_MODE_REFILL,		"danger" = 1))
		data["modes"] += list(list("name" = "Cycle - Siphons air before replacing", 			"mode" = AALARM_MODE_REPLACEMENT,	"selected" = mode == AALARM_MODE_REPLACEMENT, 	"danger" = 1))
		data["modes"] += list(list("name" = "Siphon - Siphons air out of the room", 			"mode" = AALARM_MODE_SIPHON,		"selected" = mode == AALARM_MODE_SIPHON, 		"danger" = 1))
		data["modes"] += list(list("name" = "Panic Siphon - Siphons air out of the room quickly","mode" = AALARM_MODE_PANIC,		"selected" = mode == AALARM_MODE_PANIC, 		"danger" = 1))
		data["modes"] += list(list("name" = "Off - Shuts off vents and scrubbers", 				"mode" = AALARM_MODE_OFF,			"selected" = mode == AALARM_MODE_OFF, 			"danger" = 0))
		if(emagged)
			data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents",	"mode" = AALARM_MODE_FLOOD,			"selected" = mode == AALARM_MODE_FLOOD, 		"danger" = 1))

		var/datum/tlv/selected
		var/list/thresholds = list()

		selected = TLV["pressure"]
		thresholds += list(list("name" = "Pressure", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min2", "selected" = selected.min2))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min1", "selected" = selected.min1))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max1", "selected" = selected.max1))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max2", "selected" = selected.max2))

		selected = TLV["temperature"]
		thresholds += list(list("name" = "Temperature", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min2", "selected" = selected.min2))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min1", "selected" = selected.min1))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max1", "selected" = selected.max1))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max2", "selected" = selected.max2))

		for(var/gas_id in GLOB.meta_gas_info)
			if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
				continue
			selected = TLV[gas_id]
			thresholds += list(list("name" = GLOB.meta_gas_info[gas_id][META_GAS_NAME], "settings" = list()))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min2", "selected" = selected.min2))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min1", "selected" = selected.min1))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max1", "selected" = selected.max1))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max2", "selected" = selected.max2))

		data["thresholds"] = thresholds
	return data

/obj/machinery/airalarm/ui_act(action, params)
	if(..() || buildstage != 2)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return
	var/device_id = params["id_tag"]
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				. = TRUE
		if("power", "co2_scrub", "tox_scrub", "n2o_scrub", "bz_scrub", "freon_scrub","water_vapor_scrub", "widenet", "scrubbing")
			send_signal(device_id, list("[action]" = text2num(params["val"])))
			. = TRUE
		if("excheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^1))
			. = TRUE
		if("incheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^2))
			. = TRUE
		if("set_external_pressure")
			var/area/A = get_area(src)
			var/target = input("New target pressure:", name, A.air_vent_info[device_id]["external"]) as num|null
			if(!isnull(target) && !..())
				send_signal(device_id, list("set_external_pressure" = target))
				. = TRUE
		if("reset_external_pressure")
			send_signal(device_id, list("reset_external_pressure"))
			. = TRUE
		if("threshold")
			var/env = params["env"]
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
				. = TRUE
		if("mode")
			mode = text2num(params["mode"])
			apply_mode()
			. = TRUE
		if("alarm")
			var/area/A = get_area(src)
			if(A.atmosalert(2, src))
				post_alert(2)
			. = TRUE
		if("reset")
			var/area/A = get_area(src)
			if(A.atmosalert(0, src))
				post_alert(0)
			. = TRUE
	update_icon()


/obj/machinery/airalarm/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_icon()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE


/obj/machinery/airalarm/proc/shock(mob/user, prb)
	if((stat & (NOPOWER)))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src, 1, TRUE))
		return 1
	else
		return 0

/obj/machinery/airalarm/proc/refresh_all()
	var/area/A = get_area(src)
	for(var/id_tag in A.air_vent_names)
		var/list/I = A.air_vent_info[id_tag]
		if(I && I["timestamp"] + AALARM_REPORT_TIMEOUT / 2 > world.time)
			continue
		send_signal(id_tag, list("status"))
	for(var/id_tag in A.air_scrub_names)
		var/list/I = A.air_scrub_info[id_tag]
		if(I && I["timestamp"] + AALARM_REPORT_TIMEOUT / 2 > world.time)
			continue
		send_signal(id_tag, list("status"))

/obj/machinery/airalarm/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, GLOB.RADIO_TO_AIRALARM)

/obj/machinery/airalarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, GLOB.RADIO_FROM_AIRALARM)
//			to_chat(world, text("Signal [] Broadcasted to []", command, target))

	return 1

/obj/machinery/airalarm/proc/apply_mode()
	var/area/A = get_area(src)
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"co2_scrub" = 1,
					"tox_scrub" = 0,
					"n2o_scrub" = 0,
					"bz_scrub"	= 0,
					"freon_scrub"= 0,
					"water_vapor_scrub"= 0,
					"scrubbing" = 1,
					"widenet" = 0,
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				))
		if(AALARM_MODE_CONTAMINATED)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"co2_scrub" = 1,
					"tox_scrub" = 1,
					"n2o_scrub" = 1,
					"bz_scrub"	= 1,
					"freon_scrub"= 1,
					"water_vapor_scrub"= 1,
					"scrubbing" = 1,
					"widenet" = 1,
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				))
		if(AALARM_MODE_VENTING)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				))
		if(AALARM_MODE_REFILL)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"co2_scrub" = 1,
					"tox_scrub" = 0,
					"n2o_scrub" = 0,
					"bz_scrub"	= 0,
					"freon_scrub"= 0,
					"water_vapor_scrub"= 0,
					"scrubbing" = 1,
					"widenet" = 0,
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE * 3
				))
		if(AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 1,
					"scrubbing" = 0
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 0
				))
		if(AALARM_MODE_SIPHON)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 0
				))

		if(AALARM_MODE_OFF)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 0
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 0
				))
		if(AALARM_MODE_FLOOD)
			for(var/device_id in A.air_scrub_names)
				send_signal(device_id, list(
					"power" = 0
				))
			for(var/device_id in A.air_vent_names)
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 2,
					"set_internal_pressure" = 0
				))

/obj/machinery/airalarm/update_icon()
	if(panel_open)
		switch(buildstage)
			if(2)
				icon_state = "alarmx"
			if(1)
				icon_state = "alarm_b2"
			if(0)
				icon_state = "alarm_b1"
		return

	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	var/area/A = get_area(src)
	switch(max(danger_level, A.atmosalm))
		if(0)
			icon_state = "alarm0"
		if(1)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if(2)
			icon_state = "alarm1"

/obj/machinery/airalarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/turf/location = get_turf(src)
	if(!location)
		return

	var/datum/tlv/cur_tlv

	var/datum/gas_mixture/environment = location.return_air()
	var/list/env_gases = environment.gases
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/gas_dangerlevel = 0
	for(var/gas_id in env_gases)
		if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
			continue
		cur_tlv = TLV[gas_id]
		gas_dangerlevel = max(gas_dangerlevel, cur_tlv.get_danger_level(env_gases[gas_id][MOLES] * partial_pressure))

	environment.garbage_collect()

	var/old_danger_level = danger_level
	danger_level = max(pressure_dangerlevel, temperature_dangerlevel, gas_dangerlevel)

	if(old_danger_level != danger_level)
		apply_danger_level()
	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		apply_mode()


/obj/machinery/airalarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency)
		return

	var/area/A = get_area(src)

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = A.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal,null,-1)

/obj/machinery/airalarm/proc/apply_danger_level()
	var/area/A = get_area(src)

	var/new_area_danger_level = 0
	for(var/area/R in A.related)
		for(var/obj/machinery/airalarm/AA in R)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				new_area_danger_level = max(new_area_danger_level,AA.danger_level)
	if(A.atmosalert(new_area_danger_level,src)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)

	update_icon()

/obj/machinery/airalarm/attackby(obj/item/W, mob/user, params)
	switch(buildstage)
		if(2)
			if(istype(W, /obj/item/weapon/wirecutters) && panel_open && wires.is_all_cut())
				playsound(src.loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You cut the final wires.</span>")
				new /obj/item/stack/cable_coil(loc, 5)
				buildstage = 1
				update_icon()
				return
			else if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
				playsound(src.loc, W.usesound, 50, 1)
				panel_open = !panel_open
				to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>")
				update_icon()
				return
			else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					to_chat(user, "<span class='warning'>It does nothing!</span>")
				else
					if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the air alarm interface.</span>")
					else
						to_chat(user, "<span class='danger'>Access denied.</span>")
				return
			else if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
		if(1)
			if(istype(W, /obj/item/weapon/crowbar))
				user.visible_message("[user.name] removes the electronics from [src.name].",\
									"<span class='notice'>You start prying out the circuit...</span>")
				playsound(src.loc, W.usesound, 50, 1)
				if (do_after(user, 20*W.toolspeed, target = src))
					if (buildstage == 1)
						to_chat(user, "<span class='notice'>You remove the air alarm electronics.</span>")
						new /obj/item/weapon/electronics/airalarm( src.loc )
						playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
						buildstage = 0
						update_icon()
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the fire alarm!</span>")
					return
				user.visible_message("[user.name] wires the air alarm.", \
									"<span class='notice'>You start wiring the air alarm...</span>")
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						to_chat(user, "<span class='notice'>You wire the air alarm.</span>")
						wires.repair()
						aidisabled = 0
						locked = TRUE
						mode = 1
						shorted = 0
						post_alert(0)
						buildstage = 2
						update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/electronics/airalarm))
				if(user.temporarilyRemoveItemFromInventory(W))
					to_chat(user, "<span class='notice'>You insert the circuit.</span>")
					buildstage = 1
					update_icon()
					qdel(W)
				return

			if(istype(W, /obj/item/weapon/wrench))
				to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
				playsound(src.loc, W.usesound, 50, 1)
				new /obj/item/wallframe/airalarm( user.loc )
				qdel(src)
				return

	return ..()

/obj/machinery/airalarm/power_change()
	..()
	update_icon()

/obj/machinery/airalarm/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	visible_message("<span class='warning'>Sparks fly out of [src]!</span>", "<span class='notice'>You emag [src], disabling its safeties.</span>")
	playsound(src, "sparks", 50, 1)

/obj/machinery/airalarm/obj_break(damage_flag)
	..()
	update_icon()

/obj/machinery/airalarm/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		var/obj/item/I = new /obj/item/weapon/electronics/airalarm(loc)
		if(!disassembled)
			I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

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