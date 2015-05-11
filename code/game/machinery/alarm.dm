//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
// A datum for dealing with threshold limit values
// used in /obj/machinery/alarm
/datum/tlv
	var/min2
	var/min1
	var/max1
	var/max2

/datum/tlv/New(_min2 as num, _min1 as num, _max1 as num, _max2 as num)
	min2 = _min2
	min1 = _min1
	max1 = _max1
	max2 = _max2

/datum/tlv/proc/get_danger_level(curval as num)
	if (max2 >=0 && curval>=max2)
		return 2
	if (min2 >=0 && curval<=min2)
		return 2
	if (max1 >=0 && curval>=max1)
		return 1
	if (min1 >=0 && curval<=min1)
		return 1
	return 0

/datum/tlv/proc/CopyFrom(datum/tlv/other)
	min2 = other.min2
	min1 = other.min1
	max1 = other.max1
	max2 = other.max2

#define AALARM_MODE_SCRUBBING 1
#define AALARM_MODE_VENTING 2 //makes draught
#define AALARM_MODE_PANIC 3 //constantly sucks all air
#define AALARM_MODE_REPLACEMENT 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF 5
#define AALARM_MODE_FLOOD 6 //Emagged mode; turns off scrubbers and pressure checks on vents

#define AALARM_SCREEN_MAIN    1
#define AALARM_SCREEN_VENT    2
#define AALARM_SCREEN_SCRUB   3
#define AALARM_SCREEN_MODE    4
#define AALARM_SCREEN_SENSORS 5

#define AALARM_REPORT_TIMEOUT 100

/obj/machinery/alarm
	name = "alarm"
	desc = "A machine that monitors atmosphere levels. Goes off if the area is dangerous."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(access_atmospherics)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437

	var/datum/radio_frequency/radio_connection
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone


	var/mode = AALARM_MODE_SCRUBBING

	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/danger_level = 0

	// breathable air according to human/Life()
	var/list/TLV = list(
		"oxygen"         = new/datum/tlv(  16,   19, 135, 140), // Partial pressure, kpa
		"carbon dioxide" = new/datum/tlv(-1.0, -1.0,   5,  10), // Partial pressure, kpa
		"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
		"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
		"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20), /* kpa */
		"temperature"    = new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66), // K
	)

/*
	// breathable air according to wikipedia
		"oxygen"         = new/datum/tlv(   9,  12, 158, 296), // Partial pressure, kpa
		"carbon dioxide" = new/datum/tlv(-1.0,-1.0, 0.5,   1), // Partial pressure, kpa
*/
/obj/machinery/alarm/server
	//req_access = list(access_rd) //no, let departaments to work together
	TLV = list(
		"oxygen"         = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), // Partial pressure, kpa
		"carbon dioxide" = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), // Partial pressure, kpa
		"plasma"         = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), // Partial pressure, kpa
		"other"          = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), // Partial pressure, kpa
		"pressure"       = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), /* kpa */
		"temperature"    = new/datum/tlv(-1.0, -1.0,-1.0,-1.0), // K
	)

/obj/machinery/alarm/kitchen_cold_room
	TLV = list(
		"oxygen"         = new/datum/tlv(  16,   19, 135, 140), // Partial pressure, kpa
		"carbon dioxide" = new/datum/tlv(-1.0, -1.0,   5,  10), // Partial pressure, kpa
		"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
		"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
		"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.50,ONE_ATMOSPHERE*1.60), /* kpa */
		"temperature"    = new/datum/tlv(200, 210, 273.15, 283.15), // K
	)

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm/New(nloc, ndir, nbuild)
	..()
	wires = new(src)
	if(nloc)
		loc = nloc

	if(ndir)
		dir = ndir

	if(nbuild)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	alarm_area = get_area(loc)
	if (alarm_area.master)
		alarm_area = alarm_area.master
	area_uid = alarm_area.uid
	if (name == "alarm")
		name = "[alarm_area.name] Air Alarm"

	update_icon()
	if(ticker && ticker.current_state == 3)//if the game is running
		src.initialize()

/obj/machinery/alarm/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	..()

/obj/machinery/alarm/initialize()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()

