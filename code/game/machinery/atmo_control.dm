obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	name = "Gas Sensor"

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

	update_icon()
		icon_state = "gsensor[on]"

	process()
		if(on)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			var/datum/gas_mixture/air_sample = return_air()

			if(output&1)
				signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1),)
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


	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

	initialize()
		set_frequency(frequency)

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

obj/machinery/computer/general_air_control
	icon = 'icons/obj/computer.dmi'
	icon_state = "tank"

	name = "Computer"

	var/frequency = 1439
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

	attack_hand(mob/user)
		user << browse(return_text(),"window=computer")
		user.machine = src
		onclose(user, "computer")

	process()
		..()
		src.updateDialog()

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/air_management/M = new /obj/item/weapon/circuitboard/air_management( A )
					for (var/obj/C in src)
						C.loc = src.loc
					M.frequency = src.frequency
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/air_management/M = new /obj/item/weapon/circuitboard/air_management( A )
					for (var/obj/C in src)
						C.loc = src.loc
					M.frequency = src.frequency
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else
			src.attack_hand(user)
		return

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/id_tag = signal.data["tag"]
		if(!id_tag || !sensors.Find(id_tag)) return

		sensor_information[id_tag] = signal.data

	proc/return_text()
		var/sensor_data
		if(sensors.len)
			for(var/id_tag in sensors)
				var/long_name = sensors[id_tag]
				var/list/data = sensor_information[id_tag]
				var/sensor_part = "<B>[long_name]</B>:<BR>"

				if(data)
					if(data["pressure"])
						sensor_part += "   <B>Pressure:</B> [data["pressure"]] kPa<BR>"
					if(data["temperature"])
						sensor_part += "   <B>Temperature:</B> [data["temperature"]] K<BR>"
					if(data["oxygen"]||data["toxins"]||data["nitrogen"]||data["carbon_dioxide"])
						sensor_part += "   <B>Gas Composition :</B>"
						if(data["oxygen"])
							sensor_part += "[data["oxygen"]]% O2; "
						if(data["nitrogen"])
							sensor_part += "[data["nitrogen"]]% N; "
						if(data["carbon_dioxide"])
							sensor_part += "[data["carbon_dioxide"]]% CO2; "
						if(data["toxins"])
							sensor_part += "[data["toxins"]]% TX; "
					sensor_part += "<HR>"

				else
					sensor_part = "<FONT color='red'>[long_name] can not be found!</FONT><BR>"

				sensor_data += sensor_part

		else
			sensor_data = "No sensors connected."

		var/output = {"<B>[name]</B><HR>
<B>Sensor Data:</B><HR><HR>[sensor_data]"}

		return output

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

	initialize()
		set_frequency(frequency)

	large_tank_control
		icon = 'icons/obj/computer.dmi'
		icon_state = "tank"

		var/input_tag
		var/output_tag

		var/list/input_info
		var/list/output_info

		var/pressure_setting = ONE_ATMOSPHERE * 45


		return_text()
			var/output = ..()
			//if(signal.data)
			//	input_info = signal.data // Attempting to fix intake control -- TLE

			output += "<B>Tank Control System</B><BR>"
			if(input_info)
				var/power = (input_info["power"])
				var/volume_rate = input_info["volume_rate"]
				output += {"<B>Input</B>: [power?("Injecting"):("On Hold")] <A href='?src=\ref[src];in_refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}
				output += "Command: <A href='?src=\ref[src];in_toggle_injector=1'>Toggle Power</A><BR>"

			else
				output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=\ref[src];in_refresh_status=1'>Search</A><BR>"

			output += "<BR>"

			if(output_info)
				var/power = (output_info["power"])
				var/output_pressure = output_info["internal"]
				output += {"<B>Output</B>: [power?("Open"):("On Hold")] <A href='?src=\ref[src];out_refresh_status=1'>Refresh</A><BR>
Max Output Pressure: [output_pressure] kPa<BR>"}
				output += "Command: <A href='?src=\ref[src];out_toggle_power=1'>Toggle Power</A> <A href='?src=\ref[src];out_set_pressure=1'>Set Pressure</A><BR>"

			else
				output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=\ref[src];out_refresh_status=1'>Search</A><BR>"

			output += "Max Output Pressure Set: <A href='?src=\ref[src];adj_pressure=-100'>-</A> <A href='?src=\ref[src];adj_pressure=-1'>-</A> [pressure_setting] kPa <A href='?src=\ref[src];adj_pressure=1'>+</A> <A href='?src=\ref[src];adj_pressure=100'>+</A><BR>"

			return output

		receive_signal(datum/signal/signal)
			if(!signal || signal.encryption) return

			var/id_tag = signal.data["tag"]

			if(input_tag == id_tag)
				input_info = signal.data
			else if(output_tag == id_tag)
				output_info = signal.data
			else
				..(signal)

		Topic(href, href_list)
			if(..())
				return

			if(href_list["adj_pressure"])
				var/change = text2num(href_list["adj_pressure"])
				pressure_setting = between(0, pressure_setting + change, 50*ONE_ATMOSPHERE)
				spawn(1)
					src.updateDialog()
				return

			if(!radio_connection)
				return 0
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src
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

			spawn(5)
				src.updateDialog()

	fuel_injection
		icon = 'icons/obj/computer.dmi'
		icon_state = "atmos"

		var/device_tag
		var/list/device_info

		var/automation = 0

		var/cutoff_temperature = 2000
		var/on_temperature = 1200

		attackby(I as obj, user as mob)
			if(istype(I, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				if(do_after(user, 20))
					if (src.stat & BROKEN)
						user << "\blue The broken glass falls out."
						var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
						new /obj/item/weapon/shard( src.loc )
						var/obj/item/weapon/circuitboard/injector_control/M = new /obj/item/weapon/circuitboard/injector_control( A )
						for (var/obj/C in src)
							C.loc = src.loc
						M.frequency = src.frequency
						A.circuit = M
						A.state = 3
						A.icon_state = "3"
						A.anchored = 1
						del(src)
					else
						user << "\blue You disconnect the monitor."
						var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
						var/obj/item/weapon/circuitboard/injector_control/M = new /obj/item/weapon/circuitboard/injector_control( A )
						for (var/obj/C in src)
							C.loc = src.loc
						M.frequency = src.frequency
						A.circuit = M
						A.state = 4
						A.icon_state = "4"
						A.anchored = 1
						del(src)
			else
				src.attack_hand(user)
			return

		process()
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

		return_text()
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

		receive_signal(datum/signal/signal)
			if(!signal || signal.encryption) return

			var/id_tag = signal.data["tag"]

			if(device_tag == id_tag)
				device_info = signal.data
			else
				..(signal)

		Topic(href, href_list)
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




