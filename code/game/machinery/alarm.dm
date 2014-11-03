////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_REPLACEMENT	2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC		3 //constantly sucks all air
#define AALARM_MODE_CYCLE		4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL		5 //emergency fill
#define AALARM_MODE_OFF			6 //Shuts it all down.

#define AALARM_PRESET_HUMAN     1 // Default
#define AALARM_PRESET_VOX       2 // Support Vox
#define AALARM_PRESET_SERVER    3 // Server Coldroom

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

//1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 1000

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 200
	power_channel = ENVIRON
	req_one_access = list(access_atmospherics, access_engine_equip)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 0
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	// Waiting on a device to respond.
	// Specifies an id_tag.  NULL means we aren't waiting.
	var/waiting_on_device=null

	var/mode = AALARM_MODE_SCRUBBING
	var/preset = AALARM_PRESET_HUMAN
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/local_danger_level = 0
	var/alarmActivated = 0 // Manually activated (independent from danger level)
	var/danger_averted_confidence=0
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.

	var/target_temperature = T0C+20
	var/regulating_temperature = 0

	var/datum/radio_frequency/radio_connection

	var/list/TLV = list()

/obj/machinery/alarm/xenobio
	preset = AALARM_PRESET_HUMAN
	req_one_access = list(access_rd, access_atmospherics, access_engine_equip, access_xenobiology)
	req_access = list()

/obj/machinery/alarm/server
	preset = AALARM_PRESET_SERVER
	req_one_access = list(access_rd, access_atmospherics, access_engine_equip)
	req_access = list()

/obj/machinery/alarm/vox
	preset = AALARM_PRESET_VOX
	req_access = list()

