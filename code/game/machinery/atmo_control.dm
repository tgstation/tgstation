/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gaz tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	name = "gas sensor"

	anchored = 1
	var/state = 0

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

	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/update_icon()
		icon_state = "gsensor[on]"

/obj/machinery/air_sensor/process_atmos()
	if(on)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		var/datum/gas_mixture/air_sample = return_air()

		if(output&1)
			signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1))
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
	SSair.atmos_machinery += src
	if(radio_controller)
		set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////

/obj/machinery/computer/general_air_control
	icon_screen = "tank"
	icon_keyboard = "atmos_key"

	circuit = /obj/item/weapon/circuitboard/air_management

	var/frequency = 1439
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

/obj/machinery/computer/general_air_control/New()
	..()

	if(radio_controller)
		set_frequency(frequency)

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	if(..(user))
		return
	interact(user) //UpdateDialog() is calling /interact each tick, not attack_hand()


/obj/machinery/computer/general_air_control/interact(mob/user)
	var/datum/browser/popup = new(user, "computer", name, 480, 490) //update the content every tick
	popup.set_content(return_text())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/general_air_control/process()
	if(..())	//if the computer is not broken or unpowered
		src.updateDialog()

/obj/machinery/computer/general_air_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]
	if(!id_tag || !sensors.Find(id_tag)) return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/proc/return_text()
	var/sensor_data
	var/count = 0
	if(sensors.len)
		sensor_data += "<TABLE cellpadding='3'><TR>" //begin the 3x2 table formatting

		for(var/id_tag in sensors)
			var/long_name = sensors[id_tag]
			var/list/data = sensor_information[id_tag]
			var/sensor_part = "<h2>[long_name]</h2>"

			if(data)
				if(data["pressure"])
					sensor_part += "   <B>Pressure:</B> [data["pressure"]] kPa<BR>"
				else
					sensor_part += "   <B>Pressure:</B> No pressure detected<BR>"
				if(data["temperature"])
					sensor_part += "   <B>Temperature:</B> [data["temperature"]] K<BR>"
				if(data["oxygen"]||data["toxins"]||data["nitrogen"]||data["carbon_dioxide"])
					sensor_part += "   <B>Gas Composition : </B>"
					if(data["oxygen"])
						sensor_part += "[data["oxygen"]]% O2; "
					if(data["nitrogen"])
						sensor_part += "[data["nitrogen"]]% N; "
					if(data["carbon_dioxide"])
						sensor_part += "[data["carbon_dioxide"]]% CO2; "
					if(data["toxins"])
						sensor_part += "[data["toxins"]]% TX; "

			else
				sensor_part = "<FONT class='bad'>[long_name] can not be found!</FONT><BR>"

			sensor_data += "<TD valign='top'>[sensor_part]</TD>"//add the data to the current table cell
			count++;
			if(count == 2) //if we've put two readings on a line...
				sensor_data +="</TR><TR>" //... start a new one
				count = 0
		sensor_data += "</TR></TABLE>" //end the table formatting
	else
		sensor_data = "No sensors connected.<BR><BR>" // there's nothing in the sensors list (new computer), so choose between the two atmos computers
		sensor_data += "<A href='?src=\ref[src];dist_loop=1'>Initialize as Distribution and Waste Monitor</A><BR>"
		sensor_data += "<A href='?src=\ref[src];tank_mon=1'>Initialize as Tank Monitor</A><BR>"

	var/output = {"
<h1>Sensor Data</h1>[sensor_data]"}

	return output

/obj/machinery/computer/general_air_control/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	..()

/obj/machinery/computer/general_air_control/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/general_air_control/initialize()
	set_frequency(frequency)

/obj/machinery/computer/general_air_control/Topic(href, href_list)
	if(..())
		return

	if(href_list["dist_loop"])
		name = "Distribution and Waste Monitor"
		set_frequency(1443)
		sensors = list("mair_in_meter" = "Mixed Air In", "air_sensor" = "Mixed Air Supply Tank", "mair_out_meter" = "Mixed Air Out", "dloop_atm_meter" = "Distribution Loop", "wloop_atm_meter" = "Waste Loop")

	if(href_list["tank_mon"])
		name = "Tank Monitor"
		set_frequency(1441)
		sensors = list("n2_sensor" = "Nitrogen", "o2_sensor" = "Oxygen", "co2_sensor" = "Carbon Dioxide", "tox_sensor" = "Toxins", "n2o_sensor" = "Nitrous Oxide", "waste_sensor" = "Gas Mix Tank")


/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/general_air_control/large_tank_control
	var/input_tag
	var/output_tag
	frequency = 1441
	circuit = /obj/item/weapon/circuitboard/large_tank_control

	var/list/input_info
	var/list/output_info

	var/pressure_setting = ONE_ATMOSPHERE * 45

/obj/machinery/computer/general_air_control/large_tank_control/proc/reconnect(mob/user)    //This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
	var/list/IO = list()
	var/datum/radio_frequency/air_freq = radio_controller.return_frequency(1443)
	var/datum/radio_frequency/gas_freq = radio_controller.return_frequency(1441)
	var/list/devices = air_freq.devices["_default"]
	devices |= gas_freq.devices["_default"]
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in devices)
		var/list/text = text2list(U.id_tag, "_")
		IO |= text[1]
	for(var/obj/machinery/atmospherics/unary/outlet_injector/U in devices)
		var/list/text = text2list(U.id, "_")
		IO |= text[1]
	if(!IO.len)
		user << "<span class='alert'>No machinery detected.</span>"
	var/S = input("Select the device set: ", "Selection", IO[1]) as anything in IO
	if(src)
		src.input_tag = "[S]_in"
		src.output_tag = "[S]_out"
		name = "[uppertext(S)] Supply Control"
		var/list/new_devices = gas_freq.devices["4"]
		new_devices |= air_freq.devices["4"]
		for(var/obj/machinery/air_sensor/U in new_devices)
			var/list/text = text2list(U.id_tag, "_")
			if(text[1] == S)
				sensors = list("[S]_sensor" = "Tank")
				break

	if(S == "air")
		frequency = 1443
	else
		frequency = 1441

	set_frequency(frequency)

	for(var/obj/machinery/atmospherics/unary/outlet_injector/U in devices)
		U.broadcast_status()

	for(var/obj/machinery/atmospherics/unary/vent_pump/U in devices)
		U.broadcast_status()

