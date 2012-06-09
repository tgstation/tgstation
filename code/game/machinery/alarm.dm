////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

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

#define AALARM_WIRE_IDSCAN		1	//Added wires
#define AALARM_WIRE_POWER		2
#define AALARM_WIRE_SYPHON		3
#define AALARM_WIRE_AI_CONTROL	4
#define AALARM_WIRE_AALARM		5

#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_PANIC		2 //constantly sucks all air
#define AALARM_MODE_REPLACEMENT	3 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_FILL		4 //emergency fill

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names
	var/list/air_scrub_names
	var/list/air_vent_info
	var/list/air_scrub_info

/obj/machinery/alarm
	name = "alarm"
	icon = 'monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(access_atmospherics, access_engine_equip)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 0
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = 1
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	var/mode = AALARM_MODE_SCRUBBING
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/danger_level = 0

	var/list/TLV = list()

	server/New()
		..()
		req_access = list(access_rd, access_engine_equip, access_atmospherics)
		TLV["oxygen"] =			list(-1.0, -1.0,-1.0,-1.0) // Partial pressure, kpa
		TLV["carbon dioxide"] = list(-1.0, -1.0,   5,  10) // Partial pressure, kpa
		TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
		TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
		TLV["pressure"] =		list(ONE_ATMOSPHERE*0.50,ONE_ATMOSPHERE*0.70,ONE_ATMOSPHERE*1.40,ONE_ATMOSPHERE*1.60) /* kpa */
		TLV["temperature"] =	list(40, 60, 100, 120) // K

	New()
		..()
		alarm_area = get_area(src)
		if (alarm_area.master)
			alarm_area = alarm_area.master
		area_uid = alarm_area.uid
		if (name == "alarm")
			name = "[alarm_area.name] Air Alarm"

		// breathable air according to human/Life()
		TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
		TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
		TLV["plasma"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
		TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
		TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
		TLV["temperature"] =	list(T0C, T0C+10, T0C+40, T0C+66) // K

	initialize()
		if (!master_is_operating())
			elect_master()


	process()
		if((stat & (NOPOWER|BROKEN)) || shorted)
			return

		var/turf/simulated/location = src.loc
		if (!istype(location))
			return 0

		var/datum/gas_mixture/environment = location.return_air()
		var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

		var/list/current_settings = TLV["pressure"]
		var/environment_pressure = environment.return_pressure()
		var/pressure_dangerlevel = get_danger_level(environment_pressure, current_settings)

		current_settings = TLV["oxygen"]
		var/oxygen_dangerlevel = get_danger_level(environment.oxygen*partial_pressure, current_settings)

		current_settings = TLV["carbon dioxide"]
		var/co2_dangerlevel = get_danger_level(environment.carbon_dioxide*partial_pressure, current_settings)

		current_settings = TLV["plasma"]
		var/plasma_dangerlevel = get_danger_level(environment.toxins*partial_pressure, current_settings)

		current_settings = TLV["other"]
		var/other_moles = 0.0
		for(var/datum/gas/G in environment.trace_gases)
			other_moles+=G.moles
		var/other_dangerlevel = get_danger_level(other_moles*partial_pressure, current_settings)

		current_settings = TLV["temperature"]
		var/temperature_dangerlevel = get_danger_level(environment.temperature, current_settings)

		var/old_danger_level = danger_level
		danger_level = max(pressure_dangerlevel,
			oxygen_dangerlevel,
			co2_dangerlevel,
			plasma_dangerlevel,
			other_dangerlevel,
			temperature_dangerlevel)


		if (old_danger_level != danger_level)
			apply_danger_level(danger_level)


		//atmos computer remote controll stuff
		switch(rcon_setting)
			if(RCON_NO)
				remote_control = 0
			if(RCON_AUTO)
				if(danger_level == 2)
					remote_control = 1
				else
					remote_control = 0
			if(RCON_YES)
				remote_control = 1

		updateDialog()
		return


	proc/master_is_operating()
		return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))


	proc/elect_master()
		for (var/area/A in alarm_area.related)
			for (var/obj/machinery/alarm/AA in A)
				if (!(AA.stat & (NOPOWER|BROKEN)))
					alarm_area.master_air_alarm = AA
					if (!alarm_area.air_vent_names)
						alarm_area.air_vent_names = list()
						alarm_area.air_scrub_names = list()
						alarm_area.air_vent_info = list()
						alarm_area.air_scrub_info = list()
					return 1
		return 0

	proc/get_danger_level(var/current_value, var/list/danger_levels)
		if(current_value >= danger_levels[4] || current_value <= danger_levels[1])
			return 2
		if(current_value >= danger_levels[3] || current_value <= danger_levels[2])
			return 1
		return 0

	update_icon()
		if(wiresexposed)
			icon_state = "alarmx"
			return
		if((stat & (NOPOWER|BROKEN)) || shorted)
			icon_state = "alarmp"
			return
		switch(max(danger_level, alarm_area.atmosalm))
			if (0)
				icon_state = "alarm0"
			if (1)
				icon_state = "alarm2" //yes, alarm2 is yellow alarm
			if (2)
				icon_state = "alarm1"

	proc/send_signal(var/target, var/list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data = command
		signal.data["tag"] = target
		signal.data["sigtype"] = "command"

		var/obj/machinery/target_machine = machines[target]
		target_machine.receive_signal(signal)

		return 1

	receive_signal(datum/signal/signal)
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

	proc/register_env_machine(var/m_id, var/device_type)
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

	proc/refresh_all()
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


	proc/apply_mode()
		var/current_pressures = TLV["pressure"]
		var/target_pressure = (current_pressures[2] + current_pressures[3])/2
		switch(mode)
			if(AALARM_MODE_SCRUBBING)
				for(var/device_id in alarm_area.air_scrub_names)
					send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "setting"= 1, "scrubbing"= 1, "panic_siphon"= 0) )
				for(var/device_id in alarm_area.air_vent_names)
					send_signal(device_id, list("power"= 1, "checks"= 1, "setting"= 1, "set_external_pressure"= target_pressure) )

			if(AALARM_MODE_PANIC)
				for(var/device_id in alarm_area.air_scrub_names)
					send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
				for(var/device_id in alarm_area.air_vent_names)
					send_signal(device_id, list("power"= 0) )

			if(AALARM_MODE_REPLACEMENT)
				for(var/device_id in alarm_area.air_scrub_names)
					send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "setting"= 2, "scrubbing"= 1, "panic_siphon"= 0) )
				for(var/device_id in alarm_area.air_vent_names)
					send_signal(device_id, list("power"= 1, "checks"= 1, "setting"= 2, "set_external_pressure"= target_pressure) )

			if(AALARM_MODE_FILL)
				for(var/device_id in alarm_area.air_scrub_names)
					send_signal(device_id, list("power"= 0) )
				for(var/device_id in alarm_area.air_vent_names)
					send_signal(device_id, list("power"= 1, "checks"= 1, "setting"= 2, "set_external_pressure"= target_pressure) )

	proc/apply_danger_level(var/new_danger_level)
		alarm_area.atmosalm = new_danger_level

		for (var/area/A in alarm_area.related)
			for (var/obj/machinery/alarm/AA in A)
				if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.danger_level != new_danger_level)
					AA.update_icon()

		if(danger_level > 2)
			air_doors_close(0)
		else
			air_doors_open(0)

		update_icon()

	proc/air_doors_close(manual)
		var/area/A = get_area(src)
		if(!A.master.air_doors_activated)
			A.master.air_doors_activated = 1
			for(var/obj/machinery/door/E in A.master.all_doors)
				if(istype(E,/obj/machinery/door/firedoor))
					if(!E:blocked)
						if(E.operating)
							E:nextstate = CLOSED
						else if(!E.density)
							spawn(0)
								E.close()
					continue
				if(istype(E, /obj/machinery/door/airlock))
					if((!E:arePowerSystemsOn()) || (E.stat & NOPOWER)) continue
					if(!E.density)
						spawn(0)
							E.close()
							sleep(10)
							if(E.density)
								E:air_locked = E.req_access
								E:req_access = list(access_engine, access_atmospherics)
								E.update_icon()
					if(E.operating)
						spawn(10)
							E.close()
							if(E.density)
								E:air_locked = E.req_access
								E:req_access = list(access_engine, access_atmospherics)
								E.update_icon()
					else if(!E:locked) //Don't lock already bolted doors.
						E:air_locked = E.req_access
						E:req_access = list(access_engine, access_atmospherics)
						E.update_icon()

	proc/air_doors_open(manual)
		var/area/A = get_area(loc)
		if(A.master.air_doors_activated)
			A.master.air_doors_activated = 0
			for(var/obj/machinery/door/E in A.master.all_doors)
				if(istype(E, /obj/machinery/door/firedoor))
					if(!E:blocked)
						if(E.operating)
							E:nextstate = OPEN
						else if(E.density)
							spawn(0)
								E.open()
					continue
				if(istype(E, /obj/machinery/door/airlock))
					if((!E:arePowerSystemsOn()) || (E.stat & NOPOWER)) continue
					if(E:air_locked) //Don't mess with doors locked for other reasons.
						if(E.density)
							E:req_access = E:air_locked
							E:air_locked = null
							E.update_icon()