/obj/machinery/alarm/proc/apply_preset(var/no_cycle_after=0)
	// Propogate settings.
	for (var/area/A in areaMaster.related)
		for (var/obj/machinery/alarm/AA in A)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.preset != src.preset)
				AA.preset=preset
				apply_preset(1) // Only this air alarm should send a cycle.

	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["nitrogen"] =		list(-1, -1,  -1,  -1) // Partial pressure, kpa
	TLV["carbon_dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-30, T0C, T0C+40, T0C+70) // K
	target_temperature = T0C+20
	switch(preset)
		if(AALARM_PRESET_VOX) // Same as usual, s/nitrogen/oxygen
			TLV["nitrogen"] = 		list(16, 19, 135, 140) // Vox use same partial pressure values for N2 as humans do for O2.
			TLV["oxygen"] =			list(-1.0, -1.0, 0.5, 1.0) // Under 1 kPa (PP), vox don't notice squat (vox_oxygen_max)
		if(AALARM_PRESET_SERVER) // Cold as fuck.
			TLV["oxygen"] =			list(-1.0, -1.0,-1.0,-1.0)
			TLV["carbon_dioxide"] = list(-1.0, -1.0,   5,  10) // Partial pressure, kpa
			TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
			TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
			TLV["pressure"] =		list(0,ONE_ATMOSPHERE*0.10,ONE_ATMOSPHERE*1.40,ONE_ATMOSPHERE*1.60) /* kpa */
			TLV["temperature"] =	list(20, 40, 140, 160) // K
			target_temperature = 90
	if(!no_cycle_after)
		mode = AALARM_MODE_CYCLE
		apply_mode()


/obj/machinery/alarm/New(var/loc, var/dir, var/building = 0)
	..()
	wires = new(src)

	if(building)
		if(loc)
			src.loc = loc

		if(dir)
			src.dir = dir

		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		update_icon()
		if(ticker && ticker.current_state == 3)//if the game is running
			src.initialize()
		return

	first_run()

/obj/machinery/alarm/Destroy()
	if(wires)
		wires.Destroy()
		wires = null

	..()

/obj/machinery/alarm/proc/first_run()
	area_uid = areaMaster.uid
	name = "[areaMaster.name] Air Alarm"

	// breathable air according to human/Life()
	/*
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["nitrogen"] =		list(-1, -1,  -1,  -1) // Partial pressure, kpa
	TLV["carbon_dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-26, T0C, T0C+40, T0C+66) // K
	*/
	apply_preset(1) // Don't cycle.


/obj/machinery/alarm/initialize()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()


/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		use_power = 0
		return

	var/turf/simulated/location = loc
	if(!istype(location))	return//returns if loc is not simulated

	var/datum/gas_mixture/environment = location.return_air()

	// Handle temperature adjustment here.
	if(environment.temperature < target_temperature - 2 || environment.temperature > target_temperature + 2 || regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		if(get_danger_level(target_temperature, TLV["temperature"]))
			return

		if(!regulating_temperature)
			regulating_temperature = 1
			visible_message("\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
			"You hear a click and a faint electronic hum.")

		if(target_temperature > T0C + MAX_TEMPERATURE)
			target_temperature = T0C + MAX_TEMPERATURE

		if(target_temperature < T0C + MIN_TEMPERATURE)
			target_temperature = T0C + MIN_TEMPERATURE

		var/datum/gas_mixture/gas = location.remove_air(0.25 * environment.total_moles)
		if(gas)
			var/heat_capacity = gas.heat_capacity()
			var/energy_used = max(abs(heat_capacity * (gas.temperature - target_temperature)), MAX_ENERGY_CHANGE)

			// We need to cool ourselves.
			if (environment.temperature > target_temperature)
				gas.temperature -= energy_used / heat_capacity
			else
				gas.temperature += energy_used / heat_capacity

			environment.merge(gas)

			if (abs(environment.temperature - target_temperature) <= 0.5)
				regulating_temperature = 0
				visible_message("\The [src] clicks quietly as it stops [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",\
				"You hear a click as a faint electronic humming stops.")

	var/old_level = local_danger_level
	var/new_danger = calculate_local_danger_level(environment)

	if (new_danger < old_level)
		danger_averted_confidence++
		use_power = 1

	// Only change danger level if:
	// we're going up a level
	// OR if we're going down a level and have sufficient confidence (prevents spamming update_icon).
	if (old_level < new_danger || (danger_averted_confidence >= 5 && new_danger < old_level))
		setDangerLevel(new_danger)
		update_icon()
		danger_averted_confidence = 0 // Reset counter.
		use_power = 2

	if (mode==AALARM_MODE_CYCLE && environment.return_pressure()<ONE_ATMOSPHERE*0.05)
		mode=AALARM_MODE_FILL
		apply_mode()


	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		if(RCON_AUTO)
			if(local_danger_level == 2)
				remote_control = 1
			else
				remote_control = 0
		if(RCON_YES)
			remote_control = 1
	if(screen == AALARM_SCREEN_MAIN)
		updateDialog()
	return

/obj/machinery/alarm/proc/calculate_local_danger_level(const/datum/gas_mixture/environment)
	if (wires.IsIndexCut(AALARM_WIRE_AALARM))
		return 2 // MAXIMUM ALARM (With gravelly voice) - N3X.

	if (isnull(environment))
		return 0

	var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume
	var/environment_pressure = environment.return_pressure()
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles

	var/pressure_dangerlevel = get_danger_level(environment_pressure, TLV["pressure"])
	var/oxygen_dangerlevel = get_danger_level(environment.oxygen*partial_pressure, TLV["oxygen"])
	var/nitrogen_dangerlevel = get_danger_level(environment.nitrogen*partial_pressure, TLV["nitrogen"])
	var/co2_dangerlevel = get_danger_level(environment.carbon_dioxide*partial_pressure, TLV["carbon_dioxide"])
	var/plasma_dangerlevel = get_danger_level(environment.toxins*partial_pressure, TLV["plasma"])
	var/temperature_dangerlevel = get_danger_level(environment.temperature, TLV["temperature"])
	var/other_dangerlevel = get_danger_level(other_moles*partial_pressure, TLV["other"])

	return max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		co2_dangerlevel,
		nitrogen_dangerlevel,
		plasma_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
		)

/obj/machinery/alarm/proc/master_is_operating()
	return areaMaster.master_air_alarm && !(areaMaster.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master()
	for (var/area/A in areaMaster.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)))
				areaMaster.master_air_alarm = AA
				return 1
	return 0

