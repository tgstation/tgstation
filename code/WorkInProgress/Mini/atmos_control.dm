/obj/item/weapon/circuitboard/atmoscontrol
	name = "\improper Central Atmospherics Computer Circuitboard"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current
	var/list/filter=null
	var/overridden = 0 //not set yet, can't think of a good way to do it
	req_one_access = list(access_ce)


/obj/machinery/computer/atmoscontrol/xeno
	name = "\improper Xenobiology Atmospherics Computer"
	filter=list(
		/area/toxins/xenobiology/specimen_1,
		/area/toxins/xenobiology/specimen_2,
		/area/toxins/xenobiology/specimen_3,
		/area/toxins/xenobiology/specimen_4,
		/area/toxins/xenobiology/specimen_5,
		/area/toxins/xenobiology/specimen_6)
	req_one_access = list(access_xenobiology,access_ce)


/obj/machinery/computer/atmoscontrol/gas_chamber
	name = "\improper Gas Chamber Atmospherics Computer"
	filter=list(
		/area/security/gas_chamber)
	req_one_access = list(access_ce,access_hos)


/obj/machinery/computer/atmoscontrol/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_paw(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	return interact(user)

/obj/machinery/computer/atmoscontrol/interact(mob/user)
	user.set_machine(src)
	if(allowed(user))
		overridden = 1
	else if(!emagged)
		overridden = 0
	var/dat = "<a href='?src=\ref[src]&reset=1'>Main Menu</a><hr>"
	if(current)
		dat += specific()
	else
		for(var/obj/machinery/alarm/alarm in sortAtom(machines))
			if(!is_in_filter(alarm.alarm_area.type))
				continue // NO ACCESS 4 U
			dat += "<a href='?src=\ref[src]&alarm=\ref[alarm]'>"
			switch(max(alarm.danger_level, alarm.alarm_area.atmosalm))
				if (0)
					dat += "<font color=green>"
				if (1)
					dat += "<font color=blue>"
				if (2)
					dat += "<font color=red>"
			dat += "[alarm]</font></a><br/>"
	user << browse(dat, "window=atmoscontrol")

/obj/machinery/computer/atmoscontrol/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		user.visible_message("\red \The [user] swipes \a [I] through \the [src], causing the screen to flash!",\
			"\red You swipe your [I] through \the [src], the screen flashing as you gain full control.",\
			"You hear the swipe of a card through a reader, and an electronic warble.")
		emagged = 1
		overridden = 1
		return
	return ..()


/obj/machinery/computer/atmoscontrol/proc/is_in_filter(var/typepath)
	if(!filter) return 1 // YEP.  TOTALLY.
	return typepath in filter

/obj/machinery/computer/atmoscontrol/proc/specific()
	if(!current)
		return ""
	var/dat = "<h3>[current.name]</h3><hr>"
	dat += current.return_status()
	if(current.remote_control || overridden)
		dat += "<hr>[return_controls()]"
	return dat

//a bunch of this is copied from atmos alarms
/obj/machinery/computer/atmoscontrol/Topic(href, href_list)
	if(..())
		return
	if(href_list["reset"])
		current = null
	if(href_list["alarm"])
		current = locate(href_list["alarm"])
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
					"o2_scrub",
					"panic_siphon",
					"scrubbing"
				)
					current.send_signal(device_id, list (href_list["command"] = text2num(href_list["val"])))
					spawn(3)
						src.updateUsrDialog()
				//if("adjust_threshold") //was a good idea but required very wide window
				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = current.TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null
					if (isnull(newval) || ..() || (current.locked && issilicon(usr)))
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

					//Sets the temperature the built-in heater/cooler tries to maintain.
					if(env == "temperature")
						if(current.target_temperature < selected[2])
							current.target_temperature = selected[2]
						if(current.target_temperature > selected[3])
							current.target_temperature = selected[3]

					spawn(1)
						updateUsrDialog()
			return

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			spawn(1)
				src.updateUsrDialog()
			return

		if(href_list["atmos_unlock"])
			switch(href_list["atmos_unlock"])
				if("0")
					current.air_doors_close(1)
				if("1")
					current.air_doors_open(1)

		if(href_list["atmos_alarm"])
			if (current.alarm_area.atmosalert(2))
				current.apply_danger_level(2)
			spawn(1)
				src.updateUsrDialog()
			current.update_icon()
			return
		if(href_list["atmos_reset"])
			if (current.alarm_area.atmosalert(0))
				current.apply_danger_level(0)
			spawn(1)
				src.updateUsrDialog()
			current.update_icon()
			return

		if(href_list["mode"])
			current.mode = text2num(href_list["mode"])
			current.apply_mode()
			spawn(5)
				src.updateUsrDialog()
			return

		if(href_list["preset"])
			current.preset = text2num(href_list["preset"])
			current.apply_preset()
			spawn(5)
				src.updateUsrDialog()
			return

		if(href_list["temperature"])
			var/list/selected = current.TLV["temperature"]
			var/max_temperature = min(selected[3] - T0C, MAX_TEMPERATURE)
			var/min_temperature = max(selected[2] - T0C, MIN_TEMPERATURE)
			var/input_temperature = input("What temperature would you like the system to mantain? (Capped between [min_temperature]C and [max_temperature]C)", "Thermostat Controls") as num|null
			if(input_temperature==null)
				return
			if(input_temperature > max_temperature || input_temperature < min_temperature)
				usr << "Temperature must be between [min_temperature]C and [max_temperature]C"
			else
				current.target_temperature = input_temperature + T0C
			return
	updateUsrDialog()