/obj/machinery/alarm/proc/master_is_operating()
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))

/obj/machinery/alarm/proc/elect_master()
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)))
				alarm_area.master_air_alarm = AA
				return 1
	return 0

/obj/machinery/alarm/attack_hand(mob/user)
	if (..())
		return
	user.set_machine(src)

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=air_alarm")
			user << browse(null, "window=AAlarmwires")
			return


		else if (user.has_unlimited_silicon_privilege && src.aidisabled)
			user << "AI control for this Air Alarm interface has been disabled."
			user << browse(null, "window=air_alarm")
			return

	if(!shorted)
		ui_interact(user)

	if(panel_open && (!istype(user, /mob/living/silicon/ai)))
		wires.Interact(user)

	return

/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return

	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "air_alarm.tmpl", "Air Alarm", 350, 500, 1)

/obj/machinery/alarm/get_ui_data(mob/user)
	var/data = list()
	data["locked"] = locked
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["screen"] = screen
	data["dangerous"] = emagged
	populate_status(data)
	if (!locked || user.has_unlimited_silicon_privilege)
		populate_controls(data)
	return data

/obj/machinery/alarm/proc/shock(mob/user, prb)
	if((stat & (NOPOWER)))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src))
		return 1
	else
		return 0

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
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

/obj/machinery/alarm/proc/populate_status(var/list/data)
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.oxygen + environment.carbon_dioxide + environment.toxins + environment.nitrogen

	var/list/environment_data = list()
	data["atmos_alarm"] = alarm_area.atmosalm
	data["fire_alarm"] = (alarm_area.fire != null && alarm_area.fire)
	data["danger_level"] = danger_level
	if(total)
		var/datum/tlv/cur_tlv
		var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

		cur_tlv = TLV["pressure"]
		var/pressure = environment.return_pressure()
		var/pressure_danger = cur_tlv.get_danger_level(pressure)
		environment_data += list(list("name" = "Pressure", "value" = pressure, "unit" = "kPa", "danger_level" = pressure_danger))

		cur_tlv = TLV["oxygen"]
		var/oxygen_danger = cur_tlv.get_danger_level(environment.oxygen*partial_pressure)
		environment_data += list(list("name" = "Oxygen", "value" = environment.oxygen / total * 100, "unit" = "%", "danger_level" = oxygen_danger))

		cur_tlv = TLV["carbon dioxide"]
		var/carbon_dioxide_danger = cur_tlv.get_danger_level(environment.carbon_dioxide*partial_pressure)
		environment_data += list(list("name" = "Carbon dioxide", "value" = environment.carbon_dioxide / total * 100, "unit" = "%", "danger_level" = carbon_dioxide_danger))

		cur_tlv = TLV["plasma"]
		var/plasma_danger = cur_tlv.get_danger_level(environment.toxins*partial_pressure)
		environment_data += list(list("name" = "Toxins", "value" = environment.toxins / total * 100, "unit" = "%", "danger_level" = plasma_danger))

		cur_tlv = TLV["other"]
		var/other_moles = 0.0
		for(var/datum/gas/G in environment.trace_gases)
			other_moles+=G.moles
		var/other_danger = cur_tlv.get_danger_level(other_moles*partial_pressure)
		environment_data += list(list("name" = "Other", "value" = other_moles / total * 100, "unit" = "%", "danger_level" = other_danger))

		cur_tlv = TLV["temperature"]
		var/temperature_danger = cur_tlv.get_danger_level(environment.temperature)
		environment_data += list(list("name" = "Temperature", "value" = environment.temperature, "unit" = "K ([round(environment.temperature - T0C, 0.1)]C)", "danger_level" = temperature_danger))
		data["environment_data"] = environment_data