/obj/machinery/alarm/proc/get_danger_level(const/current_value, const/list/danger_levels)
	if ((current_value >= danger_levels[4] && danger_levels[4] > 0) || current_value <= danger_levels[1])
		return 2
	if ((current_value >= danger_levels[3] && danger_levels[3] > 0) || current_value <= danger_levels[2])
		return 1

	return 0

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	switch(max(local_danger_level, areaMaster.atmosalm-1))
		if (0)
			icon_state = "alarm0"
		if (1)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if (2)
			icon_state = "alarm1"

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN) || !areaMaster)
		return
	if (areaMaster.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (areaMaster.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if (!id_tag)
		return
	if (signal.data["area"] != area_uid)
		return
	if (signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in areaMaster.air_scrub_names) && !(id_tag in areaMaster.air_vent_names))
		register_env_machine(id_tag, dev_type)
	var/got_update=0
	if(dev_type == "AScr")
		areaMaster.air_scrub_info[id_tag] = signal.data
		got_update=1
	else if(dev_type == "AVP")
		areaMaster.air_vent_info[id_tag] = signal.data
		got_update=1
	if(got_update && waiting_on_device==id_tag)
		updateUsrDialog()
		waiting_on_device=null

/obj/machinery/alarm/proc/register_env_machine(var/m_id, var/device_type)
	var/new_name
	if (device_type=="AVP")
		new_name = "[areaMaster.name] Vent Pump #[areaMaster.air_vent_names.len+1]"
		areaMaster.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[areaMaster.name] Air Scrubber #[areaMaster.air_scrub_names.len+1]"
		areaMaster.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in areaMaster.air_vent_names)
		var/list/I = areaMaster.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in areaMaster.air_scrub_names)
		var/list/I = areaMaster.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(var/target, var/list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			world << text("Signal [] Broadcasted to []", command, target)

	return 1

/obj/machinery/alarm/proc/apply_mode()
	var/current_pressures = TLV["pressure"]
	var/target_pressure = (current_pressures[2] + current_pressures[3])/2
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in areaMaster.air_scrub_names)
				send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "o2_scrub"=(preset==AALARM_PRESET_VOX), "n2_scrub"=0, "scrubbing"= 1, "panic_siphon"= 0) )
			for(var/device_id in areaMaster.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/device_id in areaMaster.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in areaMaster.air_vent_names)
				send_signal(device_id, list("power"= 0) )

		if(AALARM_MODE_REPLACEMENT)
			for(var/device_id in areaMaster.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in areaMaster.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_FILL)
			for(var/device_id in areaMaster.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in areaMaster.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= 1, "set_external_pressure"= target_pressure) )

		if(AALARM_MODE_OFF)
			for(var/device_id in areaMaster.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in areaMaster.air_vent_names)
				send_signal(device_id, list("power"= 0) )

// This sets our danger level, and, if it's changed, forces a new election of danger levels.
/obj/machinery/alarm/proc/setDangerLevel(var/new_danger_level)
	if(local_danger_level==new_danger_level)
		return
	local_danger_level=new_danger_level
	if(areaMaster.updateDangerLevel())
		post_alert(new_danger_level)

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = areaMaster.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/proc/air_doors_close(manual)
	areaMaster.CloseFirelocks()

/obj/machinery/alarm/proc/air_doors_open(manual)
	areaMaster.OpenFirelocks()

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	src.add_hiddenprint(user)
	return ui_interact(user)

/obj/machinery/alarm/attack_robot(mob/user)
	if(isMoMMI(user) && !wiresexposed)
		return interact(user)
	else
		return attack_ai(user)

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	return interact(user)

