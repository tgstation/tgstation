/obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	name = "Gas Sensor"

	anchored = 1

	var/id_tag
	var/frequency = 1439

	var/on = 1
	var/output = 3
	//Flags:
	// 1 for pressure
	// 2 for temperature
	// Output >= 4 includes gas composition
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for nitrogen concentration
	// 32 for carbon dioxide concentration

	machine_flags = WRENCHMOVE | MULTITOOL_MENU

	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/update_icon()
	icon_state = "gsensor[on]"

/obj/machinery/air_sensor/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
		<li>Monitor Pressure: <a href="?src=\ref[src];toggle_out_flag=1">[output&1 ? "Yes" : "No"]</a>
		<li>Monitor Temperature: <a href="?src=\ref[src];toggle_out_flag=2">[output&2 ? "Yes" : "No"]</a>
		<li>Monitor Oxygen Concentration: <a href="?src=\ref[src];toggle_out_flag=4">[output&4 ? "Yes" : "No"]</a>
		<li>Monitor Plasma Concentration: <a href="?src=\ref[src];toggle_out_flag=8">[output&8 ? "Yes" : "No"]</a>
		<li>Monitor Nitrogen Concentration: <a href="?src=\ref[src];toggle_out_flag=16">[output&16 ? "Yes" : "No"]</a>
		<li>Monitor Carbon Dioxide Concentration: <a href="?src=\ref[src];toggle_out_flag=32">[output&32 ? "Yes" : "No"]</a>
	</ul>"}

/obj/machinery/air_sensor/multitool_topic(var/mob/user, var/list/href_list, var/obj/item/device/multitool/P)
	. = ..()
	if(.)
		return .

	if("toggle_out_flag" in href_list)
		var/bitflag_value = text2num(href_list["toggle_out_flag"])//this is a string normally
		if(!test_bitflag(bitflag_value) && bitflag_value <= 32) //Here to prevent breaking the sensors with HREF exploits
			return 0
		if(output&bitflag_value)//the bitflag is on ATM
			output &= ~bitflag_value
		else//can't not be off
			output |= bitflag_value
		return MT_UPDATE

/obj/machinery/air_sensor/attackby(var/obj/item/W as obj, var/mob/user as mob)
	return ..()

/obj/machinery/air_sensor/process()
	if(on)
		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		var/datum/gas_mixture/air_sample = return_air()

		if(output&1)
			// Fucking why do we need num2text
			//signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1),)
			signal.data["pressure"] =round(air_sample.return_pressure(),0.1)
		if(output&2)
			signal.data["temperature"] = round(air_sample.temperature,0.1)

		if(output>4)
			var/total_moles = air_sample.total_moles()
			if(total_moles > 0)
				if(output&4)
					signal.data["oxygen"] = round(100*air_sample.oxygen/total_moles,0.1)
				if(output&8)
					signal.data["toxins"] = round(100*air_sample.toxins/total_moles,0.1)
				if(output&16)
					signal.data["nitrogen"] = round(100*air_sample.nitrogen/total_moles,0.1)
				if(output&32)
					signal.data["carbon_dioxide"] = round(100*air_sample.carbon_dioxide/total_moles,0.1)
			else
				signal.data["oxygen"] = 0
				signal.data["toxins"] = 0
				signal.data["nitrogen"] = 0
				signal.data["carbon_dioxide"] = 0
		signal.data["sigtype"]="status"
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/initialize()
	set_frequency(frequency)

/obj/machinery/air_sensor/New()
	..()

	if(radio_controller)
		set_frequency(frequency)

/obj/machinery/computer/general_air_control
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"
	circuit = "/obj/item/weapon/circuitboard/air_management"

	name = "Computer"

	var/frequency = 1439
	var/show_sensors=1
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	if(..(user))
		return
	var/html=return_text()+"</body></html>"
	user << browse(html,"window=gac")
	user.set_machine(src)
	onclose(user, "gac")

/obj/machinery/computer/general_air_control/process()
	..()
	if(!sensors)
		warning("[src.type] at [x],[y],[z] has null sensors.  Please fix.")
		sensors = list()
	src.updateUsrDialog()