///////////
//HACKING//
///////////
	proc/isWireColorCut(var/wireColor)
		var/wireFlag = AAlarmWireColorToFlag[wireColor]
		return ((AAlarmwires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = AAlarmIndexToFlag[wireIndex]
		return ((AAlarmwires & wireFlag) == 0)

	proc/cut(var/wireColor)
		var/wireFlag = AAlarmWireColorToFlag[wireColor]
		var/wireIndex = AAlarmWireColorToIndex[wireColor]
		AAlarmwires &= ~wireFlag
		switch(wireIndex)
			if(AALARM_WIRE_IDSCAN)
				locked = 1

			if(AALARM_WIRE_POWER)
				shock(usr, 50)
				shorted = 1
				update_icon()

			if (AALARM_WIRE_AI_CONTROL)
				if (aidisabled == 0)
					aidisabled = 1

			if(AALARM_WIRE_SYPHON)
				mode = AALARM_MODE_PANIC
				apply_mode()

			if(AALARM_WIRE_AALARM)

				if (alarm_area.atmosalert(2))
					apply_danger_level(2)
				spawn(1)
					updateUsrDialog()
				update_icon()

		updateDialog()

		return

	proc/mend(var/wireColor)
		var/wireFlag = AAlarmWireColorToFlag[wireColor]
		var/wireIndex = AAlarmWireColorToIndex[wireColor] //not used in this function
		AAlarmwires |= wireFlag
		switch(wireIndex)
			if(AALARM_WIRE_IDSCAN)

			if(AALARM_WIRE_POWER)
				src.shorted = 0
				src.shock(usr, 50)
				update_icon()

			if(AALARM_WIRE_AI_CONTROL)
				if (src.aidisabled == 1)
					src.aidisabled = 0

		src.updateDialog()
		return

	proc/pulse(var/wireColor)
		//var/wireFlag = AAlarmWireColorToFlag[wireColor] //not used in this function
		var/wireIndex = AAlarmWireColorToIndex[wireColor]
		switch(wireIndex)
			if(AALARM_WIRE_IDSCAN)			//unlocks for 30 seconds, if you have a better way to hack I'm all ears
				locked = 0
				spawn(300)
					locked = 1

			if (AALARM_WIRE_POWER)
				if(shorted == 0)
					shorted = 1
					update_icon()

				spawn(1200)
					if(shorted == 1)
						shorted = 0
						update_icon()


			if (AALARM_WIRE_AI_CONTROL)
				if (aidisabled == 0)
					aidisabled = 1
				updateDialog()
				spawn(10)
					if (aidisabled == 1)
						aidisabled = 0
					updateDialog()

			if(AALARM_WIRE_SYPHON)
				mode = AALARM_MODE_REPLACEMENT
				apply_mode()

			if(AALARM_WIRE_AALARM)
				if (alarm_area.atmosalert(0))
					apply_danger_level(0)
				spawn(1)
					updateUsrDialog()
				update_icon()

		updateDialog()
		return

	proc/shock(mob/user, prb)
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
///////////////
//END HACKING//
///////////////


	attack_hand(mob/user)
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


			else if (istype(user, /mob/living/silicon) && aidisabled)
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
				var/is_uncut = AAlarmwires & AAlarmWireColorToFlag[AAlarmwires[wiredesc]]
				t1 += "[wiredesc] wire: "
				if(!is_uncut)
					t1 += "<a href='?src=\ref[src];AAlarmwires=[AAlarmwires[wiredesc]]'>Mend</a>"

				else
					t1 += "<a href='?src=\ref[src];AAlarmwires=[AAlarmwires[wiredesc]]'>Cut</a> "
					t1 += "<a href='?src=\ref[src];pulse=[AAlarmwires[wiredesc]]'>Pulse</a> "

				t1 += "<br>"
			t1 += text("<br>\n[(locked ? "The Air Alarm is locked." : "The Air Alarm is unlocked.")]<br>\n[((shorted || (stat & (NOPOWER|BROKEN))) ? "The Air Alarm is offline." : "The Air Alarm is working properly!")]<br>\n[(aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
			t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p></body></html>")
			user << browse(t1, "window=AAlarmwires")
			onclose(user, "AAlarmwires")

		if(!shorted)
			user << browse(return_text(user),"window=air_alarm")
			onclose(user, "air_alarm")
			refresh_all()

		return

	proc/return_text(mob/user)
		if(!(istype(user, /mob/living/silicon)) && locked)
			return "<html><head><title>\The [src]</title></head><body>[return_status()]<hr>[rcon_text()]<hr><i>(Swipe ID card to unlock interface)</i></body></html>"
		else
			return "<html><head><title>\The [src]</title></head><body>[return_status()]<hr>[rcon_text()]<hr>[return_controls()]</body></html>"

	proc/return_status()
		var/turf/location = get_turf(src)
		var/datum/gas_mixture/environment = location.return_air()
		var/total = environment.oxygen + environment.carbon_dioxide + environment.toxins + environment.nitrogen
		var/output = "<b>Air Status:</b><br>"

		if(total == 0)
			output += "<font color='red'><b>Warning: Cannot obtain air sample for analysis.</b></font>"
			return output

		output += {"
<style>
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
"}

		var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume

		var/list/current_settings = TLV["pressure"]
		var/environment_pressure = environment.return_pressure()
		var/pressure_dangerlevel = get_danger_level(environment_pressure, current_settings)

		current_settings = TLV["oxygen"]
		var/oxygen_dangerlevel = get_danger_level(environment.oxygen*partial_pressure, current_settings)
		var/oxygen_percent = round(environment.oxygen / total * 100, 2)

		current_settings = TLV["carbon dioxide"]
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

		output += {"
Pressure: <span class='dl[pressure_dangerlevel]'>[environment_pressure]</span>kPa<br>
Oxygen: <span class='dl[oxygen_dangerlevel]'>[oxygen_percent]</span>%<br>
Carbon dioxide: <span class='dl[co2_dangerlevel]'>[co2_percent]</span>%<br>
Toxins: <span class='dl[plasma_dangerlevel]'>[plasma_percent]</span>%<br>
"}
		if (other_dangerlevel==2)
			output += "Notice: <span class='dl2'>High Concentration of Unknown Particles Detected</span><br>"
		else if (other_dangerlevel==1)
			output += "Notice: <span class='dl1'>Low Concentration of Unknown Particles Detected</span><br>"

		output += "Temperature: <span class='dl[temperature_dangerlevel]'>[environment.temperature]</span>K<br>"

		//Overall status
		output += "Local Status: "
		switch(max(pressure_dangerlevel,oxygen_dangerlevel,co2_dangerlevel,plasma_dangerlevel,other_dangerlevel,temperature_dangerlevel))
			if(2)
				output += "<span class='dl2'>DANGER: Internals Required</span>"
			if(1)
				output += "<span class='dl1'>Caution</span>"
			if(0)
				if(alarm_area.atmosalm)
					output += {"<span class='dl1'>Caution: Atmos alert in area</span>"}
				else
					output += {"<span class='dl0'>Optimal</span>"}

		return output

	proc/rcon_text()
		var/dat = "<b>Remote Control:</b><br>"
		if(rcon_setting == RCON_NO)
			dat += "<b>Off</b>"
		else
			dat += "<a href='?src=\ref[src];rcon=[RCON_NO]'>Off</a>"
		dat += " | "
		if(rcon_setting == RCON_AUTO)
			dat += "<b>Auto</b>"
		else
			dat += "<a href='?src=\ref[src];rcon=[RCON_AUTO]'>Auto</a>"
		dat += " | "
		if(rcon_setting == RCON_YES)
			dat += "<b>On</b>"
		else
			dat += "<a href='?src=\ref[src];rcon=[RCON_YES]'>On</a>"
		return dat

	proc/return_controls()
		var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

		switch(screen)
			if (AALARM_SCREEN_MAIN)
				if(alarm_area.atmosalm)
					output += "<a href='?src=\ref[src];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"
				else
					output += "<a href='?src=\ref[src];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"

				output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MODE]'>Set environmentals mode</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SENSORS]'>Sensor Settings</a><br>
<HR>
"}
				if (mode==AALARM_MODE_PANIC)
					output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];mode=[AALARM_MODE_SCRUBBING]'>Turn syphoning off</A>"
				else
					output += "<A href='?src=\ref[src];mode=[AALARM_MODE_PANIC]'><font color='red'>ACTIVATE PANIC SYPHON IN AREA</font></A>"


			if (AALARM_SCREEN_VENT)
				var/sensor_data = ""
				if(alarm_area.air_vent_names.len)
					for(var/id_tag in alarm_area.air_vent_names)
						var/long_name = alarm_area.air_vent_names[id_tag]
						var/list/data = alarm_area.air_vent_info[id_tag]
						if(!data)
							continue;

						sensor_data += {"
<B>[long_name]</B><BR>
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
<A href='?src=\ref[src];id_tag=[id_tag];command=set_external_pressure;val=[ONE_ATMOSPHERE]'> (reset) </A>
<BR>"}
						if (data["direction"] == "siphon")
							sensor_data += {"
<B>Direction:</B>
siphoning
<BR>
"}
						sensor_data += {"<HR>"}
				else
					sensor_data = "No vents connected.<BR>"
				output = "<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"


			if (AALARM_SCREEN_SCRUB)
				var/sensor_data = ""
				if(alarm_area.air_scrub_names.len)
					for(var/id_tag in alarm_area.air_scrub_names)
						var/long_name = alarm_area.air_scrub_names[id_tag]
						var/list/data = alarm_area.air_scrub_info[id_tag]
						if(!data)
							continue

						sensor_data += {"
<B>[long_name]</B><BR>
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
<B>Panic syphon:</B> [data["panic"]?"<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>":"Disabled"]
<A href='?src=\ref[src];id_tag=[id_tag];command=panic_siphon;val=[!data["panic"]]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate</font></A><BR>
<HR>
"}
				else
					sensor_data = "No scrubbers connected.<BR>"
				output = {"<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}


			if (AALARM_SCREEN_MODE)
				output += "<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br><b>Air machinery mode for the area:</b><ul>"
				var/list/modes = list(
					AALARM_MODE_SCRUBBING   = "Filtering",
					AALARM_MODE_PANIC       = "<font color='red'>PANIC</font>",
					AALARM_MODE_REPLACEMENT = "<font color='red'>REPLACE AIR</font>",
					AALARM_MODE_FILL = "<font color='red'>FILL</font>"
				)
				for (var/m=1, m<=modes.len, m++)
					if (mode==m)
						output += "<li><A href='?src=\ref[src];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"
					else
						output += "<li><A href='?src=\ref[src];mode=[m]'>[modes[m]]</A></li>"
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
					"other"          = "Other",)

				var/list/selected
				for (var/g in gases)
					output += "<TR><th>[gases[g]]</th>"
					selected = TLV[g]
					for(var/i = 1, i <= 4, i++)
						output += "<td><A href='?src=\ref[src];command=set_threshold;env=[g];var=[i]'>[selected[i] ? selected[i] :"OFF"]</A></td>"
					output += "</TR>"

				selected = TLV["pressure"]
				output += "	<TR><th>Pressure</th>"
				for(var/i = 1, i <= 4, i++)
					output += "<td><A href='?src=\ref[src];command=set_threshold;env=pressure;var=[i]'>[selected[i] ? selected[i] :"OFF"]</A></td>"
				output += "</TR>"

				selected = TLV["temperature"]
				output += "<TR><th>Temperature</th>"
				for(var/i = 1, i <= 4, i++)
					output += "<td><A href='?src=\ref[src];command=set_threshold;env=temperature;var=[i]'>[selected[i] ? selected[i] :"OFF"]</A></td>"
				output += "</TR></table>"

		return output

	Topic(href, href_list)

		if(href_list["rcon"])
			rcon_setting = text2num(href_list["rcon"])

		if ( (get_dist(src, usr) > 1 ))
			if (!istype(usr, /mob/living/silicon))
				usr.machine = null
				usr << browse(null, "window=air_alarm")
				usr << browse(null, "window=AAlarmwires")
				return

		add_fingerprint(usr)
		usr.machine = src

		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if(
					"power",
					"adjust_external_pressure",
					"set_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"panic_siphon",
					"scrubbing")

					send_signal(device_id, list(href_list["command"] = text2num(href_list["val"]) ) )

				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as null|num
					if (isnull(newval) || ..() || (locked && issilicon(usr)))
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

		if(href_list["screen"])
			screen = text2num(href_list["screen"])

		if(href_list["atmos_alarm"])
			if (alarm_area.atmosalert(2))
				apply_danger_level(2)
			update_icon()

		if(href_list["atmos_reset"])
			if (alarm_area.atmosalert(0))
				apply_danger_level(0)
			update_icon()

		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			apply_mode()

		if (href_list["AAlarmwires"])
			var/t1 = text2num(href_list["AAlarmwires"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (isWireColorCut(t1))
				mend(t1)
			else
				cut(t1)

		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				pulse(t1)

		updateUsrDialog()


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
		return attack_hand(user)


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
	if (!working)
		return
	var/area/A = get_area(src)
	if(network)
		for(var/obj/machinery/door/firedoor/D in world)
			if(!D.blocked && D.net_id == src.network)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					spawn(0)
						D.close()
	else
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
	if(network)
		for(var/obj/machinery/door/firedoor/D in world)
			if(!D.blocked && D.net_id == src.network)
				if(D.operating)
					D.nextstate = OPEN
				else if(!D.density)
					spawn(0)
						D.open()
	else
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