/obj/machinery/alarm/proc/ui_air_status()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.oxygen + environment.carbon_dioxide + environment.toxins + environment.nitrogen
	if(total==0)
		return null

	var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	var/list/current_settings = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = get_danger_level(environment_pressure, current_settings)

	current_settings = TLV["oxygen"]
	var/oxygen_dangerlevel = get_danger_level(environment.oxygen*partial_pressure, current_settings)
	var/oxygen_percent = round(environment.oxygen / total * 100, 2)

	current_settings = TLV["nitrogen"]
	var/nitrogen_dangerlevel = get_danger_level(environment.nitrogen*partial_pressure, current_settings)
	var/nitrogen_percent = round(environment.nitrogen / total * 100, 2)

	current_settings = TLV["carbon_dioxide"]
	var/co2_dangerlevel = get_danger_level(environment.carbon_dioxide*partial_pressure, current_settings)
	var/co2_percent = round(environment.carbon_dioxide / total * 100, 2)

	current_settings = TLV["plasma"]
	var/plasma_dangerlevel = get_danger_level(environment.toxins*partial_pressure, current_settings)
	var/plasma_percent = round(environment.toxins / total * 100, 2)

	current_settings = TLV["other"]
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles
	var/other_dangerlevel = get_danger_level(other_moles*partial_pressure, current_settings)

	current_settings = TLV["temperature"]
	var/temperature_dangerlevel = get_danger_level(environment.temperature, current_settings)


	var/data[0]
	data["pressure"]=environment_pressure
	data["temperature"]=environment.temperature
	data["temperature_c"]=round(environment.temperature - T0C, 0.1)

	var/percentages[0]
	percentages["oxygen"]=oxygen_percent
	percentages["nitrogen"]=nitrogen_percent
	percentages["co2"]=co2_percent
	percentages["plasma"]=plasma_percent
	percentages["other"]=other_moles
	data["contents"]=percentages

	var/danger[0]
	danger["pressure"]=pressure_dangerlevel
	danger["temperature"]=temperature_dangerlevel
	danger["oxygen"]=oxygen_dangerlevel
	danger["nitrogen"]=nitrogen_dangerlevel
	danger["co2"]=co2_dangerlevel
	danger["plasma"]=plasma_dangerlevel
	danger["other"]=other_dangerlevel
	danger["overall"]=max(pressure_dangerlevel,oxygen_dangerlevel,nitrogen_dangerlevel,co2_dangerlevel,plasma_dangerlevel,other_dangerlevel,temperature_dangerlevel)
	data["danger"]=danger
	return data

/obj/machinery/alarm/proc/get_nano_data(mob/user, fromAtmosConsole=0)

	var/data[0]
	data["air"]=ui_air_status()
	data["alarmActivated"]=alarmActivated //|| local_danger_level==2
	data["sensors"]=TLV

	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked AND
	//   NOT adminghost.
	data["locked"]=!fromAtmosConsole && (!(istype(user, /mob/living/silicon)) && locked) && !isAdminGhost(user)

	data["rcon"]=rcon_setting
	data["target_temp"] = target_temperature - T0C
	data["atmos_alarm"] = areaMaster.atmosalm
	data["modes"] = list(
		AALARM_MODE_SCRUBBING   = list("name"="Filtering",   "desc"="Scrubs out contaminants"),\
		AALARM_MODE_REPLACEMENT = list("name"="Replace Air", "desc"="Siphons out air while replacing"),\
		AALARM_MODE_PANIC       = list("name"="Panic",       "desc"="Siphons air out of the room"),\
		AALARM_MODE_CYCLE       = list("name"="Cycle",       "desc"="Siphons air before replacing"),\
		AALARM_MODE_FILL        = list("name"="Fill",        "desc"="Shuts off scrubbers and opens vents"),\
		AALARM_MODE_OFF         = list("name"="Off",         "desc"="Shuts off vents and scrubbers"))
	data["mode"]=mode
	data["presets"]=list(
		AALARM_PRESET_HUMAN		= list("name"="Human",    "desc"="Checks for Oxygen and Nitrogen"),\
		AALARM_PRESET_VOX 		= list("name"="Vox",      "desc"="Checks for Nitrogen only"),\
		AALARM_PRESET_SERVER 	= list("name"="Coldroom", "desc"="For server rooms and freezers"))
	data["preset"]=preset
	data["screen"]=screen

	var/list/vents=list()
	if(areaMaster.air_vent_names.len)
		for(var/id_tag in areaMaster.air_vent_names)
			var/vent_info[0]
			var/long_name = areaMaster.air_vent_names[id_tag]
			var/list/vent_data = areaMaster.air_vent_info[id_tag]
			if(!vent_data)
				continue
			vent_info["id_tag"]=id_tag
			vent_info["name"]=long_name
			vent_info += vent_data
			vents+=list(vent_info)
	data["vents"]=vents

	var/list/scrubbers=list()
	if(areaMaster.air_scrub_names.len)
		for(var/id_tag in areaMaster.air_scrub_names)
			var/long_name = areaMaster.air_scrub_names[id_tag]
			var/list/scrubber_data = areaMaster.air_scrub_info[id_tag]
			if(!scrubber_data)
				continue
			scrubber_data["id_tag"]=id_tag
			scrubber_data["name"]=long_name
			scrubbers+=list(scrubber_data)
	data["scrubbers"]=scrubbers
	return data