/obj/machinery/alarm/proc/populate_controls(var/list/data)
	switch(screen)
		if(AALARM_SCREEN_MAIN)
			data["mode"] = mode
		if(AALARM_SCREEN_VENT)
			data["vents"] = list()
			for(var/id_tag in alarm_area.air_vent_names)
				var/long_name = alarm_area.air_vent_names[id_tag]
				var/list/info = alarm_area.air_vent_info[id_tag]
				if(!info)
					continue
				data["vents"] += list(list(
						"id_tag"	= id_tag,
						"long_name" = sanitize(long_name),
						"power"		= info["power"],
						"checks"	= info["checks"],
						"excheck"	= info["checks"]&1,
						"incheck"	= info["checks"]&2,
						"direction"	= info["direction"],
						"external"	= info["external"]
					))
		if(AALARM_SCREEN_SCRUB)
			data["scrubbers"] = list()
			for(var/id_tag in alarm_area.air_scrub_names)
				var/long_name = alarm_area.air_scrub_names[id_tag]
				var/list/info = alarm_area.air_scrub_info[id_tag]
				if(!info)
					continue
				data["scrubbers"] += list(list(
						"id_tag"		= id_tag,
						"long_name" 	= sanitize(long_name),
						"power"			= info["power"],
						"scrubbing"		= info["scrubbing"],
						"panic"			= info["panic"],
						"filter_co2"	= info["filter_co2"],
						"filter_toxins"	= info["filter_toxins"],
						"filter_n2o"	= info["filter_n2o"]
					))
		if(AALARM_SCREEN_MODE)
			data["mode"] = mode
			data["modes"] = list()
			data["modes"] += list(list("name" = "Filtering - Scrubs out contaminants", 				"mode" = AALARM_MODE_SCRUBBING,		"selected" = mode == AALARM_MODE_SCRUBBING, 	"danger" = 0))
			data["modes"] += list(list("name" = "Draught - Siphons out air while replacing",		"mode" = AALARM_MODE_VENTING,		"selected" = mode == AALARM_MODE_VENTING,		"danger" = 0))
			data["modes"] += list(list("name" = "Cycle - Siphons air before replacing", 			"mode" = AALARM_MODE_REPLACEMENT,	"selected" = mode == AALARM_MODE_REPLACEMENT, 	"danger" = 1))
			data["modes"] += list(list("name" = "Panic - Siphons air out of the room", 				"mode" = AALARM_MODE_PANIC,			"selected" = mode == AALARM_MODE_PANIC, 		"danger" = 1))
			data["modes"] += list(list("name" = "Off - Shuts off vents and scrubbers", 				"mode" = AALARM_MODE_OFF,			"selected" = mode == AALARM_MODE_OFF, 			"danger" = 0))
			if (src.emagged)
				data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents",	"mode" = AALARM_MODE_FLOOD,		"selected" = mode == AALARM_MODE_FLOOD, 			"danger" = 1))
		if(AALARM_SCREEN_SENSORS)
			var/datum/tlv/selected
			var/list/thresholds = list()

			var/list/gas_names = list(
				"oxygen"         = "O<sub>2</sub>",
				"carbon dioxide" = "CO<sub>2</sub>",
				"plasma"         = "Toxin",
				"other"          = "Other")
			for (var/g in gas_names)
				thresholds += list(list("name" = gas_names[g], "settings" = list()))
				selected = TLV[g]
				thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "min2", "selected" = selected.min2))
				thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "min1", "selected" = selected.min1))
				thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "max1", "selected" = selected.max1))
				thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = "max2", "selected" = selected.max2))

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


			data["thresholds"] = thresholds

