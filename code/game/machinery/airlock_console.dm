#define AIRLOCK_STATE_VENT		-3
#define AIRLOCK_STATE_EXTERIOR		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_SEALED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_INTERIOR		2
#define AIRLOCK_STATE_CONFIG		3

obj/machinery/airlock_console
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	name = "Airlock Console"
	density = 0
	var/tdir

	// Setup parameters only
	var/id_tag
	var/obj/machinery/door/airlock/exterior_door	//var/exterior_door_tag
	var/obj/machinery/door/airlock/interior_door	//var/interior_door_tag
	var/obj/machinery/atmospherics/unary/vent_pump/air_pump			//var/airpump_tag
	var/obj/machinery/airlock_sensor_wired/air_sensor		//var/sensor_tag
	var/sanitize_external

	power_channel = ENVIRON

	//screen
	var/page = 0
	var/option = 0

	//computer
	var/obj/machinery/airlock_console/parent
	var/formatted = 0
	var/processing = 0
	var/on = 0

	//memory
	var/state = AIRLOCK_STATE_CONFIG
	var/target_state = AIRLOCK_STATE_CONFIG
	var/sensor_pressure
	var/sensor_temperature
	var/exterior_status
	var/interior_status
	var/pump_status

	New(turf/loc, var/ndir, var/building=0)
		..()
		if (building)
			// offset 24 pixels in direction of dir
			// this allows the APC to be embedded in a wall, yet still inside an area
			dir = ndir
			src.tdir = dir		// to fix Vars bug
			dir = SOUTH

			pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
			pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0

	update_icon()
		if(formatted || parent)
			if(processing)
				icon_state = "airlock_control_process"
			else
				icon_state = "airlock_control_standby"
		else
			icon_state = "airlock_control_off"

	proc/airlockState()
		if(!formatted)	//is activated?
			state = AIRLOCK_STATE_CONFIG

	proc/airlockOpen(var/obj/machinery/door/airlock/D)
		D.locked = 0
		D.update_icon()
		sleep(2)
		D.open(1)
		D.locked = 1
		D.update_icon()

	proc/airlockClose(var/obj/machinery/door/airlock/D)
		D.locked = 0
		D.close(1)
		D.locked = 1
		D.update_icon()
		sleep(2)

	proc/airlockPressurize(var/obj/machinery/atmospherics/unary/vent_pump/P)
		//pressurize
		P.pump_direction = 1	//release
		P.external_pressure_bound = ONE_ATMOSPHERE
		P.pressure_checks = 1	//Do not pass external_pressure_bound
		P.on = 1
		P.update_icon()


	proc/airlockDepressurize(var/obj/machinery/atmospherics/unary/vent_pump/P)
		//depressurize
		//var/target_pressure = ONE_ATMOSPHERE*0.05
		//if(sanitize_external)
		//	target_pressure = ONE_ATMOSPHERE*0.01
		P.pump_direction = 0	//siphon
		P.external_pressure_bound = 0
		P.pressure_checks = 0	//Do not pass external_pressure_bound
		P.on = 1
		P.update_icon()


	proc/return_text()
		var/dat = ""
		var/sclosed = "border:2px solid DarkRed;background-color:red"
		var/sopen = "border:2px solid DarkGreen;background-color:green"
		if(formatted || parent)
			page = 2
		update_icon()
		switch(page)	//This is the basic configuration page
			if(0)
				dat += "<h3>Device Status</h3>"
				dat += text("<table width='100%'>")
				dat += text("<tr><td width='50%'>")
				dat += text("<div align='center' width='20%'style='[formatted? sopen : sclosed]'>[formatted? "online" : "offline"]</span></td></tr>")
				dat += text("</tr></table>")
				dat += "<h3>Maintenance</h3>"
				dat += "<table width='100%'>"
				dat += text("<tr><td width='50%'><A href='?src=\ref[src];action=0;item=\ref[src];='>Activate Console</A></td></tr>")
				dat += text("<tr><td width='50%'><A href='?src=\ref[src];action=-1;item=\ref[src];='>Disable Doors</A></td></tr>")
				dat += text("<tr><td width='50%'><A href='?src=\ref[src];page=3'>Slave Console</A></td></tr>")
				if(parent)
					return
				dat += text("<tr><td width='50%'><A href='?src=\ref[src];page=2'>Access Control Console</A></td></tr>")
				dat += text("</tr></table>")
				dat += "<h3>Network Connections</h3>"
				dat += "<table width='100%'>"
				dat += text("<tr><td width='25%'>Exterior Door</td>")
				dat += text("<td width='25%'>[exterior_door? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];page=1;option=1'>[exterior_door? "replace" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Interior Door</td>")
				dat += text("<td width='25%'>[interior_door? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];page=1;option=2'>[interior_door? "replace" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Sensor</td>")
				dat += text("<td width='25%'>[air_sensor? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];page=1;option=3'>[air_sensor? "replace" : "link"]</A></td></tr>")
				dat += text("<tr><td width='25%'>Airpump</td>")
				dat += text("<td width='25%'>[air_pump? "<span class='good'>active</span>" : "<span class='bad'>inactive</span>"]</span></td>")
				dat += text("<td width='25%'><A href='?src=\ref[src];page=1;option=4'>[air_pump? "replace" : "link"]</A></td></tr>")
				dat += text("</table>")
			if(1)
				dat += "<h3>Select [(option == 1)? "Exterior Door":""][(option == 2)? "Interior Door":""][(option == 3)? "Sensor":""][(option == 4)? "Air Pump":""]</h3>"
				dat += "<table width='100%'>"
				var/list/L = range(5, src)
				var/isLinked

				switch(option)
					if(1)
						for(var/obj/machinery/door/airlock/D in L)
							if(exterior_door)
								isLinked = (D == exterior_door)
							else
								isLinked = 0
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[D.locked? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=1'>[isLinked? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(2)
						for(var/obj/machinery/door/airlock/D in L)
							if(interior_door)
								isLinked = (D == interior_door)
							else
								isLinked = 0
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[D.locked? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=2'>[isLinked? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(3)
						for(var/obj/machinery/airlock_sensor_wired/D in L)
							if(air_sensor)
								isLinked = (D == air_sensor)
							else
								isLinked = 0
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>[D.parent? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=3'>[isLinked? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
					if(4)
						for(var/obj/machinery/atmospherics/unary/vent_pump/D in L)
							if(air_pump)
								isLinked = (D == air_pump)
							else
								isLinked = 0
							dat += text("<tr>")
							dat += text("<td width='50%'>[D.name]</td>")
							dat += text("<td width='25%'><span class='good'>Unknown</span></td>")
							dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=4'>[isLinked? "unlink" : "link"]</A></td>")
							dat += text("</tr>")
				dat += text("</table><A href='?src=\ref[src];page=0'>Back to Configuration Menu</A>")
			if(2)
				airlockState()

				//var/blcolor = "#ffeeee" //banned light
				//var/bdcolor = "#ffdddd" //banned dark
				//var/ulcolor = "#eeffee" //unbanned light
				//var/udcolor = "#ddffdd" //unbanned dark
				var/style_pressure
				var/style_temp
				var/stylepump

				if(exterior_door)
					exterior_status = exterior_door.density?("closed"):("open")
				if(interior_door)
					interior_status = interior_door.density?("closed"):("open")

				if(parent)
					state = parent.state

				dat += text("<h3>Control Console</h3>")
				dat += text("[parent? "<span class='Good'>SLAVE CONSOLE</span>": ""]")
				dat += text("<table width='100%'>")

				switch(state)
					if(AIRLOCK_STATE_INTERIOR)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_closed'>Close Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A></td></tr>")
					if(AIRLOCK_STATE_PRESSURIZE)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=abort'>Abort Cycling</A></td></tr>")
					if(AIRLOCK_STATE_SEALED)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_interior'>Open Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_exterior'>Open Exterior Airlock</A></td></tr>")
					if(AIRLOCK_STATE_DEPRESSURIZE)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=abort'>Abort Cycling</A></td></tr>")
					if(AIRLOCK_STATE_EXTERIOR)
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A></td></tr>")
						dat += text("<tr><td width='100%'><A href='?src=\ref[src];command=cycle_closed'>Close Exterior Airlock</A></td></tr>")
					if(AIRLOCK_STATE_CONFIG)
						if(!parent)
							dat += text("<tr><td width='100%'><A href='?src=\ref[src];page=0'>Configure Console</A></td></tr>")

				//pressure
				if(air_sensor.pressure > 90)
					style_pressure = "good"
				else
					if(air_sensor.pressure > 50)
						style_pressure = "average"
					else
						style_pressure = "bad"

				//temperature
				if(air_sensor.temperature > 15)
					style_temp = "good"
				else
					if(air_sensor.temperature > 5)
						style_temp = "average"
					else
						style_temp = "bad"

				if(air_pump.on)
					pump_status = air_pump.pump_direction?("release"):("siphon")
				else
					pump_status = "off"

				switch(pump_status)
					if("siphon")
						stylepump = sopen
					if("release")
						stylepump = sopen
					if("off")
						stylepump = sclosed

				dat += text("</table>")
				dat += text("<h3>Chamber Environment</h3>")
				dat += text("<table width='100%'>")
				dat += text("<tr><td width='50%'>Pressure</td><td width='50%'><b><span class='[style_pressure]'>[air_sensor.pressure]</b></span> kPa</td></tr>")
				dat += text("<tr><td width='50%'>Temperature</td><td width='50%'><b><span class='[style_temp]'>[air_sensor.temperature]</b></span>&deg;C</td></tr>")
				dat += text("</table>")
				dat += text("<h3>Airlock Status</h3>")
				dat += text("<table width='100%'>")
				dat += text("<tr><td width='50%'>Exterior Door</td><td width='50%'><div align='center' width='20%'style='[(exterior_status == "open")? sopen : sclosed]'>[exterior_status]</div></td></tr>")
				dat += text("<tr><td width='50%'>Interior Door</td><td width='50%'><div align='center' width='20%'style='[(interior_status == "open")? sopen : sclosed]'>[interior_status]</div></td></tr>")
				dat += text("<tr><td width='50%'>Control Pump</td><td width='50%'><div align='center' width='20%'style='[stylepump]'>[pump_status]</div></td></tr>")
				dat += text("</table>")
				//dat += text("</table><A href='?src=\ref[src];page=0'>Back to Configuration Menu</A>")
			if(3)
				dat += "<h3>Select a console to slave to</h3>"
				dat += "<table width='100%'>"
				var/isLinked
				var/list/L = range(5, src)
				for(var/obj/machinery/airlock_console/D in L)
					if(parent)
						isLinked = (D == parent)
					else
						isLinked = 0
					if(D != src)
						dat += text("<tr>")
						dat += text("<td width='50%'>[D.name]</td>")
						dat += text("<td width='25%'><span class='good'>[D.parent? "<span class='bad'>in use</span>" : "<span class='good'>available</span>"]</span></td>")
						dat += text("<td width='25%'><A href='?src=\ref[src];item=\ref[D];action=5'>[isLinked? "unlink" : "link"]</A></td>")
						dat += text("</tr>")
				dat += text("</table><A href='?src=\ref[src];page=0'>Back to Configuration Menu</A>")
		return dat

	attack_hand(mob/user)
		var/datum/browser/popup = new(user, "airlock", "Airlock Control", 300, 420)

		popup.set_content(return_text())
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return

	Topic(href, href_list)
		if(..())
			return 0
		//var/datum/computer/file/embedded_program/airlock_controller/P = program

		if(href_list["action"])
			//usr << "doing action!! )]"
			if(href_list["item"])
				switch(text2num(href_list["action"]))
					if(-1)
						var/obj/machinery/door/airlock/DE = exterior_door
						var/obj/machinery/door/airlock/DI = interior_door
						airlockClose(DE)
						airlockClose(DI)
						sleep(2)
						DE.locked = !DE.locked
						DI.locked = !DI.locked
						DE.update_icon()
						DI.update_icon()

						page = 2
					if(0)
						if(exterior_door && interior_door && air_sensor && air_pump)
							formatted = 1
							pump_status = "off"	//should probably make a check for this...
							state = AIRLOCK_STATE_SEALED
							target_state = AIRLOCK_STATE_SEALED
							update_icon()
						page = 0
					if(1)
						var/obj/machinery/door/airlock/O = locate(href_list["item"])
						exterior_door = O
						O.locked = 1
						O.icon_state = "door_locked"
						O.autoclose = 0
						if(!O.density)			//door is closed
							airlockClose(O)		//ask to close door
						page = 0
					if(2)
						var/obj/machinery/door/airlock/O = locate(href_list["item"])
						interior_door = O
						O.locked = 1
						O.icon_state = "door_locked"
						O.autoclose = 0
						if(!O.density)			//door is closed
							airlockClose(O)		//ask to close door
						page = 0
					if(3)
						var/obj/machinery/airlock_sensor/O = locate(href_list["item"])
						air_sensor = O
						page = 0
					if(4)
						var/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/O = locate(href_list["item"])
						air_pump = O
						page = 0
					if(5)
						var/obj/machinery/airlock_console/O = locate(href_list["item"])
						parent = O
						exterior_door = parent.exterior_door
						interior_door = parent.interior_door
						air_pump = parent.air_pump
						air_sensor = parent.air_sensor
						page = 0
			src.updateUsrDialog()

		if(href_list["page"])
			//usr << "changing page!!"
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
				if(3)
					page = 3
					option = 0
			src.updateUsrDialog()

		if(href_list["command"])
			//usr << "action!!"
			var/command = href_list["command"]

			if(!air_sensor || !air_pump)	//if no sensor, leave
				return

			if(!istype(air_sensor, /obj/machinery/airlock_sensor_wired) || !istype(air_pump, /obj/machinery/atmospherics/unary/vent_pump))	//if no sensor, leave
				return

			if(command == "cycle_interior")
				target_state = AIRLOCK_STATE_INTERIOR
				processing = 1

			if(command == "cycle_exterior")
				target_state = AIRLOCK_STATE_EXTERIOR
				processing = 1

			if(command == "cycle_closed")
				target_state = AIRLOCK_STATE_SEALED
				processing = 1

			if(command == "cycle_vent")
				target_state = AIRLOCK_STATE_VENT
				processing = 1

			if(command == "abort")
				target_state = AIRLOCK_STATE_SEALED
				processing = 1

			//setup parenting
			if(parent)
				parent.target_state = target_state
			update_icon()
			src.updateUsrDialog()
		//if(program)
		//	program.receive_user_command(href_list["command"])
		//	spawn(5) program.process()

		usr.set_machine(src)
		//spawn(5) src.updateUsrDialog()

	process()
		..()
		var/process_again = 1
		if(parent)
			state = parent.state
			target_state = parent.target_state
		if(formatted)	//if no sensor, leave
			while(process_again)
				src.updateUsrDialog()
				process_again = 0
				switch(state)

					if(AIRLOCK_STATE_SEALED)	//here now
						if(target_state < state)
							//Exterior
							if(interior_door.density)
								state = AIRLOCK_STATE_DEPRESSURIZE
								process_again = 1
							else
								airlockClose(interior_door)
						else if(target_state > state)
							//interior
							if(exterior_door.density)
								state = AIRLOCK_STATE_PRESSURIZE
								process_again = 1
							else
								airlockClose(exterior_door)
						else
							air_pump.on = 0
							air_pump.update_icon()
							processing = 0
							update_icon()

					if(AIRLOCK_STATE_PRESSURIZE)
						if(target_state > state)
							if(air_sensor.pressure >= ONE_ATMOSPHERE*0.95)
								air_pump.on = 0
								if(!interior_door.density)
									state = AIRLOCK_STATE_INTERIOR
									process_again = 1
								else
									airlockOpen(interior_door)
							else
								airlockPressurize(air_pump)
						else
							state = AIRLOCK_STATE_SEALED
							process_again = 1

					if(AIRLOCK_STATE_INTERIOR)
						if(target_state < state)	//2 to -2 yes
							if(interior_door.density)
								state = AIRLOCK_STATE_SEALED
								process_again = 1
							else
								airlockClose(interior_door)
						else
							air_pump.on = 0
							air_pump.update_icon()
							processing = 0
							update_icon()

					if(AIRLOCK_STATE_DEPRESSURIZE)
						var/target_pressure = ONE_ATMOSPHERE*0.05
						if(sanitize_external)
							target_pressure = ONE_ATMOSPHERE*0.01

						if(air_sensor.pressure <= target_pressure)
							if(target_state < state)
								if(!exterior_door.density)
									state = AIRLOCK_STATE_EXTERIOR
								else
									airlockOpen(exterior_door)
							else if(target_state < state)
								state = AIRLOCK_STATE_SEALED
								process_again = 1
						else if((target_state > state) && !sanitize_external)
							state = AIRLOCK_STATE_SEALED
							process_again = 1
						else
							airlockDepressurize(air_pump)

					if(AIRLOCK_STATE_EXTERIOR)
						if(target_state > state)
							if(exterior_door.density)
								if(sanitize_external)
									state = AIRLOCK_STATE_DEPRESSURIZE
									process_again = 1
								else
									state = AIRLOCK_STATE_SEALED
									process_again = 1

							else
								airlockClose(exterior_door)
						else
							air_pump.on = 0
							air_pump.update_icon()
							processing = 0
							update_icon()
				return 1
		processing = 0
		update_icon()
		src.updateUsrDialog()
/*
###################
	SENSORS
###################
*/
obj/machinery/airlock_sensor_wired
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "airlock sensor (wired)"

	anchored = 1
	power_channel = ENVIRON

	var/id_tag
	var/pressure = 0
	var/temperature = 0
	var/on = 1
	var/alert = 0
	var/parent
	var/idle = 1
	var/tdir

	New(turf/loc, var/ndir, var/building=0)
		..()
		if (building)
			// offset 24 pixels in direction of dir
			// this allows the APC to be embedded in a wall, yet still inside an area
			dir = ndir
			src.tdir = dir		// to fix Vars bug
			dir = SOUTH

			pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
			pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0

	update_icon()
		if(on)
			if(alert)
				icon_state = "airlock_sensor_alert"
			else
				icon_state = "airlock_sensor_standby"
		else
			icon_state = "airlock_sensor_off"

	process()
		if(on)
			var/datum/gas_mixture/air_sample = return_air()
			pressure = round(air_sample.return_pressure(),0.1)
			temperature = round(air_sample.temperature,0.1) - 273.15
			alert = (pressure < ONE_ATMOSPHERE*0.8)
		update_icon()

/*
###################
	PUMPS
###################


/obj/machinery/atmospherics/binary/dp_vent_pump/airlock_pump
	icon = 'icons/obj/atmospherics/dp_vent_pump.dmi'
	icon_state = "off"

	//node2 is output port
	//node1 is input port

	name = "Dual Port Air Vent (wired)"
	desc = "Has a valve and pump attached to it. There are two ports."
	var/parent

	level = 1

	New()
	..()
	air1.volume = 1000
	air2.volume = 1000
	initial_loc = get_area(loc)
	if (initial_loc.master)
		initial_loc = initial_loc.master
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	if(ticker && ticker.current_state == 3)//if the game is running
		src.initialize()
		src.broadcast_status()


	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (!(stat & NOPOWER) && on)
			user << "\red You cannot unwrench this [src], turn it off first."
			return 1
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)

	update_icon()
		if(on)
			if(pump_direction)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0

		return

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on)
			if(pump_direction)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return

	process()
		..()

		if(!on)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()
		var/environment_pressure = environment.return_pressure()
		var/pressure_delta = 10000

		if(pump_direction) //input -> external

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

			if(pressure_delta > 0)
				if(air1.temperature > 0)
					var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = air1.remove(transfer_moles)

					loc.assume_air(removed)

					if(network1)
						network1.update = 1

		else //external -> output

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
			if(pressure_checks&4)
				pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

			if(pressure_delta > 0)
				if(environment.temperature > 0)
					var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

					air2.merge(removed)

					if(network2)
						network2.update = 1
		return 1
*/