/obj/machinery/computer/general_air_control/large_tank_control/return_text()
	var/output = "<A href='?src=\ref[src];reconnect=1'>Reconnect</A><BR>"
	if(sensors.len) //if recieving signals from nearby sensors...
		output += ..() //... get the data.
	else
		output += "No sensors connected."

	output += "<h1>Tank Control System</h1>"
	if(input_info)
		var/power = (input_info["power"])
		var/volume_rate = input_info["volume_rate"]
		output += {"<B>Input</B>: [power?("Injecting"):("On Hold")] <A href='?src=\ref[src];in_refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}
		output += "<B>Command:</B> <A href='?src=\ref[src];in_toggle_injector=1'>Toggle Power</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find input port</FONT><BR>"

	output += "<BR>"

	if(output_info)
		var/power = (output_info["power"])
		var/output_pressure = output_info["internal"]
		output += {"<B>Output</B>: [power?("Open"):("On Hold")] <A href='?src=\ref[src];out_refresh_status=1'>Refresh</A><BR>
<B>Max Output Pressure:</B> [output_pressure] kPa<BR>"}
		output += "<B>Command:</B> <A href='?src=\ref[src];out_toggle_power=1'>Toggle Power</A> <A href='?src=\ref[src];out_set_pressure=1'>Set Pressure</A><BR>"
		output += "<B>Max Output Pressure Set:</B> <A href='?src=\ref[src];adj_pressure=-1000'>-</A> <A href='?src=\ref[src];adj_pressure=-100'>-</A> <A href='?src=\ref[src];adj_pressure=-10'>-</A> <A href='?src=\ref[src];adj_pressure=-1'>-</A> [pressure_setting] kPa <A href='?src=\ref[src];adj_pressure=1'>+</A> <A href='?src=\ref[src];adj_pressure=10'>+</A> <A href='?src=\ref[src];adj_pressure=100'>+</A> <A href='?src=\ref[src];adj_pressure=1000'>+</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find output port</FONT><BR>"

	return output

/obj/machinery/computer/general_air_control/large_tank_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	if(..())
		return

	if(href_list["adj_pressure"])
		var/change = text2num(href_list["adj_pressure"])
		pressure_setting = Clamp(pressure_setting + change, 0, 50*ONE_ATMOSPHERE)
		return

	if(!radio_connection)
		return 0
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	if(href_list["reconnect"])
		reconnect(usr)
	if(href_list["in_refresh_status"])
		input_info = null
		signal.data = list ("tag" = input_tag, "status")

	if(href_list["in_toggle_injector"])
		input_info = null
		signal.data = list ("tag" = input_tag, "power_toggle")

	if(href_list["out_refresh_status"])
		output_info = null
		signal.data = list ("tag" = output_tag, "status")

	if(href_list["out_toggle_power"])
		output_info = null
		signal.data = list ("tag" = output_tag, "power_toggle")

	if(href_list["out_set_pressure"])
		output_info = null
		signal.data = list ("tag" = output_tag, "set_internal_pressure" = "[pressure_setting]")

	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


/////////////////////////////////////////////////////////////
// FUEL INJECTION
/////////////////////////////////////////////////////////////

/obj/machinery/computer/general_air_control/fuel_injection
	icon_screen = "atmos"

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

		var/datum/signal/signal = new
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

	output += "<B>Fuel Injection System</B><BR>"
	if(device_info)
		var/power = device_info["power"]
		var/volume_rate = device_info["volume_rate"]
		output += {"Status: [power?("Injecting"):("On Hold")] <A href='?src=\ref[src];refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}

		if(automation)
			output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Engaged</A><BR>"
			output += "Injector Controls Locked Out<BR>"
		else
			output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Disengaged</A><BR>"
			output += "Injector: <A href='?src=\ref[src];toggle_injector=1'>Toggle Power</A> <A href='?src=\ref[src];injection=1'>Inject (1 Cycle)</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find device</FONT> <A href='?src=\ref[src];refresh_status=1'>Search</A><BR>"

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

		var/datum/signal/signal = new
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

	if(href_list["toggle_injector"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
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

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"inject",
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