/obj/machinery/alarm/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	if (locked && !usr.has_unlimited_silicon_privilege)
		return

	if ( (get_dist(src, usr) > 1 ))
		if (!istype(usr, /mob/living/silicon))
			usr.unset_machine()
			usr << browse(null, "window=air_alarm")
			return

	if(href_list["toggleaccess"])
		if(usr.has_unlimited_silicon_privilege && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
			locked = !locked

	if(href_list["command"])
		var/device_id = href_list["id_tag"]
		switch(href_list["command"])
			if("set_external_pressure")
				var/input_pressure = input("What pressure you like the system to mantain?", "Pressure Controls") as num|null
				if(isnum(input_pressure))
					send_signal(device_id, list(href_list["command"] = input_pressure))
				return 1

			if("reset_external_pressure")
				send_signal(device_id, list(href_list["command"] = ONE_ATMOSPHERE))
				return 1
			if(
				"power",
				"adjust_external_pressure",
				"co2_scrub",
				"tox_scrub",
				"n2o_scrub",
				"panic_siphon",
				"scrubbing"
			)
				send_signal(device_id, list (href_list["command"] = text2num(href_list["val"])))
				spawn(3)
					src.updateUsrDialog()

			if ("excheck")
				send_signal(device_id, list ("checks" = text2num(href_list["val"])^1))

			if ("incheck")
				send_signal(device_id, list ("checks" = text2num(href_list["val"])^2))

			//if("adjust_threshold") //was a good idea but required very wide window
			if("set_threshold")
				var/env = href_list["env"]
				var/varname = href_list["var"]
				var/datum/tlv/tlv = TLV[env]
				var/newval = input("Enter [varname] for [env]", "Alarm triggers", tlv.vars[varname]) as num|null

				if (isnull(newval) || ..() || (locked && !(usr.has_unlimited_silicon_privilege)))
					return
				if (newval<0)
					tlv.vars[varname] = -1.0
				else if (env=="temperature" && newval>5000)
					tlv.vars[varname] = 5000
				else if (env=="pressure" && newval>50*ONE_ATMOSPHERE)
					tlv.vars[varname] = 50*ONE_ATMOSPHERE
				else if (env!="temperature" && env!="pressure" && newval>200)
					tlv.vars[varname] = 200
				else
					newval = round(newval,0.01)
					tlv.vars[varname] = newval
				spawn(1)
					src.updateUsrDialog()

	if(href_list["screen"])
		screen = text2num(href_list["screen"])
		spawn(1)
			src.updateUsrDialog()


	if(href_list["atmos_alarm"])
		if (alarm_area.atmosalert(2,src))
			post_alert(2)
		spawn(1)
			src.updateUsrDialog()
		update_icon()
	if(href_list["atmos_reset"])
		if (alarm_area.atmosalert(0,src))
			post_alert(0)
		spawn(1)
			src.updateUsrDialog()
		update_icon()

	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		apply_mode()
		spawn(5)
			src.updateUsrDialog()

	return

/obj/machinery/alarm/proc/apply_mode()
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"scrubbing"= 1,
					"panic_siphon"= 0,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))

		if(AALARM_MODE_VENTING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"panic_siphon"= 0,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))
		if(
			AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT
		)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"panic_siphon"= 1
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"panic_siphon"= 0,
					"power"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(AALARM_MODE_FLOOD)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"panic_siphon"= 0,
					"power"=0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 0,
				))

/obj/machinery/alarm/update_icon()
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
	switch(max(danger_level, alarm_area.atmosalm))
		if (0)
			src.icon_state = "alarm0"
		if (1)
			src.icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if (2)
			src.icon_state = "alarm1"

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/turf/simulated/location = src.loc
	if (!istype(location))
		return 0

	var/datum/gas_mixture/environment = location.return_air()

	var/datum/tlv/cur_tlv
	var/GET_PP = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen*GET_PP)

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide*GET_PP)

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins*GET_PP)

	cur_tlv = TLV["other"]
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/old_danger_level = danger_level
	danger_level = max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		co2_dangerlevel,
		plasma_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
	)
	if (old_danger_level!=danger_level)
		apply_danger_level()

	if (mode==AALARM_MODE_REPLACEMENT && environment_pressure<ONE_ATMOSPHERE*0.05)
		mode=AALARM_MODE_SCRUBBING
		apply_mode()

	//src.updateDialog()
	return

/obj/machinery/alarm/proc/post_alert(alert_level)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)

	if(!frequency) return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal,null,-1)

