//States for airlock_control
#define AIRLOCK_STATE_INOPEN		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_CLOSED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_OUTOPEN		2

var/airlock_control_num

datum/computer/file/embedded_program/airlock_controller
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED
	var/sensor_pressure = null

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==sensor_tag)
			if(signal.data["pressure"])
				sensor_pressure = text2num(signal.data["pressure"])

		else if(receive_tag==exterior_door_tag)
			memory["exterior_status"] = signal.data["door_status"]

		else if(receive_tag==interior_door_tag)
			memory["interior_status"] = signal.data["door_status"]

		else if(receive_tag==airpump_tag)
			if(signal.data["power"])
				memory["pump_status"] = signal.data["direction"]
			else
				memory["pump_status"] = "off"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle")
					if(state < AIRLOCK_STATE_CLOSED)
						target_state = AIRLOCK_STATE_OUTOPEN
					else
						target_state = AIRLOCK_STATE_INOPEN

	receive_user_command(command)
		switch(command)
			if("cycle_closed")
				target_state = AIRLOCK_STATE_CLOSED
			if("cycle_exterior")
				target_state = AIRLOCK_STATE_OUTOPEN
			if("cycle_interior")
				target_state = AIRLOCK_STATE_INOPEN
			if("abort")
				target_state = AIRLOCK_STATE_CLOSED

	process()
		var/process_again = 1
		while(process_again)
			process_again = 0
			switch(state)
				if(AIRLOCK_STATE_INOPEN) // state -2
					if(target_state > state)
						if(memory["interior_status"] == "closed")
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

				if(AIRLOCK_STATE_PRESSURIZE)
					if(target_state < state)
						if(sensor_pressure >= ONE_ATMOSPHERE*0.95)
							if(memory["interior_status"] == "open")
								state = AIRLOCK_STATE_INOPEN
								process_again = 1
							else
								var/datum/signal/signal = new
								signal.data["tag"] = interior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
						else
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"sigtype"="command"
							)
							if(memory["pump_status"] == "siphon")
								signal.data["stabalize"] = 1
							else if(memory["pump_status"] != "release")
								signal.data["power"] = 1
							post_signal(signal)
					else if(target_state > state)
						state = AIRLOCK_STATE_CLOSED
						process_again = 1

				if(AIRLOCK_STATE_CLOSED)
					if(target_state > state)
						if(memory["interior_status"] == "closed")
							state = AIRLOCK_STATE_DEPRESSURIZE
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else if(target_state < state)
						if(memory["exterior_status"] == "closed")
							state = AIRLOCK_STATE_PRESSURIZE
							process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)

					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

				if(AIRLOCK_STATE_DEPRESSURIZE)
					var/target_pressure = ONE_ATMOSPHERE*0.05
					if(sanitize_external)
						target_pressure = ONE_ATMOSPHERE*0.01

					if(sensor_pressure <= target_pressure)
						if(target_state > state)
							if(memory["exterior_status"] == "open")
								state = AIRLOCK_STATE_OUTOPEN
							else
								var/datum/signal/signal = new
								signal.data["tag"] = exterior_door_tag
								signal.data["command"] = "secure_open"
								post_signal(signal)
						else if(target_state < state)
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
					else if((target_state < state) && !sanitize_external)
						state = AIRLOCK_STATE_CLOSED
						process_again = 1
					else
						var/datum/signal/signal = new
						signal.transmission_method = 1 //radio signal
						signal.data = list(
							"tag" = airpump_tag,
							"sigtype"="command"
						)
						if(memory["pump_status"] == "release")
							signal.data["purge"] = 1
						else if(memory["pump_status"] != "siphon")
							signal.data["power"] = 1
						post_signal(signal)

				if(AIRLOCK_STATE_OUTOPEN) //state 2
					if(target_state < state)
						if(memory["exterior_status"] == "closed")
							if(sanitize_external)
								state = AIRLOCK_STATE_DEPRESSURIZE
								process_again = 1
							else
								state = AIRLOCK_STATE_CLOSED
								process_again = 1
						else
							var/datum/signal/signal = new
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "secure_close"
							post_signal(signal)
					else
						if(memory["pump_status"] != "off")
							var/datum/signal/signal = new
							signal.data = list(
								"tag" = airpump_tag,
								"power" = 0,
								"sigtype"="command"
							)
							post_signal(signal)

		memory["sensor_pressure"] = sensor_pressure
		memory["processing"] = state != target_state
		//sensor_pressure = null //not sure if we can comment this out. Uncomment in case of problems -rastaf0
		return 1


