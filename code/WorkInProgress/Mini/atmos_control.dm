/obj/item/weapon/circuitboard/atmoscontrol
	name = "Central Atmospherics Computer Circuitboard"
	build_path = "/obj/machinery/computer/security/atmoscontrol"

/obj/machinery/computer/atmoscontrol
	name = "Central Atmospherics Computer"
	icon = 'computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 1.0
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	var/obj/machinery/alarm/current = ""

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	user.machine = src
	var/dat = "<a href='?src=\ref[src]&reset=1'>Main Menu</a><hr>"
	if(current)
		dat += src.specific()
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

/obj/machinery/computer/atmoscontrol/proc/specific()
	if(!current)
		return ""
	var/dat = "<h3>[current.name]</h3><hr>"
	dat += current.return_status()
	if(current.remote_control)
		dat += "<hr>[src.return_controls()]"
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
					var/varname = href_list["var"]
					var/datum/tlv/tlv = current.TLV[env]
					var/newval = input("Enter [varname] for env", "Alarm triggers", tlv.vars[varname]) as num|null
					if (isnull(newval) || ..() || (current.locked && issilicon(usr)))
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
			return

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			spawn(1)
				src.updateUsrDialog()
			return


		if(href_list["atmos_alarm"])
			if (current.alarm_area.atmosalert(2))
				current.post_alert(2)
			spawn(1)
				src.updateUsrDialog()
			current.update_icon()
			return
		if(href_list["atmos_reset"])
			if (current.alarm_area.atmosalert(0))
				current.post_alert(0)
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
#define AALARM_MODE_SCRUBBING    1
#define AALARM_MODE_VENTING      2 //makes draught
#define AALARM_MODE_PANIC        3 //constantly sucks all air
#define AALARM_MODE_REPLACEMENT  4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF          5

#define AALARM_SCREEN_MAIN    1
#define AALARM_SCREEN_VENT    2
#define AALARM_SCREEN_SCRUB   3
#define AALARM_SCREEN_MODE    4
#define AALARM_SCREEN_SENSORS 5

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
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_OFF]'>turn syphoning off</A>"
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
				AALARM_MODE_VENTING     = "Draught",
				AALARM_MODE_PANIC       = "<font color='red'>PANIC</font>",
				AALARM_MODE_REPLACEMENT = "<font color='red'>REPLACE AIR</font>",
				AALARM_MODE_OFF         = "Off",
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
			var/list/thresholds = list("min2", "min1", "max1", "max2")
			var/datum/tlv/tlv
			for (var/g in gases)
				output += {"
<TR><th>[gases[g]]</th>
"}
				tlv = current.TLV[g]
				for (var/v in thresholds)
					output += {"
<td>
<A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=[g];var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
				output += {"
</TR>
"}
			tlv = current.TLV["pressure"]
			output += {"
<TR><th>Pressure</th>
"}
			for (var/v in thresholds)
				output += {"
<td>
<A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=pressure;var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
			output += {"
</TR>
"}
			tlv = current.TLV["temperature"]
			output += {"
<TR><th>Temperature</th>
"}
			for (var/v in thresholds)
				output += {"
<td>
<A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=temperature;var=[v]'>[tlv.vars[v]>=0?tlv.vars[v]:"OFF"]</A>
</td>
"}
			output += {"
</TR>
"}
			output += {"</table>"}

	return output
//---END COPYPASTA----
