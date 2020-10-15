/datum/airalarm_control
	var/area/area

	var/list/breathable_gas_ranges = list( // Breathable air.
		AALARM_PRESSURE = new /datum/gas_range(HAZARD_LOW_PRESSURE, WARNING_LOW_PRESSURE, WARNING_HIGH_PRESSURE, HAZARD_HIGH_PRESSURE), // kPa. Values are min_danger, min_warning, max_warning, max_danger
		AALARM_TEMPERATURE = new /datum/gas_range(T0C, T0C+10, T0C+40, T0C+66),
		/datum/gas/oxygen = new /datum/gas_range(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen = new /datum/gas_range(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide = new /datum/gas_range(-1, -1, 5, 10),
		/datum/gas/miasma = new /datum/gas_range/(-1, -1, 15, 30),
		/datum/gas/plasma = new /datum/gas_range/dangerous,
		/datum/gas/nitrous_oxide = new /datum/gas_range/dangerous,
		/datum/gas/bz = new /datum/gas_range/dangerous,
		/datum/gas/hypernoblium = new /datum/gas_range(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor = new /datum/gas_range/dangerous,
		/datum/gas/tritium = new /datum/gas_range/dangerous,
		/datum/gas/stimulum = new /datum/gas_range/dangerous,
		/datum/gas/nitryl = new /datum/gas_range/dangerous,
		/datum/gas/pluoxium = new /datum/gas_range(-1, -1, 1000, 1000), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
		/datum/gas/freon = new /datum/gas_range/dangerous,
		/datum/gas/hydrogen = new /datum/gas_range/dangerous,
		/datum/gas/healium = new /datum/gas_range/dangerous,
		/datum/gas/proto_nitrate = new /datum/gas_range/dangerous,
		/datum/gas/zauker = new /datum/gas_range/dangerous,
		/datum/gas/halon = new /datum/gas_range/dangerous,
		/datum/gas/hexane = new /datum/gas_range/dangerous,
	)

	var/list/sensors
	var/list/scrubbers
	var/list/vents
	var/list/airalarms

	var/mode = AALARM_MODE_SCRUBBING
	var/danger_level = AALARM_ALERT_CLEAR

/datum/airalarm_control/New(area/A)
	area = A
	sensors = list()
	scrubbers = list()
	vents = list()
	airalarms = list()

/datum/airalarm_control/Destroy(force, ...)
	if(area.air_control == src)
		area.air_control = null
	return ..()

/// Returns the average gas mixture as read from all sensors
/datum/airalarm_control/proc/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/list/all_reads = list()
	var/total_volume = 0
	for(var/I in sensors)
		var/obj/machinery/air_sensor/sensor = I
		var/datum/gas_mixture/read = sensor.last_read
		if(read)
			all_reads += read
			total_volume += read.volume

	if(!all_reads.len)
		// no info
		return null

	var/datum/gas_mixture/average = new(total_volume)
	for(var/I in all_reads)
		average.merge(I)

	return average

/datum/airalarm_control/proc/get_mode_name(mode_value = null)
	if(isnull(mode_value))
		mode_value = mode

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

/datum/airalarm_control/proc/send_signal(target, list/command, atom/source)
	// bluespess radio go!
	var/datum/signal/signal = new(command)
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"
	signal.data["user"] = source
	for(var/I in scrubbers)
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = I
		scrubber.receive_signal(signal)
	for(var/I in vents)
		var/obj/machinery/atmospherics/components/unary/vent_pump/vent = I
		vent.receive_signal(signal)

/datum/airalarm_control/proc/get_scrubber_ids()
	. = list()
	for(var/I in scrubbers)
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = I
		. += scrubber.id_tag

/datum/airalarm_control/proc/get_vent_ids()
	. = list()
	for(var/I in vents)
		var/obj/machinery/atmospherics/components/unary/vent_pump/vent = I
		. += vent.id_tag

/datum/airalarm_control/proc/apply_mode(new_mode, atom/signal_source)
	mode = new_mode
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = TRUE,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = TRUE,
					"widenet" = FALSE
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = TRUE,
					"checks" = TRUE,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_CONTAMINATED)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(
						/datum/gas/carbon_dioxide,
						/datum/gas/miasma,
						/datum/gas/plasma,
						/datum/gas/water_vapor,
						/datum/gas/hypernoblium,
						/datum/gas/nitrous_oxide,
						/datum/gas/nitryl,
						/datum/gas/tritium,
						/datum/gas/bz,
						/datum/gas/stimulum,
						/datum/gas/pluoxium,
						/datum/gas/freon,
						/datum/gas/hydrogen,
						/datum/gas/healium,
						/datum/gas/proto_nitrate,
						/datum/gas/zauker,
						/datum/gas/halon,
						/datum/gas/hexane,
					),
					"scrubbing" = 1,
					"widenet" = 1
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE
				), signal_source)
		if(AALARM_MODE_VENTING)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				), signal_source)
		if(AALARM_MODE_REFILL)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 1,
					"set_filters" = list(/datum/gas/carbon_dioxide),
					"scrubbing" = 1,
					"widenet" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 1,
					"set_external_pressure" = ONE_ATMOSPHERE * 3
				), signal_source)
		if(AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 1,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_SIPHON)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 1,
					"widenet" = 0,
					"scrubbing" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 0
				), signal_source)

		if(AALARM_MODE_OFF)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
		if(AALARM_MODE_FLOOD)
			for(var/device_id in get_scrubber_ids())
				send_signal(device_id, list(
					"power" = 0
				), signal_source)
			for(var/device_id in get_vent_ids())
				send_signal(device_id, list(
					"power" = 1,
					"checks" = 2,
					"set_internal_pressure" = 0
				), signal_source)