/obj/machinery/computer/general_air_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag || !sensors || !sensors.Find(id_tag)) return

	sensor_information[id_tag] = signal.data


/obj/machinery/computer/general_air_control/proc/return_text()
	var/sensor_data
	if(sensors.len)
		for(var/id_tag in sensors)
			var/long_name = sensors[id_tag]
			var/list/data = sensor_information[id_tag]
			var/sensor_part = "<fieldset><legend>[long_name]</legend>"

			if(data)
				sensor_part += "<table>"
				if("pressure" in data)
					sensor_part += "<tr><th>Pressure:</th><td>[data["pressure"]] kPa</td></tr>"
				if(data["temperature"])
					sensor_part += "<tr><th>Temperature:</th><td>[data["temperature"]] K</td></tr>"
				if(data["oxygen"]||data["toxins"]||data["nitrogen"]||data["carbon_dioxide"])
					sensor_part += "<tr><th>Gas Composition :</th><td><ul>"
					if(data["oxygen"])
						sensor_part += "<li>[data["oxygen"]]% O<sub>2</sub></li>"
					if(data["nitrogen"])
						sensor_part += "<li>[data["nitrogen"]]% N</li>"
					if(data["carbon_dioxide"])
						sensor_part += "<li>[data["carbon_dioxide"]]% CO<sub>2</sub></li>"
					if(data["toxins"])
						sensor_part += "<li>[data["toxins"]]% Plasma</li>"
					sensor_part += "</ul></td></tr>"
				sensor_part += "</table>"

			else
				sensor_part += "<FONT color='red'>[long_name] can not be found!</FONT><BR>"
			sensor_part += "</fieldset>"
			sensor_data += sensor_part

	else
		sensor_data = "<em>No sensors connected.</em>"

	var/output = {"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title>[name]</title>
	<style type="text/css">
html,body {
font-family:sans-serif,verdana;
font-size:smaller;
color:#666;
}
h1 {
border-bottom:1px solid maroon;
}
table {
border-spacing: 0;
border-collapse: collapse;
}
td, th {
margin: 0;
font-size: small;
border-bottom: 1px solid #ccc;
padding: 3px;
}

th {
text-align:right;
}

fieldset {
border:1px solid #ccc;
background: #efefef;
}
legend {
font-weight:bold;
}
	</style>
</head>
<body>
	<h1>[name]</h1>"}
	if(show_sensors)
		output += {"
	<h2>Sensor Data:</h2>
	[sensor_data]"}

	return output

/obj/machinery/computer/general_air_control/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/initialize()
	set_frequency(frequency)

/obj/machinery/computer/general_air_control/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat= {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
	</ul>
	<b>Sensors:</b>
	<ul>"}
	for(var/id_tag in sensors)
		dat += {"<li><a href="?src=\ref[src];edit_sensor=[id_tag]">[sensors[id_tag]]</a></li>"}
	dat += {"<li><a href="?src=\ref[src];add_sensor=1">\[+\]</a></li></ul>"}
	return dat

/obj/machinery/computer/general_air_control/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.) return .
	if("add_sensor" in href_list)

		// Make a list of all available sensors on the same frequency
		var/list/sensor_list = list()
		for(var/obj/machinery/air_sensor/G in machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		for(var/obj/machinery/meter/G in machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		if(!sensor_list.len)
			to_chat(user, "<span class=\"warning\">No sensors on this frequency.</span>")
			return MT_ERROR

		// Have the user pick one of them and name its label
		var/sensor = input(user, "Select a sensor:", "Sensor Data") as null|anything in sensor_list
		if(!sensor)
			return MT_ERROR
		var/label = reject_bad_name( input(user, "Choose a sensor label:", "Sensor Label")  as text|null, allow_numbers=1)
		if(!label)
			return MT_ERROR

		// Add the sensor's information to general_air_controler
		sensors[sensor] = label
		return MT_UPDATE

	if("edit_sensor" in href_list)
		var/list/sensor_list = list()
		for(var/obj/machinery/air_sensor/G in machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		for(var/obj/machinery/meter/G in machines)
			if(!isnull(G.id_tag) && G.frequency == frequency)
				sensor_list|=G.id_tag
		if(!sensor_list.len)
			to_chat(user, "<span class=\"warning\">No sensors on this frequency.</span>")
			return MT_ERROR
		var/label = sensors[href_list["edit_sensor"]]
		var/sensor = input(user, "Select a sensor:", "Sensor Data", href_list["edit_sensor"]) as null|anything in sensor_list
		if(!sensor)
			return MT_ERROR
		sensors.Remove(href_list["edit_sensor"])
		sensors[sensor] = label
		return MT_UPDATE

/obj/machinery/computer/general_air_control/unlinkFrom(var/mob/user, var/obj/O)
	..()
	if("id_tag" in O.vars && (istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter)))
		sensors.Remove(O:id_tag)
		return 1
	return 0

/obj/machinery/computer/general_air_control/linkMenu(var/obj/O)
	var/dat=""
	if((istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter)) && !isLinkedWith(O))
		dat += " <a href='?src=\ref[src];link=1'>\[New Sensor\]</a> "
	return dat

/obj/machinery/computer/general_air_control/canLink(var/obj/O, var/list/context)
	if(istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter))
		return O:id_tag

/obj/machinery/computer/general_air_control/isLinkedWith(var/obj/O)
	if(istype(O,/obj/machinery/air_sensor) || istype(O, /obj/machinery/meter))
		return O:id_tag in sensors

/obj/machinery/computer/general_air_control/linkWith(var/mob/user, var/obj/O, var/link/context)
	sensors[O:id_tag] = reject_bad_name(input(user, "Choose a sensor label:", "Sensor Label") as text|null, allow_numbers=1)
	return 1

/obj/machinery/computer/general_air_control/large_tank_control
		icon = 'icons/obj/computer.dmi'
		icon_state = "tank"
		circuit = "/obj/item/weapon/circuitboard/large_tank_control"

		var/input_tag
		var/output_tag

		var/list/input_info
		var/list/output_info

		var/list/input_linkable=list(
			/obj/machinery/atmospherics/unary/outlet_injector,
			/obj/machinery/atmospherics/unary/vent_pump
		)

		var/list/output_linkable=list(
			/obj/machinery/atmospherics/unary/vent_pump
		)

		var/pressure_setting = ONE_ATMOSPHERE * 45


/obj/machinery/computer/general_air_control/large_tank_control/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	var/dat= {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("Input","input_tag")]</li>
		<li>[format_tag("Output","output_tag")]</li>
	</ul>
	<b>Sensors:</b>
	<ul>"}
	for(var/id_tag in sensors)
		dat += {"<li><a href="?src=\ref[src];edit_sensor=[id_tag]">[sensors[id_tag]]</a></li>"}
	dat += {"<li><a href="?src=\ref[src];add_sensor=1">\[+\]</a></li></ul>"}
	return dat


/obj/machinery/computer/general_air_control/large_tank_control/linkWith(var/mob/user, var/obj/O, var/list/context)
	if(context["slot"]=="input" && is_type_in_list(O,input_linkable))
		input_tag = O:id_tag
		input_info = null
		if(istype(O,/obj/machinery/atmospherics/unary/vent_pump))
			send_signal(list("tag"=input_tag,
				"direction"=1, // Release
				"checks"   =0  // No pressure checks.
				))
		return 1
	if(context["slot"]=="output" && is_type_in_list(O,output_linkable))
		output_tag = O:id_tag
		output_info = null
		if(istype(O,/obj/machinery/atmospherics/unary/vent_pump))
			send_signal(list("tag"=output_tag,
				"direction"=0, // Siphon
				"checks"   =2  // Internal pressure checks.
				))
		return 1

/obj/machinery/computer/general_air_control/large_tank_control/unlinkFrom(var/mob/user, var/obj/O)
	if("id_tag" in O.vars)
		if(O:id_tag == input_tag)
			input_tag=null
			input_info=null
			return 1
		if(O:id_tag == output_tag)
			output_tag=null
			output_info=null
			return 1
	return 0

/obj/machinery/computer/general_air_control/large_tank_control/linkMenu(var/obj/O)
	var/dat=""
	if(canLink(O,list("slot"="input")))
		dat += " <a href='?src=\ref[src];link=1;slot=input'>\[Link @ Input\]</a> "
	if(canLink(O,list("slot"="output")))
		dat += " <a href='?src=\ref[src];link=1;slot=output'>\[Link @ Output\]</a> "
	return dat

/obj/machinery/computer/general_air_control/large_tank_control/canLink(var/obj/O, var/list/context)
	return (context["slot"]=="input" && is_type_in_list(O,input_linkable)) || (context["slot"]=="output" && is_type_in_list(O,output_linkable))

/obj/machinery/computer/general_air_control/large_tank_control/isLinkedWith(var/obj/O)
	if(O:id_tag == input_tag)
		return 1
	if(O:id_tag == output_tag)
		return 1
	return 0

/obj/machinery/computer/general_air_control/large_tank_control/process()
	..()
	if(!input_info && input_tag)
		request_device_refresh(input_tag)
	if(!output_info && output_tag)
		request_device_refresh(output_tag)

/obj/machinery/computer/general_air_control/large_tank_control/return_text()
	var/output = ..()
	//if(signal.data)
	//	input_info = signal.data // Attempting to fix intake control -- TLE

	output += "<h2>Tank Control System</h2><BR>"
	if(input_tag)
		if(input_info)
			var/power = (input_info["power"])
			var/volume_rate = input_info["volume_rate"]
			output += {"
<fieldset>
<legend>Input (<A href='?src=\ref[src];in_refresh_status=1'>Refresh</A>)</legend>
<table>
<tr>
	<th>State:</th>
	<td><A href='?src=\ref[src];in_toggle_injector=1'>[power?("Injecting"):("On Hold")]</A></td>
</tr>
<tr>
	<th>Rate:</th>
	<td><a href="?src=\ref[src];in_set_rate=1">[volume_rate]</a> L/sec</td>
</tr>
</table>
</fieldset>
"}

		else
			output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=\ref[src];in_refresh_status=1'>Search</A><BR>"
	if(output_tag)
		if(output_info)
			var/power = (output_info["power"])
			var/output_pressure = output_info["internal"]
			output += {"
<fieldset>
<legend>Output (<A href='?src=\ref[src];out_refresh_status=1'>Refresh</A>)</legend>
<table>
<tr>
	<th>State:</th>
	<td><A href='?src=\ref[src];out_toggle_power=1'>[power?("Open"):("On Hold")]</A></td>
</tr>
<tr>
	<th>Max Output Pressure:</th>
	<td><A href='?src=\ref[src];out_set_pressure=1'>[output_pressure]</A> kPa</td>
</tr>
</table>
</fieldset>
"}
		else
			output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=\ref[src];out_refresh_status=1'>Search</A><BR>"

	return output


/obj/machinery/computer/general_air_control/large_tank_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
		updateUsrDialog()
	else if(output_tag == id_tag)
		output_info = signal.data
		updateUsrDialog()
	else
		..(signal)

/obj/machinery/computer/general_air_control/large_tank_control/proc/request_device_refresh(var/device)
	send_signal(list("tag"=device, "status"))

/obj/machinery/computer/general_air_control/large_tank_control/proc/send_signal(var/list/data)
	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data=data
	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	if(href_list["out_set_pressure"])
		var/response=input(usr,"Set new pressure, in kPa. \[0-[50*ONE_ATMOSPHERE]\]") as num
		var/oldpressure = pressure_setting
		pressure_setting = text2num(response)
		pressure_setting = Clamp(pressure_setting, 0, 50*ONE_ATMOSPHERE)
		investigation_log(I_ATMOS,"'s output pressure set to [pressure_setting] from [oldpressure] by [key_name(usr)]")

	if(!radio_connection)
		return 0
	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src
	if(href_list["in_refresh_status"])
		input_info = null
		signal.data = list ("tag" = input_tag, "status")

	else if(href_list["in_toggle_injector"])
		input_info = null
		signal.data = list ("tag" = input_tag, "power_toggle")

	else if(href_list["in_set_rate"])
		input_info = null
		var/new_rate=input("Enter the new volume rate of the injector:","Injector Rate") as num
		new_rate = text2num(new_rate)
		new_rate = Clamp(new_rate, 0, new_rate)
		signal.data = list ("tag" = input_tag, "set_volume_rate"=new_rate)

	else if(href_list["out_refresh_status"])
		output_info = null
		signal.data = list ("tag" = output_tag, "status")

	else if(href_list["out_toggle_power"])
		output_info = null
		signal.data = list ("tag" = output_tag, "power_toggle", "direction" = 0, "checks" = 2)
		// Vents need to be set to siphon. Manualy inputting the id won't set the uvent correctly

	else if(href_list["out_set_pressure"])
		output_info = null
		signal.data = list ("tag" = output_tag, "set_internal_pressure" = "[pressure_setting]")
	/*else
		testing("Bad Topic() to large_tank_control \"[src.name]\": [href]")
		return */// NOPE. // disabling because it spams when multitool menus are used

	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
	src.updateUsrDialog()

/obj/machinery/computer/general_air_control/fuel_injection
	icon = 'icons/obj/computer.dmi'
	icon_state = "atmos"
	circuit = "/obj/item/weapon/circuitboard/injector_control"

	var/device_tag
	var/list/device_info

	var/automation = 0

	var/cutoff_temperature = 2000
	var/on_temperature = 1200

/obj/machinery/computer/general_air_control/fuel_injection/process()
	if(automation)
		if(!radio_connection)
			return 0

		var/injecting = 0
		for(var/id_tag in sensor_information)
			var/list/data = sensor_information[id_tag]
			if(data["temperature"])
				if(data["temperature"] >= cutoff_temperature)
					injecting = 0
					break
				if(data["temperature"] <= on_temperature)
					injecting = 1

		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data = list(
			"tag" = device_tag,
			"power" = injecting,
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	..()

/obj/machinery/computer/general_air_control/fuel_injection/return_text()
	var/output = ..()
	output += "<fieldset><legend>Fuel Injection System (<A href='?src=\ref[src];refresh_status=1'>Refresh</A>)</legend>"
	if(device_info)
		var/power = device_info["power"]
		var/volume_rate = device_info["volume_rate"]
		output += {"<table>
		<tr>
			<th>Status:</th>
			<td>[power?"Injecting":"On Hold"]</td>
		</tr>
		<tr>
			<th>Rate:</th>
			<td>[volume_rate] L/sec</td>
		</tr>
		<tr>
			<th>Automated Fuel Injection:</th>
			<td><A href='?src=\ref[src];toggle_automation=1'>[automation?"Engaged":"Disengaged"]</A></td>
		</tr>"}

		if(automation)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\atmo_control.dm:372: output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Engaged</A><BR>"
			output += {"
			<tr>
				<td colspan="2">Injector Controls Locked Out</td>
			</tr>"}
			// END AUTOFIX
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\atmo_control.dm:375: output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Disengaged</A><BR>"
			output += {"
			<tr>
				<th>Injector:</th>
				<td><A href='?src=\ref[src];toggle_injector=1'>Toggle Power</A> <A href='?src=\ref[src];injection=1'>Inject (1 Cycle)</A></td>
			</td>"}
			// END AUTOFIX
		output += "</table>"
	else
		output += {"<p style="color:red"><b>ERROR:</b> Can not find device. <A href='?src=\ref[src];refresh_status=1'>Search</A></p>"}
	output += "</fieldset>"

	return output

/obj/machinery/computer/general_air_control/fuel_injection/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(device_tag == id_tag)
		device_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/fuel_injection/Topic(href, href_list)
	if(..())
		return

	if(href_list["refresh_status"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"status",
			"sigtype"="command"
		)
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["toggle_automation"])
		automation = !automation
		investigation_log(I_ATMOS,"was turned [automation ? "on" : "off"] by [key_name(usr)]")

	if(href_list["toggle_injector"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"power_toggle",
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["injection"])
		if(!radio_connection)
			return 0

		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"inject",
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