/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(user.stat && !isobserver(user))
		return

	var/list/data=src.get_nano_data(user,FALSE)

	if (!ui) // no ui has been passed, so we'll search for one
	{
		ui = nanomanager.get_open_ui(user, src, ui_key)
	}
	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "air_alarm.tmpl", name, 550, 410)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return


/obj/machinery/alarm/interact(mob/user)
	user.set_machine(src)

	if(buildstage!=2)
		return

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=air_alarm")
			user << browse(null, "window=AAlarmwires")
			return


		else if (istype(user, /mob/living/silicon) && aidisabled)
			user << "AI control for this Air Alarm interface has been disabled."
			user << browse(null, "window=air_alarm")
			return

	if(wiresexposed && (isMoMMI(user) || !istype(user, /mob/living/silicon)))
		wires.Interact(user)
	if(!shorted)
		ui_interact(user)

/obj/machinery/alarm/Topic(href, href_list)
	var/changed=0

	if(href_list["rcon"])
		rcon_setting = text2num(href_list["rcon"])
		changed=1

	if ( (get_dist(src, usr) > 1 ))
		if (!istype(usr, /mob/living/silicon))
			usr.machine = null
			usr << browse(null, "window=air_alarm")
			usr << browse(null, "window=AAlarmwires")
			return

	add_fingerprint(usr)
	usr.machine = src

	//testing(href)
	if(href_list["command"])
		var/device_id = href_list["id_tag"]
		switch(href_list["command"])
			if( "power",
				"adjust_external_pressure",
				"set_external_pressure",
				"checks",
				"co2_scrub",
				"tox_scrub",
				"n2o_scrub",
				"o2_scrub",
				"n2_scrub",
				"panic_siphon",
				"scrubbing")
				var/val
				if(href_list["val"])
					val=text2num(href_list["val"])
				else
					var/newval = input("Enter new value") as num|null
					if(isnull(newval))
						return
					if(href_list["command"]=="set_external_pressure")
						if(newval>1000+ONE_ATMOSPHERE)
							newval = 1000+ONE_ATMOSPHERE
						if(newval<0)
							newval = 0
					val = newval

				send_signal(device_id, list(href_list["command"] = val ) )
				changed=0 // We wait for the device to reply.
				waiting_on_device=device_id

			if("set_threshold")
				var/env = href_list["env"]
				var/threshold = text2num(href_list["var"])
				var/list/selected = TLV[env]
				var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
				var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null
				if (isnull(newval) || ..() || (locked && !issilicon(usr)))
					return
				if (newval<0)
					selected[threshold] = -1.0
				else if (env=="temperature" && newval>5000)
					selected[threshold] = 5000
				else if (env=="pressure" && newval>50*ONE_ATMOSPHERE)
					selected[threshold] = 50*ONE_ATMOSPHERE
				else if (env!="temperature" && env!="pressure" && newval>200)
					selected[threshold] = 200
				else
					newval = round(newval,0.01)
					selected[threshold] = newval
				if(threshold == 1)
					if(selected[1] > selected[2])
						selected[2] = selected[1]
					if(selected[1] > selected[3])
						selected[3] = selected[1]
					if(selected[1] > selected[4])
						selected[4] = selected[1]
				if(threshold == 2)
					if(selected[1] > selected[2])
						selected[1] = selected[2]
					if(selected[2] > selected[3])
						selected[3] = selected[2]
					if(selected[2] > selected[4])
						selected[4] = selected[2]
				if(threshold == 3)
					if(selected[1] > selected[3])
						selected[1] = selected[3]
					if(selected[2] > selected[3])
						selected[2] = selected[3]
					if(selected[3] > selected[4])
						selected[4] = selected[3]
				if(threshold == 4)
					if(selected[1] > selected[4])
						selected[1] = selected[4]
					if(selected[2] > selected[4])
						selected[2] = selected[4]
					if(selected[3] > selected[4])
						selected[3] = selected[4]

				apply_mode()
				ui_interact(usr)
				return 1

	if(href_list["screen"])
		var/prevscreen=screen
		screen = text2num(href_list["screen"])
		if(prevscreen==screen) return 0
		ui_interact(usr)
		return 1

	if(href_list["atmos_alarm"])
		alarmActivated=1
		areaMaster.updateDangerLevel()
		update_icon()
		ui_interact(usr)
		return 1

	if(href_list["atmos_reset"])
		alarmActivated=0
		areaMaster.updateDangerLevel()
		update_icon()
		ui_interact(usr)
		return 1

	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		apply_mode()
		ui_interact(usr)
		return 1

	if(href_list["preset"])
		preset = text2num(href_list["preset"])
		apply_preset()
		ui_interact(usr)
		return 1

	if(href_list["temperature"])
		var/list/selected = TLV["temperature"]
		var/max_temperature = min(selected[3] - T0C, MAX_TEMPERATURE)
		var/min_temperature = max(selected[2] - T0C, MIN_TEMPERATURE)
		var/input_temperature = input("What temperature would you like the system to maintain? (Capped between [min_temperature]C and [max_temperature]C)", "Thermostat Controls") as num|null
		if(input_temperature==null)
			return
		if(!input_temperature || input_temperature >= max_temperature || input_temperature <= min_temperature)
			usr << "Temperature must be between [min_temperature]C and [max_temperature]C"
		else
			target_temperature = input_temperature + T0C
		ui_interact(usr)
		return 1
	if(changed)
		updateUsrDialog()


