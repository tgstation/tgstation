
/proc/RandomAAlarmWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/AAlarmwires = list(0, 0, 0, 0, 0)
	AAlarmIndexToFlag = list(0, 0, 0, 0, 0)
	AAlarmIndexToWireColor = list(0, 0, 0, 0, 0)
	AAlarmWireColorToIndex = list(0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<32, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 5)
			if (AAlarmwires[colorIndex]==0)
				valid = 1
				AAlarmwires[colorIndex] = flag
				AAlarmIndexToFlag[flagIndex] = flag
				AAlarmIndexToWireColor[flagIndex] = colorIndex
				AAlarmWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return AAlarmwires



// A datum for dealing with threshold limit values
// used in /obj/machinery/alarm
/datum/tlv
	var
		min2
		min1
		max1
		max2
	New(_min2 as num, _min1 as num, _max1 as num, _max2 as num)
		min2 = _min2
		min1 = _min1
		max1 = _max1
		max2 = _max2
	proc/get_danger_level(curval as num)
		if (max2 >=0 && curval>=max2)
			return 2
		if (min2 >=0 && curval<=min2)
			return 2
		if (max1 >=0 && curval>=max1)
			return 1
		if (min1 >=0 && curval<=min1)
			return 1
		return 0
	proc/CopyFrom(datum/tlv/other)
		min2 = other.min2
		min1 = other.min1
		max1 = other.max1
		max2 = other.max2

/obj/machinery/alarm
	name = "alarm"
	icon = 'monitors.dmi'
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
	var/remote_control = 0
#define RCON_NO 1
#define RCON_AUTO 2
#define RCON_YES 3
	var/rcon_setting = 2
	var/rcon_time = 0
#define AALARM_REPORT_TIMEOUT 100
	var/datum/radio_frequency/radio_connection
	var/locked = 1
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

 // Uses code from apc.dm

#define AALARM_WIRE_IDSCAN 1									//Added wires
#define AALARM_WIRE_POWER 2
#define AALARM_WIRE_SYPHON 3
#define AALARM_WIRE_AI_CONTROL 4
#define AALARM_WIRE_AALARM 5


#define AALARM_MODE_SCRUBBING    1
#define AALARM_MODE_VENTING      2 //makes draught
#define AALARM_MODE_PANIC        3 //constantly sucks all air
#define AALARM_MODE_REPLACEMENT  4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF          5
	var/mode = AALARM_MODE_SCRUBBING

#define AALARM_SCREEN_MAIN    1
#define AALARM_SCREEN_VENT    2
#define AALARM_SCREEN_SCRUB   3
#define AALARM_SCREEN_MODE    4
#define AALARM_SCREEN_SENSORS 5
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
		"carbon dioxide" = new/datum/tlv(-1.0, -1.0,   5,  10), // Partial pressure, kpa
		"plasma"         = new/datum/tlv(-1.0, -1.0, 0.2, 0.5), // Partial pressure, kpa
		"other"          = new/datum/tlv(-1.0, -1.0, 0.5, 1.0), // Partial pressure, kpa
		"pressure"       = new/datum/tlv(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.40,ONE_ATMOSPHERE*1.60), /* kpa */
		"temperature"    = new/datum/tlv(40, 60, 100, 120), // K
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
	var/list/air_vent_names
	var/list/air_scrub_names
	var/list/air_vent_info
	var/list/air_scrub_info