//copypasta from alarm code, changed to work with this without derping hard
//---START COPYPASTA----
/obj/machinery/computer/atmoscontrol/proc/fmtScrubberGasStatus(var/id_tag,var/code,var/list/data)
	var/label=replacetext(uppertext(code),"2","<sub>2</sub>")
	if(code=="tox")
		label="Plasma"
	return "<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=[code]_scrub;val=[!data["filter_"+code]]' class='scrub[data["filter_"+code]]'>[label]</A>"

/obj/machinery/computer/atmoscontrol/proc/return_controls()
	var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

	switch(current.screen)
		if (AALARM_SCREEN_MAIN)
			output += "<table width=\"100%\"><td align=\"center\"><b>Thermostat:</b><br><a href='?src=\ref[src];alarm=\ref[current];temperature=1'>[current.target_temperature - T0C]C</a></td></table>"
			if(current.alarm_area.atmosalm)
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"}
			else
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"}

			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MODE]'>Set environmental mode</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SENSORS]'>Sensor Control</a><br>
<HR>
"}
			if (current.mode==AALARM_MODE_PANIC)
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_SCRUBBING]'>turn syphoning off</A>"
			else
				output += "<A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_PANIC]'><font color='red'><B>ACTIVATE PANIC SYPHON IN AREA</B></font></A>"

			//output += "<br><br>Atmospheric Lockdown: <a href='?src=\ref[src];alarm=\ref[current];atmos_unlock=[current.alarm_area.air_doors_activated]'>[current.alarm_area.air_doors_activated ? "<b>ENABLED</b>" : "Disabled"]</a>"
		if (AALARM_SCREEN_VENT)
			var/sensor_data = ""
			if(current.alarm_area.air_vent_names.len)
				for(var/id_tag in current.alarm_area.air_vent_names)
					var/long_name = current.alarm_area.air_vent_names[id_tag]
					var/list/data = current.alarm_area.air_vent_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"]+AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"
					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A>