/datum/airalarm_control/proc/process_devices(obj/machinery/airalarm/source)
	var/datum/gas_range/cur_tlv

	var/datum/gas_mixture/environment = return_air()
	if(!environment)
		return

	var/list/env_gases = environment.gases
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume

	cur_tlv = breathable_gas_ranges[AALARM_PRESSURE]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = breathable_gas_ranges[AALARM_TEMPERATURE]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/gas_dangerlevel = 0
	for(var/gas_id in env_gases)
		if(!(gas_id in breathable_gas_ranges)) // We're not interested in this gas, it seems.
			continue
		cur_tlv = breathable_gas_ranges[gas_id]
		gas_dangerlevel = max(gas_dangerlevel, cur_tlv.get_danger_level(env_gases[gas_id][MOLES] * partial_pressure))

	environment.garbage_collect()

	var/new_danger_level = max(pressure_dangerlevel, temperature_dangerlevel, gas_dangerlevel)

	if(danger_level != new_danger_level)
		apply_danger_level(new_danger_level)
	if(mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		apply_mode(AALARM_MODE_SCRUBBING, source)

/datum/airalarm_control/proc/apply_danger_level(new_danger_level, obj/source)
	var/operational_alarm = (source in airalarms)
	if(!operational_alarm)
		for(var/I in airalarms)
			var/obj/machinery/airalarm/AA = I
			if (AA.is_operational && !AA.shorted)
				operational_alarm = AA
				break

	atmosalert(new_danger_level, source)

	for(var/I in airalarms)
		var/obj/machinery/airalarm/AA = I
		AA.update_icon()

/**
  * Generate an atmospheric alert for this area. Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  *
  * * isdangerous - If the alert is being turned on or off
  * * source - The source of the alert
  */
/datum/airalarm_control/proc/atmosalert(activate, obj/source)
	if (area.area_flags & NO_ALERTS)
		return

	if(activate == danger_level)
		return FALSE

	danger_level = activate

	/// The alert comes from all working air alarms
	var/alert_name = "Atmosphere"
	for(var/I in airalarms)
		var/obj/machinery/airalarm/AA = I
		AA.update_icon()
		if(!AA.is_operational)
			continue

		if(activate)
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.triggerAlarm(alert_name, area, area.cameras, AA)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.triggerAlarm(alert_name, area, area.cameras, AA)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.triggerAlarm(alert_name, area, area.cameras, AA)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.triggerAlarm(alert_name, area, area.cameras, AA)
		else
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				aiPlayer.cancelAlarm(alert_name, area, AA)
			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				a.cancelAlarm(alert_name, area, AA)
			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				D.cancelAlarm(alert_name, area, AA)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.cancelAlarm(alert_name, area, AA)

	post_alert(danger_level, source)

	return TRUE

/datum/airalarm_control/proc/post_alert(alert_level, obj/source)
	// bluespess radio
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_ATMOS_ALARMS)

	if(!frequency)
		return

	var/datum/signal/alert_signal = new(list(
		"zone" = get_area_name(src, TRUE),
		"type" = "Atmospheric"
	))
	if(alert_level == AALARM_ALERT_SEVERE)
		alert_signal.data["alert"] = "severe"
	else if (alert_level == AALARM_ALERT_MINOR)
		alert_signal.data["alert"] = "minor"
	else if (alert_level == AALARM_ALERT_CLEAR)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(source, alert_signal, range = -1)

/datum/airalarm_control/proc/register_sensor(obj/machinery/air_sensor/sensor)
	sensors |= sensor
	sensor.control = src

/datum/airalarm_control/proc/register_vent(obj/machinery/atmospherics/components/unary/vent_pump/vent)
	vents |= vent
	vent.control = src

/datum/airalarm_control/proc/register_scrubber(obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber)
	scrubbers |= scrubber
	scrubber.control = src

/datum/airalarm_control/proc/register_alarm(obj/machinery/airalarm/alarm)
	airalarms |= alarm
	alarm.control = src