/obj/machinery/alarm/New()
	..()
	alarm_area = get_area(loc)
	if (alarm_area.master)
		alarm_area = alarm_area.master
	area_uid = alarm_area.uid
	if (name == "alarm")
		name = "[alarm_area.name] Air Alarm"

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
				if (!alarm_area.air_vent_names)
					alarm_area.air_vent_names = new
					alarm_area.air_scrub_names = new
					alarm_area.air_vent_info = new
					alarm_area.air_scrub_info = new
				return 1
	return 0

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	user.machine = src

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=air_alarm")
			user << browse(null, "window=AAlarmwires")
			return


		else if (istype(user, /mob/living/silicon) && src.aidisabled)
			user << "AI control for this Air Alarm interface has been disabled."
			user << browse(null, "window=air_alarm")
			return

	if(wiresexposed && (!istype(user, /mob/living/silicon)))
		var/t1 = text("<html><head><title>[alarm_area.name] Air Alarm Wires</title></head><body><B>Access Panel</B><br>\n")
		var/list/AAlarmwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Black" = 5,
		)
		for(var/wiredesc in AAlarmwires)
			var/is_uncut = src.AAlarmwires & AAlarmWireColorToFlag[AAlarmwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];AAlarmwires=[AAlarmwires[wiredesc]]'>Mend</a>"

			else
				t1 += "<a href='?src=\ref[src];AAlarmwires=[AAlarmwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[AAlarmwires[wiredesc]]'>Pulse</a> "

			t1 += "<br>"
		t1 += text("<br>\n[(src.locked ? "The Air Alarm is locked." : "The Air Alarm is unlocked.")]<br>\n[((src.shorted || (stat & (NOPOWER|BROKEN))) ? "The Air Alarm is offline." : "The Air Alarm is working properly!")]<br>\n[(src.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p></body></html>")
		user << browse(t1, "window=AAlarmwires")
		onclose(user, "AAlarmwires")

	if(!shorted)
		user << browse(return_text(),"window=air_alarm")
		onclose(user, "air_alarm")
		refresh_all()

	return