<BR>
<B>Pressure checks:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=checks;val=[data["checks"]^1]' [(data["checks"]&1)?"style='font-weight:bold;'":""]>external</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=checks;val=[data["checks"]^2]' [(data["checks"]&2)?"style='font-weight:bold;'":""]>internal</A>
<BR>
<B>External pressure bound:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-1000'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-100'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-10'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-1'>-</A>
[data["external"]]
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+1'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+10'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+100'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+1000'>+</A>
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
			output = {"<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}
		if (AALARM_SCREEN_SCRUB)
			var/sensor_data = ""
			if(current.alarm_area.air_scrub_names.len)
				for(var/id_tag in current.alarm_area.air_scrub_names)
					var/long_name = current.alarm_area.air_scrub_names[id_tag]
					var/list/data = current.alarm_area.air_scrub_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"]+AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"

					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A><BR>
<B>Type:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=scrubbing;val=[!data["scrubbing"]]'>[data["scrubbing"]?"scrubbing":"syphoning"]</A><BR>
"}

					if(data["scrubbing"])
						sensor_data += {"
<B>Filtering:</B>
[fmtScrubberGasStatus(id_tag,"co2",data)],
[fmtScrubberGasStatus(id_tag,"tox",data)],
[fmtScrubberGasStatus(id_tag,"n2o",data)],
[fmtScrubberGasStatus(id_tag,"o2",data)]
<BR>
"}
					sensor_data += {"
<B>Panic syphon:</B> [data["panic"]?"<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>":""]
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=panic_siphon;val=[!data["panic"]]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate</font></A><BR>
<HR>
"}
			else
				sensor_data = "No scrubbers connected.<BR>"
			output = {"<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}

		if (AALARM_SCREEN_MODE)
			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Air machinery mode for the area:</b><ul>"}
			var/list/modes = list(AALARM_MODE_SCRUBBING   = "Filtering - Scrubs out contaminants",\
					AALARM_MODE_REPLACEMENT = "<font color='blue'>Replace Air - Siphons out air while replacing</font>",\
					AALARM_MODE_PANIC       = "<font color='red'>Panic - Siphons air out of the room</font>",\
					AALARM_MODE_CYCLE       = "<font color='red'>Cycle - Siphons air before replacing</font>",\
					AALARM_MODE_FILL        = "<font color='green'>Fill - Shuts off scrubbers and opens vents</font>",\
					AALARM_MODE_OFF         = "<font color='blue'>Off - Shuts off vents and scrubbers</font>",)
			for (var/m=1,m<=modes.len,m++)
				if (current.mode==m)
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"}
				else
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'>[modes[m]]</A></li>"}
			output += {"</ul>
<hr><br><b>Sensor presets:</b><br><i>(Note, this only sets sensors, air supplied to vents must still be changed.)</i><ul>"}
			var/list/presets = list(
				AALARM_PRESET_HUMAN   = "Human - Checks for Oxygen and Nitrogen",\
				AALARM_PRESET_VOX 	= "Vox - Checks for Nitrogen only",\
				AALARM_PRESET_SERVER 	= "Coldroom - For server rooms and freezers")
			for(var/p=1;p<=presets.len;p++)
				if (current.preset==p)
					output += "<li><A href='?src=\ref[src];alarm=\ref[current];preset=[p]'><b>[presets[p]]</b></A> (selected)</li>"
				else
					output += "<li><A href='?src=\ref[src];alarm=\ref[current];preset=[p]'>[presets[p]]</A></li>"
			output += "</ul>"
		if (AALARM_SCREEN_SENSORS)
			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
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
			var/list/tlv
			for (var/g in gases)
				output += "<TR><th>[gases[g]]</th>"
				tlv = current.TLV[g]
				for (var/i = 1, i <= 4, i++)
					output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=[g];var=[i]'>[tlv[i] >= 0?tlv[i]:"OFF"]</A></td>"
				output += "</TR>"

			tlv = current.TLV["pressure"]
			output += "<TR><th>Pressure</th>"
			for (var/i = 1, i <= 4, i++)
				output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=pressure;var=[i]'>[tlv[i]>= 0?tlv[i]:"OFF"]</A></td>"
			output += "</TR>"

			tlv = current.TLV["temperature"]
			output += "<TR><th>Temperature</th>"
			for (var/i = 1, i <= 4, i++)
				output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=temperature;var=[i]'>[tlv[i]>= 0?tlv[i]:"OFF"]</A></td>"

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Mini\atmos_control.dm:357: output += "</TR>"
			output += {"</TR>
				</table>"}
			// END AUTOFIX
	return output
//---END COPYPASTA----