/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = 0
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				new_area_danger_level = max(new_area_danger_level,AA.danger_level)
	if (alarm_area.atmosalert(new_area_danger_level,src)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)
	update_icon()

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob, params)
	switch(buildstage)
		if(2)
			if(istype(W, /obj/item/weapon/wirecutters) && panel_open && (wires.wires_status == 27 || wires.wires_status == 31))   //this checks for all wires to be cut, except the syphon wire which is optional.
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "<span class='notice'>You cut the final wires.</span>"
				var/obj/item/stack/cable_coil/cable = new /obj/item/stack/cable_coil( src.loc )
				cable.amount = 5
				buildstage = 1
				update_icon()
				return

			if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				panel_open = !panel_open
				user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
				update_icon()
				return

			if (panel_open && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))))
				return src.attack_hand(user)
			else if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					user << "<span class='warning'>It does nothing!</span>"
				else
					if(src.allowed(usr) && !wires.IsIndexCut(AALARM_WIRE_IDSCAN))
						locked = !locked
						user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the air alarm interface.</span>"
						src.updateUsrDialog()
					else
						user << "<span class='danger'>Access denied.</span>"
				return
		if(1)
			if(istype(W, /obj/item/weapon/crowbar))
				user.visible_message("[user.name] removes the electronics from [src.name].",\
									"<span class='notice'>You start prying out the circuit...</span>")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if (do_after(user, 20))
					if (buildstage == 1)
						user <<"<span class='notice'>You remove the air alarm electronics.</span>"
						new /obj/item/weapon/airalarm_electronics( src.loc )
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						buildstage = 0
						update_icon()
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					user << "<span class='warning'>You need five lengths of cable to wire the fire alarm!</span>"
					return
				user.visible_message("[user.name] wires the air alarm.", \
									"<span class='notice'>You start wiring the air alarm...</span>")
				if (do_after(user, 20))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						user << "<span class='notice'>You wire the air alarm.</span>"
						wires.wires_status = 0
						aidisabled = 0
						locked = 1
						mode = 1
						shorted = 0
						post_alert(0)
						buildstage = 2
						update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/airalarm_electronics))
				user << "<span class='notice'>You insert the circuit.</span>"
				buildstage = 1
				update_icon()
				user.drop_item()
				qdel(W)
				return

			if(istype(W, /obj/item/weapon/wrench))
				user << "<span class='notice'>You detach \the [src] from the wall.</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				new /obj/item/alarm_frame( user.loc )
				qdel(src)
				return

	return ..()

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		if(loc)
			update_icon()


/obj/machinery/alarm/emag_act(mob/user as mob)
	if(!emagged)
		src.emagged = 1
		user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its safeties.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return


/*
AIR ALARM CIRCUIT
Just a object used in constructing air alarms
*/
/obj/item/weapon/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/module.dmi'
	icon_state = "airalarm_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = 2.0
	m_amt = 50
	g_amt = 50


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
	flags = CONDUCT

/obj/item/alarm_frame/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		qdel(src)
		return
	..()

/obj/item/alarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "<span class='warning'>Air Alarm cannot be placed on this spot!</span>"
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "<span class='warning'>Air Alarm cannot be placed in this area!</span>"
		return

	if(gotwallitem(loc, ndir))
		usr << "<span class='warning'>There's already an item on this wall!</span>"
		return

	new /obj/machinery/alarm(loc, ndir, 1)

	qdel(src)


/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()

	src.overlays = list()

	var/area/A = src.loc
	A = A.loc

	if(panel_open)
		switch(buildstage)
			if(0)
				icon_state="fire_b0"
				return
			if(1)
				icon_state="fire_b1"
				return
			if(2)
				icon_state="fire_b2"

		if((stat & BROKEN) || (stat & NOPOWER))
			return

		overlays += "overlay_[security_level]"
		return

	if(stat & BROKEN)
		icon_state = "firex"
		return

	icon_state = "fire0"

	if(stat & NOPOWER)
		return

	overlays += "overlay_[security_level]"

	if(!src.detecting)
		overlays += "overlay_fire"
	else
		overlays += "overlay_[A.fire ? "fire" : "clear"]"



/obj/machinery/firealarm/emag_act(mob/user as mob)
	if(!emagged)
		src.emagged = 1
		user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its thermal sensors.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return