/obj/machinery/alarm/proc/isWireColorCut(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	return ((src.AAlarmwires & wireFlag) == 0)

/obj/machinery/alarm/proc/isWireCut(var/wireIndex)
	var/wireFlag = AAlarmIndexToFlag[wireIndex]
	return ((src.AAlarmwires & wireFlag) == 0)

/obj/machinery/alarm/proc/cut(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	var/wireIndex = AAlarmWireColorToIndex[wireColor]
	AAlarmwires &= ~wireFlag
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)
			src.locked = 1
			//world << "Idscan wire cut"

		if(AALARM_WIRE_POWER)
			src.shock(usr, 50)
			src.shorted = 1
			update_icon()
			//world << "Power wire cut"

		if (AALARM_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
				//world << "AI Control Wire Cut"

		if(AALARM_WIRE_SYPHON)
			mode = AALARM_MODE_PANIC
			apply_mode()
			//world << "Syphon Wire Cut"

		if(AALARM_WIRE_AALARM)

			if (alarm_area.atmosalert(2))
				post_alert(2)
			spawn(1)
				src.updateUsrDialog()
			update_icon()

			//world << "AAlarm Wire Cut"

	src.updateDialog()

	return

/obj/machinery/alarm/proc/mend(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	var/wireIndex = AAlarmWireColorToIndex[wireColor] //not used in this function
	AAlarmwires |= wireFlag
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)
			//world << "Idscan wire mended"

		if(AALARM_WIRE_POWER)
			src.shorted = 0
			src.shock(usr, 50)
			update_icon()
			//world << "Power wire mended"

		if(AALARM_WIRE_AI_CONTROL)
			if (src.aidisabled == 1)
				src.aidisabled = 0
				//world << "AI Cont. wire mended"


	//	if(AALARM_WIRE_SYPHON)
		//	world << "Syphon Wire mended"


	//	if(AALARM_WIRE_AALARM)
			//world << "AAlarm Wire mended"

	src.updateDialog()
	return

/obj/machinery/alarm/proc/pulse(var/wireColor)
	//var/wireFlag = AAlarmWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = AAlarmWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)			//unlocks for 30 seconds, if you have a better way to hack I'm all ears
			src.locked = 0
			spawn(300)
				src.locked = 1
			//world << "Idscan wire pulsed"

		if (AALARM_WIRE_POWER)
		//	world << "Power wire pulsed"
			if(shorted == 0)
				shorted = 1
				update_icon()

			spawn(1200)
				if(shorted == 1)
					shorted = 0
					update_icon()


		if (AALARM_WIRE_AI_CONTROL)
		//	world << "AI Control wire pulsed"
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
			spawn(10)
				if (src.aidisabled == 1)
					src.aidisabled = 0
				src.updateDialog()

		if(AALARM_WIRE_SYPHON)
		//	world << "Syphon wire pulsed"
			mode = AALARM_MODE_REPLACEMENT
			apply_mode()

		if(AALARM_WIRE_AALARM)
		//	world << "Aalarm wire pulsed"
			if (alarm_area.atmosalert(0))
				post_alert(0)
			spawn(1)
				src.updateUsrDialog()
			update_icon()

	src.updateDialog()
	return

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

/obj/machinery/alarm/Topic(href, href_list)
	src.add_fingerprint(usr)
	usr.machine = src

	if ( (get_dist(src, usr) > 1 ))
		if (!istype(usr, /mob/living/silicon))
			usr.machine = null
			usr << browse(null, "window=air_alarm")
			usr << browse(null, "window=AAlarmwires")
			return

	if (href_list["AAlarmwires"])
		var/t1 = text2num(href_list["AAlarmwires"])
		if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
			usr << "You need wirecutters!"
			return
		if (src.isWireColorCut(t1))
			src.mend(t1)
		else
			src.cut(t1)
	else if (href_list["pulse"])
		var/t1 = text2num(href_list["pulse"])
		if (!istype(usr.equipped(), /obj/item/device/multitool))
			usr << "You need a multitool!"
			return
		if (src.isWireColorCut(t1))
			usr << "You can't pulse a cut wire."
			return
		else
			src.pulse(t1)

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if (alarm_area.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (alarm_area.master_air_alarm != src)
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
	if(!(id_tag in alarm_area.air_scrub_names) && !(id_tag in alarm_area.air_vent_names))
		register_env_machine(id_tag, dev_type)
	if(dev_type == "AScr")
		alarm_area.air_scrub_info[id_tag] = signal.data
	else if(dev_type == "AVP")
		alarm_area.air_vent_info[id_tag] = signal.data

/obj/machinery/alarm/proc/register_env_machine(var/m_id, var/device_type)
	var/new_name
	if (device_type=="AVP")
		new_name = "[alarm_area.name] Vent Pump #[alarm_area.air_vent_names.len+1]"
		alarm_area.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[alarm_area.name] Air Scrubber #[alarm_area.air_scrub_names.len+1]"
		alarm_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

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

/obj/machinery/alarm/proc/return_text()
	if(!(istype(usr, /mob/living/silicon)) && locked)
		return "<html><head><title>[src]</title></head><body>[return_status()]<hr><i>(Swipe ID card to unlock interface)</i></body></html>"
	else
		return "<html><head><title>[src]</title></head><body>[return_status()]<hr>[return_controls()]</body></html>"

/obj/machinery/alarm/proc/return_status()
	var/turf/location = src.loc
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.oxygen + environment.carbon_dioxide + environment.toxins + environment.nitrogen
	var/output = "<b>Air Status:</b><br>"

	if(total == 0)
		output +={"<font color='red'><b>Warning: Cannot obtain air sample for analysis.</b></font>"}
		return output

	output += {"
<style>
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
"}
	var/datum/tlv/cur_tlv
	var/GET_PP = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["oxygen"]
	var/oxygen_dangerlevel = cur_tlv.get_danger_level(environment.oxygen*GET_PP)
	var/oxygen_percent = round(environment.oxygen / total * 100, 2)

	cur_tlv = TLV["carbon dioxide"]
	var/co2_dangerlevel = cur_tlv.get_danger_level(environment.carbon_dioxide*GET_PP)
	var/co2_percent = round(environment.carbon_dioxide / total * 100, 2)

	cur_tlv = TLV["plasma"]
	var/plasma_dangerlevel = cur_tlv.get_danger_level(environment.toxins*GET_PP)
	var/plasma_percent = round(environment.toxins / total * 100, 2)

	cur_tlv = TLV["other"]
	var/other_moles = 0.0
	for(var/datum/gas/G in environment.trace_gases)
		other_moles+=G.moles
	var/other_dangerlevel = cur_tlv.get_danger_level(other_moles*GET_PP)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	output += {"
Pressure: <span class='dl[pressure_dangerlevel]'>[environment_pressure]</span>kPa<br>
Oxygen: <span class='dl[oxygen_dangerlevel]'>[oxygen_percent]</span>%<br>
Carbon dioxide: <span class='dl[co2_dangerlevel]'>[co2_percent]</span>%<br>
Toxins: <span class='dl[plasma_dangerlevel]'>[plasma_percent]</span>%<br>
"}
	if (other_dangerlevel==2)
		output += {"Notice: <span class='dl2'>High Concentration of Unknown Particles Detected</span><br>"}
	else if (other_dangerlevel==1)
		output += {"Notice: <span class='dl1'>Low Concentration of Unknown Particles Detected</span><br>"}

	output += {"
Temperature: <span class='dl[temperature_dangerlevel]'>[environment.temperature]</span>K<br>
"}

	var/display_danger_level = max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		co2_dangerlevel,
		plasma_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
	)

	//Overall status
	output += {"Local Status: "}
	if(display_danger_level == 2)
		output += {"<span class='dl2'>DANGER: Internals Required</span>"}
	else if(display_danger_level == 1)
		output += {"<span class='dl1'>Caution</span>"}
	else if (alarm_area.atmosalm)
		output += {"<span class='dl1'>Caution: Atmos alert in area</span>"}
	else
		output += {"<span class='dl0'>Optimal</span>"}

	return output

/obj/machinery/alarm/proc/rcon_text()
	var/dat = "<b>Remote Control:</b><br>"
	if(src.rcon_setting == RCON_NO)
		dat += "Off"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_NO]'>Off</a>"
	dat += " | "
	if(src.rcon_setting == RCON_AUTO)
		dat += "Auto"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_AUTO]'>Auto</a>"
	dat += " | "
	if(src.rcon_setting == RCON_YES)
		dat += "On"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_YES]'>On</a>"
	return dat

/obj/machinery/alarm/proc/return_controls()
	var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

	switch(screen)
		if (AALARM_SCREEN_MAIN)
			if(alarm_area.atmosalm)
				output += {"<a href='?src=\ref[src];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"}
			else
				output += {"<a href='?src=\ref[src];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"}

			output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MODE]'>Set envirenomentals mode</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SENSORS]'>Sensor Control</a><br>
<HR>
"}
			if (mode==AALARM_MODE_PANIC)
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];mode=[AALARM_MODE_OFF]'>turn syphoning off</A>"
			else
				output += "<A href='?src=\ref[src];mode=[AALARM_MODE_PANIC]'><font color='red'><B>ACTIVATE PANIC SYPHON IN AREA</B></font></A>"
		if (AALARM_SCREEN_VENT)
			var/sensor_data = ""
			if(alarm_area.air_vent_names.len)
				for(var/id_tag in alarm_area.air_vent_names)
					var/long_name = alarm_area.air_vent_names[id_tag]
					var/list/data = alarm_area.air_vent_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"]+AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"
					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A>
