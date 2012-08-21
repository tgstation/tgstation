/obj/item/weapon/circuitboard/atmoscontrol
	name = "\improper Central Atmospherics Computer Circuitboard"
	build_path = "/obj/machinery/computer/security/atmoscontrol"

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current
	var/overridden = 0 //not set yet, can't think of a good way to do it
	req_access = list(access_ce)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	user.machine = src
	if(allowed(user))
		overridden = 1
	else if(!emagged)
		overridden = 0
	var/dat = "<a href='?src=\ref[src]&reset=1'>Main Menu</a><hr>"
	if(current)
		dat += specific()
	else
		for(var/obj/machinery/alarm/alarm in world)
			dat += "<a href='?src=\ref[src]&alarm=\ref[alarm]'>"
			switch(max(alarm.danger_level, alarm.alarm_area.atmosalm))
				if (0)
					dat += "<font color=blue>"
				if (1)
					dat += "<font color=yellow>"
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
		src.updateUsrDialog()
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
					spawn(1)
						updateUsrDialog()
			return

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			spawn(1)
				src.updateUsrDialog()
			return


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
		src.updateUsrDialog()

//copypasta from alarm code, changed to work with this without derping hard
//---START COPYPASTA----

/obj/machinery/computer/atmoscontrol/proc/return_controls()
	var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

	switch(current.screen)
		if (AALARM_SCREEN_MAIN)
			if(current.alarm_area.atmosalm)
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"}
			else
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"}

			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MODE]'>Set envirenomentals mode</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SENSORS]'>Sensor Control</a><br>
<HR>
"}
			if (current.mode==AALARM_MODE_PANIC)
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_SCRUBBING]'>turn syphoning off</A>"
			else
				output += "<A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_PANIC]'><font color='red'><B>ACTIVATE PANIC SYPHON IN AREA</B></font></A>"
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
Carbon Dioxide
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=co2_scrub;val=[!data["filter_co2"]]'>[data["filter_co2"]?"on":"off"]</A>;
Toxins
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=tox_scrub;val=[!data["filter_toxins"]]'>[data["filter_toxins"]?"on":"off"]</A>;
Nitrous Oxide
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=n2o_scrub;val=[!data["filter_n2o"]]'>[data["filter_n2o"]?"on":"off"]</A>
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
			var/list/modes = list(
					AALARM_MODE_SCRUBBING   = "Filtering",
					AALARM_MODE_REPLACEMENT = "<font color='red'>REPLACE AIR</font>",
					AALARM_MODE_PANIC       = "<font color='red'>PANIC</font>",
					AALARM_MODE_CYCLE		= "<font color='red'>CYCLE</font>",
					AALARM_MODE_FILL = "<font color='red'>FILL</font>",
			)
			for (var/m=1,m<=modes.len,m++)
				if (current.mode==m)
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"}
				else
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'>[modes[m]]</A></li>"}
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
			output += "</TR>"
			output += "</table>"

	return output
//---END COPYPASTA----