/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
/*	if (istype(W, /obj/item/weapon/wirecutters))
		stat ^= BROKEN
		add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		update_icon()
		return
*/
	src.add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
				//user << "You pop the Air Alarm's maintence panel open."
				wiresexposed = !wiresexposed
				user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
				update_icon()
				return

			if (wiresexposed && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))))
				return attack_hand(user)

			if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					user << "It does nothing"
					return
				else
					if(allowed(user) && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
						locked = !locked
						user << "\blue You [ locked ? "lock" : "unlock"] the Air Alarm interface."
						updateUsrDialog()
					else
						user << "\red Access denied."
			return

		if(1)
			if(istype(W, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/coil = W
				if(coil.amount < 5)
					user << "You need more cable for this!"
					return

				user << "You wire \the [src]!"
				coil.amount -= 5
				if(!coil.amount)
					del(coil)

				buildstage = 2
				update_icon()
				first_run()
				return

			else if(istype(W, /obj/item/weapon/crowbar))
				user << "You start prying out the circuit."
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user,20))
					user << "You pry out the circuit!"
					var/obj/item/weapon/circuitboard/air_alarm/circuit = new /obj/item/weapon/circuitboard/air_alarm()
					circuit.loc = user.loc
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/circuitboard/air_alarm))
				user << "You insert the circuit!"
				del(W)
				buildstage = 1
				update_icon()
				return

			else if(istype(W, /obj/item/weapon/wrench))
				user << "You remove the fire alarm assembly from the wall!"
				var/obj/item/alarm_frame/frame = new /obj/item/alarm_frame()
				frame.loc = user.loc
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				del(src)
				return

	return ..()

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()

/obj/machinery/alarm/examine()
	..()
	if (buildstage < 2)
		usr << "It is not wired."
	if (buildstage < 1)
		usr << "The circuit is missing."

/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/alarm_frame
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 2*CC_PER_SHEET_METAL
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL

/obj/item/alarm_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)
		return
	..()

/obj/item/alarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red Air Alarm cannot be placed on this spot."
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "\red Air Alarm cannot be placed in this area."
		return

	if(gotwallitem(loc, ndir))
		usr << "\red There's already an item on this wall!"
		return

	new /obj/machinery/alarm(loc, ndir, 1)
	del(src)