<BR>
<B>Pressure checks:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=checks;val=[data["checks"]^1]' [(data["checks"]&1)?"style='font-weight:bold;'":""]>external</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=checks;val=[data["checks"]^2]' [(data["checks"]&2)?"style='font-weight:bold;'":""]>internal</A>
<BR>
<B>External pressure bound:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-1000'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-100'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-10'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-1'>-</A>
[data["external"]]
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+1'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+10'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+100'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+1000'>+</A>
<BR>
"}
					if (data["direction"] == "siphon")
						sensor_data += {"
<B>Direction:</B>
siphoning
<BR>
"}
					sensor_data += {"<HR>"}
			else
				sensor_data = "No vents connected.<BR>"
			output = {"<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}
		if (AALARM_SCREEN_SCRUB)
			var/sensor_data = ""
			if(alarm_area.air_scrub_names.len)
				for(var/id_tag in alarm_area.air_scrub_names)
					var/long_name = alarm_area.air_scrub_names[id_tag]
					var/list/data = alarm_area.air_scrub_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"]+AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"

					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A><BR>
<B>Type:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=scrubbing;val=[!data["scrubbing"]]'>[data["scrubbing"]?"scrubbing":"syphoning"]</A><BR>
"}

					if(data["scrubbing"])
						sensor_data += {"
<B>Filtering:</B>
Carbon Dioxide
<A href='?src=\ref[src];id_tag=[id_tag];command=co2_scrub;val=[!data["filter_co2"]]'>[data["filter_co2"]?"on":"off"]</A>;
Toxins
<A href='?src=\ref[src];id_tag=[id_tag];command=tox_scrub;val=[!data["filter_toxins"]]'>[data["filter_toxins"]?"on":"off"]</A>;
Nitrous Oxide
<A href='?src=\ref[src];id_tag=[id_tag];command=n2o_scrub;val=[!data["filter_n2o"]]'>[data["filter_n2o"]?"on":"off"]</A>
<BR>
"}
					sensor_data += {"
<B>Panic syphon:</B> [data["panic"]?"<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>":""]
<A href='?src=\ref[src];id_tag=[id_tag];command=panic_siphon;val=[!data["panic"]]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate</font></A><BR>
<HR>
"}
			else
				sensor_data = "No scrubbers connected.<BR>"
			output = {"<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}

		if (AALARM_SCREEN_MODE)
			output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Air machinery mode for the area:</b><ul>"}
			var/list/modes = list(
				AALARM_MODE_SCRUBBING   = "Filtering",
				AALARM_MODE_VENTING     = "Draught",
				AALARM_MODE_PANIC       = "<font color='red'>PANIC</font>",
				AALARM_MODE_REPLACEMENT = "<font color='red'>REPLACE AIR</font>",
				AALARM_MODE_OFF         = "Off",
			)
			for (var/m=1,m<=modes.len,m++)
				if (mode==m)
					output += {"<li><A href='?src=\ref[src];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"}
				else
					output += {"<li><A href='?src=\ref[src];mode=[m]'>[modes[m]]</A></li>"}
			output += "</ul>"
		if (AALARM_SCREEN_SENSORS)
			output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Alarm thresholds:</b><br>
Partial pressure for gases
<style>/* some CSS woodoo here. Does not work perfect in ie6 but who cares? */
table td { border-left: 1px solid black; border-top: 1px solid black;}
table tr:first-child th { border-left: 1px solid black;}
table th:first-child { border-top: 1px solid black; font-weight: normal;}
table tr:first-child th:first-child { border: none;}
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
<table cellspacing=0>
<TR><th></th><th class=dl2>min2</th><th class=dl1>min1</th><th class=dl1>max1</th><th class=dl2>max2</th></TR>
"}
			var/list/gases = list(
				"oxygen"         = "O<sub>2</sub>",
				"carbon dioxide" = "CO<sub>2</sub>",
				"plasma"         = "Toxin",
				"other"          = "Other",
			)
			var/list/thresholds = list("min2", "min1", "max1", "max2")
			var/datum/tlv/tlv
			for (var/g in gases)
				output += {"
<TR><th>[gases[g]]</th>
"}
				tlv = TLV[g]
				for (var/v in thresholds)
					output += {"
<td>
<A href='?src=\ref[src];command=set_threshold;env=[g];var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
				output += {"
</TR>
"}
			tlv = TLV["pressure"]
			output += {"
<TR><th>Pressure</th>
"}
			for (var/v in thresholds)
				output += {"
<td>
<A href='?src=\ref[src];command=set_threshold;env=pressure;var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
			output += {"
</TR>
"}
			tlv = TLV["temperature"]
			output += {"
<TR><th>Temperature</th>
"}
			for (var/v in thresholds)
				output += {"
<td>
<A href='?src=\ref[src];command=set_threshold;env=temperature;var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
			output += {"
</TR>
"}
			output += {"</table>"}

	return output

/obj/machinery/alarm/Topic(href, href_list)
	if(..())
		return
	if(href_list["rcon"])
		rcon_setting = text2num(href_list["rcon"])
		src.updateUsrDialog()

	if ( (get_dist(src, usr) > 1 ))
		if (!istype(usr, /mob/living/silicon))
			usr.machine = null
			usr << browse(null, "window=air_alarm")

	if(href_list["command"])
		var/device_id = href_list["id_tag"]
		switch(href_list["command"])
			if(
				"power",
				"adjust_external_pressure",
				"checks",
				"co2_scrub",
				"tox_scrub",
				"n2o_scrub",
				"panic_siphon",
				"scrubbing"
			)
				send_signal(device_id, list (href_list["command"] = text2num(href_list["val"])))
				spawn(3)
					src.updateUsrDialog()
			//if("adjust_threshold") //was a good idea but required very wide window
			if("set_threshold")
				var/env = href_list["env"]
				var/varname = href_list["var"]
				var/datum/tlv/tlv = TLV[env]
				var/newval = input("Enter [varname] for env", "Alarm triggers", tlv.vars[varname]) as num|null
				if (isnull(newval) || ..() || (locked && issilicon(usr)))
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
		if (alarm_area.atmosalert(2))
			post_alert(2)
		spawn(1)
			src.updateUsrDialog()
		update_icon()
	if(href_list["atmos_reset"])
		if (alarm_area.atmosalert(0))
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
					"power"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
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

	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		if(RCON_AUTO)
			if(danger_level == 2)
				remote_control = 1
				rcon_time = 60
		if(RCON_YES)
			remote_control = 1
	if(rcon_time > 0)
		rcon_time--
	else if(rcon_setting == RCON_AUTO)
		remote_control = 0

	src.updateDialog()
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
		tension_master.new_air_alarm() //log this for stats purposes
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = 0
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				new_area_danger_level = max(new_area_danger_level,AA.danger_level)
	if (alarm_area.atmosalert(new_area_danger_level)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)
	update_icon()

/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
/*	if (istype(W, /obj/item/weapon/wirecutters))
		stat ^= BROKEN
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		update_icon()
		return
*/
	if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
		//user << "You pop the Air Alarm's maintence panel open."
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		update_icon()
		return

	if (wiresexposed && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))))
		return src.attack_hand(user)


	else if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
		if(stat & (NOPOWER|BROKEN))
			user << "It does nothing"
		else
			if(src.allowed(usr) && !isWireCut(AALARM_WIRE_IDSCAN))
				locked = !locked
				user << "\blue You [ locked ? "lock" : "unlock"] the Air Alarm interface."
				src.updateUsrDialog()
			else
				user << "\red Access denied."
		return
	return ..()

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
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

/obj/machinery/firealarm/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		src.detecting = !( src.detecting )
		if (src.detecting)
			user.visible_message("\red [user] has reconnected [src]'s detecting unit!", "You have reconnected [src]'s detecting unit.")
		else
			user.visible_message("\red [user] has disconnected [src]'s detecting unit!", "You have disconnected [src]'s detecting unit.")
	else
		src.alarm()
	src.add_fingerprint(user)
	return

/obj/machinery/firealarm/process()
	if(stat & (NOPOWER|BROKEN))
		return

	var/area/A = src.loc
	A = A.loc

	if(A.fire)
		src.icon_state = "fire1"
	else
		src.icon_state = "fire0"

	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "fire0"
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			icon_state = "firep"

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon))
		A = A.loc

		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> [d1]\n<HR>The current alert level is: [get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
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
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>[stars("Fire alarm")]</B> [d1]\n<HR><b>The current alert level is: [stars(get_security_level())]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	return

/obj/machinery/firealarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
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
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.firereset()
	return

/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.firealert()
	//playsound(src.loc, 'signal.ogg', 75, 0)
	return

/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)
/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=partyalarm")
		return
	return