/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			if(!emagged) //Doesn't give off alarm when emagged
				src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob, params)
	src.add_fingerprint(user)

	if (istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
		update_icon()
		return

	if(panel_open)
		switch(buildstage)
			if(2)
				if (istype(W, /obj/item/device/multitool))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", "<span class='notice'>You reconnect [src]'s detecting unit.</span>")
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", "<span class='notice'>You disconnect [src]'s detecting unit.</span>")

				else if (istype(W, /obj/item/weapon/wirecutters))
					buildstage = 1
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil()
					coil.amount = 5
					coil.loc = user.loc
					user << "<span class='notice'>You cut the wires from \the [src].</span>"
					update_icon()
			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						user << "<span class='warning'>You need more cable for this!</span>"
						return

					coil.use(5)

					buildstage = 2
					user << "<span class='notice'>You wire \the [src].</span>"
					update_icon()

				else if(istype(W, /obj/item/weapon/crowbar))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										"<span class='notice'>You start prying out the circuit...</span>")
					if(do_after(user, 20))
						if(buildstage == 1)
							if(stat & BROKEN)
								user << "<span class='notice'>You remove the destroyed circuit.</span>"
							else
								user << "<span class='notice'>You pry out the circuit.</span>"
								new /obj/item/weapon/firealarm_electronics(user.loc)
							buildstage = 0
							update_icon()
			if(0)
				if(istype(W, /obj/item/weapon/firealarm_electronics))
					user << "<span class='notice'>You insert the circuit.</span>"
					qdel(W)
					buildstage = 1
					update_icon()

				else if(istype(W, /obj/item/weapon/wrench))
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 "<span class='notice'>You remove the fire alarm assembly from the wall.</span>")
					var/obj/item/firealarm_frame/frame = new /obj/item/firealarm_frame()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return

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
			SSobj.processing.Remove(src)
		src.updateDialog()
	last_process = world.timeofday
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		if(loc)
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/safety_warning
	var/d1
	var/d2
	var/dat = ""
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc
		if (src.emagged)
			safety_warning = text("<font color='red'>NOTICE: Thermal sensors nonfunctional. Device will not report or recognize high temperatures.</font>")
		else
			safety_warning = text("Safety measures functioning properly.")
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[safety_warning]<br /><br />[d1]<br /><b>The current alert level is: [get_security_level()]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[d1]<br /><b>The current alert level is: [stars(get_security_level())]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	var/datum/browser/popup = new(user, "firealarm", "Fire Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/Topic(href, href_list)
	if(..())
		return

	if (buildstage != 2)
		return

	usr.set_machine(src)
	if (href_list["reset"])
		src.reset()
	else if (href_list["alarm"])
		src.alarm()
	else if (href_list["time"])
		src.timing = text2num(href_list["time"])
		last_process = world.timeofday
		SSobj.processing |= src
	else if (href_list["tp"])
		var/tp = text2num(href_list["tp"])
		src.time += tp
		src.time = min(max(round(src.time), 0), 120)

	src.updateUsrDialog()

/obj/machinery/firealarm/proc/reset()
	if (stat & (NOPOWER|BROKEN)) // can't reset alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	A.firereset(src)
	return

/obj/machinery/firealarm/proc/alarm()
	if (stat & (NOPOWER|BROKEN))  // can't activate alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	A.firealert(src)
	//playsound(src.loc, 'sound/ambience/signal.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, dir, building)
	..()

	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(z == 1)
		if(security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

	update_icon()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/weapon/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""
	w_class = 2.0
	m_amt = 50
	g_amt = 50


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
	flags = CONDUCT


/obj/item/firealarm_frame/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		qdel(src)
		return
	..()

/obj/item/firealarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "<span class='warning'>Fire Alarm cannot be placed on this spot.</span>"
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "<span class='warning'>Fire Alarm cannot be placed in this area.</span>"
		return

	if(gotwallitem(loc, ndir))
		usr << "<span class='warning'>There's already an item on this wall!</span>"
		return

	new /obj/machinery/firealarm(loc, ndir, 1)

	qdel(src)

/*
 * Party button
 */

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"

/obj/machinery/firealarm/partyalarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/d1
	var/dat
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []</BODY></HTML>", d1)

	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []", stars("Party Button"), d1)

	var/datum/browser/popup = new(user, "firealarm", "Party Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/partyalarm/reset()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyreset()
	return

/obj/machinery/firealarm/partyalarm/alarm()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyalert()
	return