/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "Fire Alarm"
	desc = "<i>\"Pull this in case of emergency\"<i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()

	if(wiresexposed)
		switch(buildstage)
			if(2)
				icon_state="fire_b2"
			if(1)
				icon_state="fire_b1"
			if(0)
				icon_state="fire_b0"

		return

	if(stat & BROKEN)
		icon_state = "firex"
	else if(stat & NOPOWER)
		icon_state = "firep"
	else if(!src.detecting)
		icon_state = "fire1"
	else
		icon_state = "fire0"

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(src.detecting)
		if(exposed_temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if (istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (istype(W, /obj/item/device/multitool))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("\red [user] has reconnected [src]'s detecting unit!", "You have reconnected [src]'s detecting unit.")
					else
						user.visible_message("\red [user] has disconnected [src]'s detecting unit!", "You have disconnected [src]'s detecting unit.")
				if(istype(W, /obj/item/weapon/wirecutters))
					if(do_after(user,50))
						buildstage=1
						user.visible_message("\red [user] has cut the wiring from \the [src]!", "You have cut the last of the wiring from \the [src].")
						update_icon()
						new /obj/item/weapon/cable_coil(user.loc,5)
						playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			if(1)
				if(istype(W, /obj/item/weapon/cable_coil))
					var/obj/item/weapon/cable_coil/coil = W
					if(coil.amount < 5)
						user << "You need more cable for this!"
						return

					coil.amount -= 5
					if(!coil.amount)
						del(coil)

					buildstage = 2
					user << "You wire \the [src]!"
					update_icon()

				else if(istype(W, /obj/item/weapon/crowbar))
					user << "You pry out the circuit!"
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					spawn(20)
						var/obj/item/weapon/circuitboard/fire_alarm/circuit = new /obj/item/weapon/circuitboard/fire_alarm()
						circuit.loc = user.loc
						buildstage = 0
						update_icon()
			if(0)
				if(istype(W, /obj/item/weapon/circuitboard/fire_alarm))
					user << "You insert the circuit!"
					del(W)
					buildstage = 1
					update_icon()

				else if(istype(W, /obj/item/weapon/wrench))
					user << "You remove the fire alarm assembly from the wall!"
					var/obj/item/firealarm_frame/frame = new /obj/item/firealarm_frame()
					frame.loc = user.loc
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
					del(src)
		return

	src.alarm()
	return

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
			processing_objects.Remove(src)
		src.updateDialog()
	last_process = world.timeofday

	if(locate(/obj/fire) in loc)
		alarm()

	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon))

		if (areaMaster.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> [d1]\n<HR>The current alert level is: [get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	else
		if (areaMaster.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>[stars("Fire alarm")]</B> [d1]\n<HR><b>The current alert level is: [stars(get_security_level())]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	return

/obj/machinery/firealarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return

	if (buildstage != 2)
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if (href_list["reset"])
			src.reset()
		else if (href_list["alarm"])
			src.alarm()
		else if (href_list["time"])
			src.timing = text2num(href_list["time"])
			last_process = world.timeofday
			processing_objects.Add(src)
		else if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 120)

		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return
	areaMaster.firereset()
	update_icon()
	return

/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ))
		return
	areaMaster.firealert()
	update_icon()
	//playsound(get_turf(src), 'sound/ambience/signal.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, dir, building)
	..()
	name = "[areaMaster.name] fire alarm"
	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(z == 1)
		if(security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

	update_icon()

/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/firealarm_frame
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt=2*CC_PER_SHEET_METAL
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL

/obj/item/firealarm_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)
		return
	..()

/obj/item/firealarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red Fire Alarm cannot be placed on this spot."
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "\red Fire Alarm cannot be placed in this area."
		return

	if(gotwallitem(loc, ndir))
		usr << "\red There's already an item on this wall!"
		return

	new /obj/machinery/firealarm(loc, ndir, 1)

	del(src)


/obj/machinery/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6

/obj/machinery/partyalarm/New()
	..()
	name = "[areaMaster.name] party alarm"

/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		if (areaMaster.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		if (areaMaster.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if (!( working ))
		return
	areaMaster.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if (!( working ))
		return
	areaMaster.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			reset()
		else
			if (href_list["alarm"])
				alarm()
			else
				if (href_list["time"])
					timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						time += tp
						time = min(max(round(time), 0), 120)
		updateUsrDialog()

		add_fingerprint(usr)
	else
		usr << browse(null, "window=partyalarm")
		return
	return