/datum/airalarm_control/proc/garbage_collect()
	if(!sensors.len && !vents.len && !scrubbers.len && !airalarms.len)
		qdel(src)

/datum/airalarm_control/proc/unregister_sensor(obj/machinery/air_sensor/sensor)
	sensors -= sensor
	sensor.control = null
	garbage_collect()

/datum/airalarm_control/proc/unregister_vent(obj/machinery/atmospherics/components/unary/vent_pump/vent)
	vents -= vent
	vent.control = null
	garbage_collect()

/datum/airalarm_control/proc/unregister_scrubber(obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber)
	scrubbers -= scrubber
	scrubber.control = null
	garbage_collect()

/datum/airalarm_control/proc/unregister_alarm(obj/machinery/airalarm/alarm)
	airalarms -= alarm
	alarm.control = null
	garbage_collect()

/datum/airalarm_control/server
	breathable_gas_ranges = list(
		AALARM_PRESSURE				= new/datum/gas_range/no_checks,
		AALARM_TEMPERATURE			= new/datum/gas_range/no_checks,
		/datum/gas/oxygen			= new/datum/gas_range/no_checks,
		/datum/gas/nitrogen			= new/datum/gas_range/no_checks,
		/datum/gas/carbon_dioxide	= new/datum/gas_range/no_checks,
		/datum/gas/miasma			= new/datum/gas_range/no_checks,
		/datum/gas/plasma			= new/datum/gas_range/no_checks,
		/datum/gas/nitrous_oxide	= new/datum/gas_range/no_checks,
		/datum/gas/bz				= new/datum/gas_range/no_checks,
		/datum/gas/hypernoblium		= new/datum/gas_range/no_checks,
		/datum/gas/water_vapor		= new/datum/gas_range/no_checks,
		/datum/gas/tritium			= new/datum/gas_range/no_checks,
		/datum/gas/stimulum			= new/datum/gas_range/no_checks,
		/datum/gas/nitryl			= new/datum/gas_range/no_checks,
		/datum/gas/pluoxium			= new/datum/gas_range/no_checks,
		/datum/gas/freon			= new/datum/gas_range/no_checks,
		/datum/gas/hydrogen			= new/datum/gas_range/no_checks,
		/datum/gas/healium			= new/datum/gas_range/dangerous,
		/datum/gas/proto_nitrate	= new/datum/gas_range/dangerous,
		/datum/gas/zauker			= new/datum/gas_range/dangerous,
		/datum/gas/halon			= new/datum/gas_range/dangerous,
		/datum/gas/hexane			= new/datum/gas_range/dangerous
	)

/datum/airalarm_control/kitchen_cold_room
	breathable_gas_ranges = list(
		AALARM_PRESSURE				= new/datum/gas_range(ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE*  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2), // kPa
		AALARM_TEMPERATURE			= new/datum/gas_range(COLD_ROOM_TEMP-40, COLD_ROOM_TEMP-20, COLD_ROOM_TEMP+20, COLD_ROOM_TEMP+40),
		/datum/gas/oxygen			= new/datum/gas_range(16, 19, 135, 140), // Partial pressure, kpa
		/datum/gas/nitrogen			= new/datum/gas_range(-1, -1, 1000, 1000),
		/datum/gas/carbon_dioxide	= new/datum/gas_range(-1, -1, 5, 10),
		/datum/gas/miasma			= new/datum/gas_range/(-1, -1, 2, 5),
		/datum/gas/plasma			= new/datum/gas_range/dangerous,
		/datum/gas/nitrous_oxide	= new/datum/gas_range/dangerous,
		/datum/gas/bz				= new/datum/gas_range/dangerous,
		/datum/gas/hypernoblium		= new/datum/gas_range(-1, -1, 1000, 1000), // Hyper-Noblium is inert and nontoxic
		/datum/gas/water_vapor		= new/datum/gas_range/dangerous,
		/datum/gas/tritium			= new/datum/gas_range/dangerous,
		/datum/gas/stimulum			= new/datum/gas_range/dangerous,
		/datum/gas/nitryl			= new/datum/gas_range/dangerous,
		/datum/gas/pluoxium			= new/datum/gas_range(-1, -1, 1000, 1000), // Unlike oxygen, pluoxium does not fuel plasma/tritium fires
		/datum/gas/freon			= new/datum/gas_range/dangerous,
		/datum/gas/hydrogen			= new/datum/gas_range/dangerous,
		/datum/gas/healium			= new/datum/gas_range/dangerous,
		/datum/gas/proto_nitrate	= new/datum/gas_range/dangerous,
		/datum/gas/zauker			= new/datum/gas_range/dangerous,
		/datum/gas/halon			= new/datum/gas_range/dangerous,
		/datum/gas/hexane			= new/datum/gas_range/dangerous
	)