obj/machinery/embedded_controller/radio/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Airlock Console"
	density = 0

	frequency = 1449
	power_channel = ENVIRON

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	//Config parameters
	var/page = 2
	var/option = 0
	var/formatted = 1

	initialize()
		..()

		var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

		if(!id_tag)
			airlock_control_num = airlock_control_num + 1
			id_tag = "airlock_net_[airlock_control_num]"
			exterior_door_tag = "[id_tag]_ext"
			interior_door_tag = "[id_tag]_int"
			airpump_tag = "[id_tag]_pump"
			sensor_tag = "[id_tag]_sensor"
			frequency = 1450
			sanitize_external = 0
			page = 0
			formatted = 1
		else
			page = 2
			formatted = 1

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag
		new_prog.airpump_tag = airpump_tag
		new_prog.sensor_tag = sensor_tag
		new_prog.sanitize_external = sanitize_external

		new_prog.master = src
		program = new_prog

	update_icon()
		if(on && program && formatted)
			if(program.memory["processing"])
				icon_state = "airlock_control_process"
			else
				icon_state = "airlock_control_standby"
		else
			icon_state = "airlock_control_off"

	return_text()
		var/dat = ""
		var/sclosed = "border:2px solid DarkRed;background-color:red"
		var/sopen = "border:2px solid DarkGreen;background-color:green"
		switch(page)	//This is the basic configuration page
			if(0)
				dat += "<h3>Device Status</h3>"
				dat += text("<table width='100%'>")
				dat += text("<tr><td width='50%'>")
				dat += text("<div align='center' width='20%'style='[formatted? sopen : sclosed]'>[formatted? "online" : "offline"]</span></td></tr>")
				//dat += text("<tr><td width='50%'><A href='?src=\ref[src];action=0;item=\ref[src];='>Format Device</A></td></tr>")
				dat += text("<tr><td width='50%'><A href='?src=\ref[src];page=2'>Access Control Console</A></td></tr>")
				dat += text("</tr></table>")
				dat += "<h3>Settings</h3>"
				dat += "<table width='100%'>"
				dat += text("<tr><td width='25%'>Exterior Door</td>")
				dat += text("<td width='25%'>[exterior_door_tag? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[exterior_door_tag];page=1;option=1'>[exterior_door_tag? "unlink" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Interior Door</td>")
				dat += text("<td width='25%'>[interior_door_tag? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[interior_door_tag];page=1;option=2'>[interior_door_tag? "unlink" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Sensor</td>")
				dat += text("<td width='25%'>[sensor_tag? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[interior_door_tag];page=1;option=3'>[sensor_tag? "unlink" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Airpump</td>")
				dat += text("<td width='25%'>[airpump_tag? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[airpump_tag];page=1;option=4'>[airpump_tag? "unlink" : "link"]</A></td></tr>")
				dat += text("</table>")
			if(1)
				dat += "<h3>Select [(page == 1)? "Exterior Door":""][(page == 2)? "Interior Door":""][(page == 3)? "Sensor":""][(page == 4)? "Air Pump":""]</h3>"
				dat += "<table width='100%'>"
				var/list/L = range(5, src)

				switch(option)
					if(1)
						for(var/obj/machinery/door/airlock/D in L)
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[(D.id_tag)? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=1'>[(D.id_tag)? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(2)
						for(var/obj/machinery/door/airlock/D in L)
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[(D.id_tag)? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=2'>[(D.id_tag)? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(3)
						for(var/obj/machinery/airlock_sensor/D in L)
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[(D.id_tag)? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=3'>[(D.id_tag)? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(4)
						for(var/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/D in L)
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[(D.id)? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=4'>[(D.id)? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
				dat += text("</table><A href='?src=\ref[src];page=0'>Back to Configuration Menu</A>")
			if(2)
				var/state = 0
				var/sensor_pressure = "----"
				var/exterior_status = "----"
				var/interior_status = "----"
				var/pump_status = "----"

				//var/blcolor = "#ffeeee" //banned light
				//var/bdcolor = "#ffdddd" //banned dark
				//var/ulcolor = "#eeffee" //unbanned light
				//var/udcolor = "#ddffdd" //unbanned dark
				var/stylesen
				var/stylepump

				if(program)
					state = program.state
					sensor_pressure = program.memory["sensor_pressure"]
					exterior_status = program.memory["exterior_status"]
					interior_status = program.memory["interior_status"]
					pump_status = program.memory["pump_status"]
				dat += text("<h3>Control Console</h3>")
				dat += text("<table width='100%'>")
				switch(state)
					if(AIRLOCK_STATE_INOPEN)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_closed'>Close Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A></td></tr>")
					if(AIRLOCK_STATE_PRESSURIZE)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=abort'>Abort Cycling</A></td></tr>")
					if(AIRLOCK_STATE_CLOSED)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_interior'>Open Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_exterior'>Open Exterior Airlock</A></td></tr>")
					if(AIRLOCK_STATE_DEPRESSURIZE)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=abort'>Abort Cycling</A></td></tr>")
					if(AIRLOCK_STATE_OUTOPEN)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_closed'>Close Exterior Airlock</A></td></tr>")
				if(sensor_pressure > 90)
					stylesen = "good"
				else
					if(sensor_pressure > 50)
						stylesen = "average"
					else
						stylesen = "bad"
				switch(pump_status)
					if("siphon")
						stylepump = sopen
					if("release")
						stylepump = sopen
					if("off")
						stylepump = sclosed

				dat += text("</table>")
				dat += text("<h3>Status</h3>")
				dat += text("<table width='100%'>")
				dat += text("<tr><td width='50%'>Chamber Pressure</td><td width='50%'><b><span class='[stylesen]'>[sensor_pressure]</b></span> kPa</td></tr>")
				dat += text("<tr><td width='50%'>Exterior Door</td><td width='50%'><div align='center' width='20%'style='[(exterior_status == "open")? sopen : sclosed]'>[exterior_status]</div></td></tr>")
				dat += text("<tr><td width='50%'>Interior Door</td><td width='50%'><div align='center' width='20%'style='[(interior_status == "open")? sopen : sclosed]'>[interior_status]</div></td></tr>")
				dat += text("<tr><td width='50%'>Control Pump</td><td width='50%'><div align='center' width='20%'style='[stylepump]'>[pump_status]</div></td></tr>")
				dat += text("</table>")
				dat += text("</table><A href='?src=\ref[src];page=0'>Back to Configuration Menu</A>")
		return dat

	attack_hand(mob/user)
		var/datum/browser/popup = new(user, "airlock", "Airlock Control", 300, 360)

		popup.set_content(return_text())
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return

	Topic(href, href_list)
		if(..())
			return 0
		//var/datum/computer/file/embedded_program/airlock_controller/P = program

		if(href_list["action"])
			usr << "doing action!! )]"
			if(href_list["item"])
				switch(text2num(href_list["action"]))
					if(0)
						//initialize()
						page = 0
					if(1)
						var/obj/machinery/door/airlock/O = locate(href_list["item"])
						O.id_tag = "[id_tag]_ext"
						O.locked = 1
						O.frequency = 1449
						O.icon_state = "door_locked"
						O.autoclose = 0
						page = 0
					if(2)
						var/obj/machinery/door/airlock/O = locate(href_list["item"])
						O.id_tag = "[id_tag]_int"
						O.locked = 1
						O.frequency = 1449
						O.icon_state = "door_locked"
						O.autoclose = 0
						page = 0
					if(3)
						var/obj/machinery/airlock_sensor/O = locate(href_list["item"])
						O.id_tag = "[id_tag]_sensor"
						O.frequency = 1449
						O.master_tag = id_tag
						page = 0
					if(4)
						var/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/O = locate(href_list["item"])
						O.id = "[id_tag]_pump"
						O.frequency = 1449
						page = 0
			src.updateUsrDialog()

		if(href_list["page"])
			usr << "changing page!!"
			switch(text2num(href_list["page"]))
				if(0)
					page = 0
					option = 0
				if(1)
					page = 1
					option = text2num(href_list["option"])
				if(2)
					page = 2
					option = 0
			src.updateUsrDialog()

		if(program)
			program.receive_user_command(href_list["command"])
			spawn(5) program.process()

		usr.set_machine(src)
		spawn(5) src.updateUsrDialog()

	process()
		if(program && formatted)
			program.process()

		update_icon()
		src.updateUsrDialog()