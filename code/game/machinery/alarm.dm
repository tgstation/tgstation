/obj/machinery/alarm

	var/frequency = 1439
	var/list/sensors = list()
	var/list/vents = list()
	var/list/sensor_information = list()
	var/list/vent_information = list()
	var/datum/radio_frequency/radio_connection
	var/alarm_area //Currently unused. Maybe do something if emmaged or hacked...Like change the area to security, syphon air out, ..., profit.
	var/locked = 1
	var/panic = 0 //is this alarm panicked?
	var/device = null

	req_access = list(access_atmospherics)

	attack_hand(mob/user)
		if(!(istype(usr, /mob/living/silicon) || istype(usr, /mob/living/carbon/human)))
			user << "\red You don't have the dexterity to do this."
			return
		if(stat & (NOPOWER|BROKEN))
			return

		//Following is no longer needed, as all human/silicon mobs will be able to view air info.
		/*else if(!(istype(usr, /mob/living/silicon)) && locked)
			user << "\red You must unlock the Air Alarm interface first"
			return*/
		src.add_fingerprint(user)

		user << browse(return_text(),"window=air_alarm")
		user.machine = src
		onclose(user, "air_alarm")
		return


	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/id_tag = signal.data["tag"]
		if(!id_tag || (!sensors.Find(id_tag) && !vents.Find(id_tag))) return
		if(signal.data["device"] == "AScr")
			sensor_information[id_tag] = signal.data
		else if(signal.data["device"] == "AVP")
			vent_information[id_tag] = signal.data

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")


		send_signal(var/target, var/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src

			signal.data["tag"] = target
			signal.data["command"] = command

			radio_connection.post_signal(src, signal)
//			world << text("Signal [] Broadcasted to []", command, target)

			return 1

		return_text()
			if(!(istype(usr, /mob/living/silicon)) && locked)
				return "<html><head><title>[alarm_zone] Air Alarm</title></head><body>[return_status()]<hr><i>(Swipe ID card to unlock interface)</i></body></html>"
			else
				return "<html><head><title>[alarm_zone] Air Alarm</title></head><body>[return_status()]<hr>[return_controls()]</body></html>"

		return_status()
			var/turf/location = src.loc
			var/area/A = src.loc
			A = A.loc
			var/datum/gas_mixture/environment = location.return_air()
			var/environment_pressure = environment.return_pressure()
			var/total = environment.oxygen + environment.carbon_dioxide + environment.toxins + environment.nitrogen
			var/safe = 2
			var/percent
			var/output = "<b>Air Status:</b><br>"

			if(total == 0)
				output +={"<font color='red'><b>Warning: Cannot obtain air sample for analysis.</b></font>"}
				return output

			output += {"Pressure: "}
			//Pressure sensor
			if((environment_pressure < ONE_ATMOSPHERE*0.90) || (environment_pressure > ONE_ATMOSPHERE*1.10))
				if((environment_pressure < ONE_ATMOSPHERE*0.80) || (environment_pressure > ONE_ATMOSPHERE*1.20))
					output += {"<font color='red'><b>[environment_pressure]</b></font>kPa<br>"}
					safe = 0
				else
					output += {"<font color='orange'>[environment_pressure]</font>kPa<br>"}
					if(safe != 0) safe = 1
			else
				output+= {"<font color='green'>[environment_pressure]</font>kPa<br>"}

			output += {"Oxygen: "}
			//Oxygen Levels Sensor
			percent = round(environment.oxygen / total * 100, 2)
			if((environment.oxygen < MOLES_O2STANDARD*0.90) || (environment.oxygen > MOLES_O2STANDARD*1.10))
				if(environment.oxygen < MOLES_O2STANDARD*0.80)
					output += {"<font color='red'><b>[percent]</b></font>%<br>"}
					safe = 0
				else
					output += {"<font color='orange'>[percent]</font>%<br>"}
					if(safe != 0) safe = 1
			else	output += {"<font color='green'>[percent]</font>%<br>"}

			output += {"Carbon: "}
			percent = round(environment.carbon_dioxide / total * 100, 2)
			//CO2 Levels Sensor
			if(environment.carbon_dioxide > 5)
				if(environment.carbon_dioxide > 10)
					output += {"<font color='red'><b>[percent]</b></font>%<br>"}
					safe = 0
				else
					output+= {"<font color='orange'>[percent]</font>%<br>"}
					if(safe != 0) safe = 1
			else output += {"<font color='green'>[percent]</font>%<br>"}

			output += {"Toxins: "}
			//Plasma Levels Sensor
			percent = round(environment.toxins / total * 100, 2)
			if(safe && (environment.toxins > 1))
				if(environment.toxins > 2)
					output += {"<font color='red'><b>[percent]</b></font>%<br>"}
					safe = 0
				else
					output += {"<font color='orange'>[percent]</font>%<br>"}
					if(safe != 0) safe = 1
			else output += {"<font color='green'>[percent]</font>%<br>"}

			//Trace Gas Sensor
			if(safe && environment.trace_gases.len)
				for(var/datum/gas/sleeping_agent/SA in environment.trace_gases)
					var/SA_pp = (SA.moles/environment.total_moles())*environment_pressure
					if(SA_pp > 0.01)
						if(SA_pp > 1)
							output += {"Notice: <font color='red'>High Concentration of Unknown Particles Detected</font><br>"}
							safe = 0
						else
							output += {"Notice: <font color='orange'>Low Concentration of Unknown Particles Detected</font><br>"}
							safe = 1

			output += {"Temperature: "}
			//Temperature Levels Sensor
			if((environment.temperature < (T20C-10)) || (environment.temperature > (T20C+10)))
				if((environment.temperature < (T20C-20)) || (environment.temperature > (T20C+10)))
					output += {"<font color='red'><b>[environment.temperature]</b></font>K<br>"}
					safe = 0
				else
					output +={"<font color='orange'>[environment.temperature]</font>K<br>"}
			else output += {"<font color='green'>[environment.temperature]</font>K<br>"}

			//Overall status
			output += {"Local Status: "}
			if(safe == 0) output += {"<font color='red'><b>DANGER: Internals Required</b></font>"}
			else if(safe == 1) output += {"<font color='orange'>Caution</font>"}
			else if (A.atmosalm == 1) output += {"<font color='orange'>Caution: Atmos alert in area</font>"}
			else output += {"<font color='green'>Optimal</font>"}

			return output


		return_controls()
			var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"
			if(!src.device)
				var/area/A = src.loc
				A = A.loc
				if(A.atmosalm)
					output += {"<a href='?src=\ref[src];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"}
				else
					output += {"<a href='?src=\ref[src];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"}

				output += {"<a href='?src=\ref[src];scrubbers_control=1'>Scrubbers Control</a><br>
						<a href='?src=\ref[src];vents_control=1'>Vents Control</a><br>
						<HR>
						"}

				output += "<A href='?src=\ref[src];toggle_panic_siphon_global=1'><font color='red'><B>TOGGLE PANIC SYPHON IN AREA</B></font></A>"
				output += "<HR><A href='?src=\ref[src];reinit_atmos_machinery=1'>Reinitialize atmospheric machinery in area</A>"
			else
				var/sensor_data
				if(src.device == "Scrubbers")
					if(sensors.len)
						for(var/id_tag in sensors)
							var/long_name = sensors[id_tag]
							var/list/data = sensor_information[id_tag]
							var/sensor_part = "<B>[long_name]</B>:<BR>"

							if(data)
								sensor_part += {"<B>Operating:</B> <A href='?src=\ref[src];scr_toggle_power=[id_tag]'>[(data["on"]?"on":"off")]</A><BR>
												<B>Type:</B> <A href='?src=\ref[src];scr_toggle_scrubbing=[id_tag]'>[(data["scrubbing"]?"scrubbing":"syphoning")]</A><BR>"}
								if(data["scrubbing"])
									sensor_part += "<B>Filtering:</B> Carbon Dioxide <A href='?src=\ref[src];scr_toggle_co2_scrub=[id_tag]'>([(data["filter_co2"]?"on":"off")])</A>; Toxins <A href='?src=\ref[src];scr_toggle_tox_scrub=[id_tag]'>([data["filter_toxins"]?"on":"off"])</A>; Nitrous Oxide <A href='?src=\ref[src];scr_toggle_n2o_scrub=[id_tag]'>([data["filter_n2o"]?"on":"off"])</A><BR>"
								sensor_part += "<A href='?src=\ref[src];scr_toggle_panic_siphon=[id_tag]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate panic syphon</A></font><BR>"
								if(data["panic"])
									sensor_part += "<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>"
								sensor_part += "<HR>"
							else
								sensor_part = "<FONT color='red'>[long_name] can not be found!</FONT><BR><HR>"

							sensor_data += sensor_part
					else
						sensor_data = "No scrubbers connected.<BR>"

				else if(src.device == "Vents")
					if(vents.len)
						for(var/id_tag in vents)
							var/long_name = vents[id_tag]
							var/list/data = vent_information[id_tag]
							var/sensor_part = "<B>[long_name]</B>:<BR>"

							if(data)
								sensor_part += {"<B>Operating:</B> <A href='?src=\ref[src];v_toggle_power=[id_tag]'>[data["power"]]</A><BR>
												<B>Pressure checks:</B> <A href='?src=\ref[src];v_toggle_checks=[id_tag]'>[data["checks"]?"on":"off"]</A><BR>
												<HR>"}
							else
								sensor_part = "<FONT color='red'>[long_name] can not be found!</FONT><HR>"

							sensor_data += sensor_part
					else
						sensor_data = "No scrubbers connected.<BR>"

				output = {"[sensor_data]<a href='?src=\ref[src];main=1'>Main menu</a><br>"}

			return output

		alarm()
			var/area/A = src.loc
			A = A.loc
			if (!( istype(A, /area) ))
				return
			for(var/area/RA in A.related)
				RA.atmosalert()
			return
		reset()
			var/area/A = src.loc
			A = A.loc
			if (!( istype(A, /area) ))
				return
			for(var/area/RA in A.related)
				RA.atmosreset()
			return

	initialize()
		set_frequency(frequency)


	Topic(href, href_list)
		//if(..())
		//	return
		if(href_list["atmos_alarm"])
			src.alarm()
		if(href_list["atmos_reset"])
			src.reset()
		if(href_list["scrubbers_control"])
			src.device = "Scrubbers"
		if(href_list["vents_control"])
			src.device = "Vents"
		if(href_list["main"])
			src.device = null
		if(href_list["scr_toggle_power"])
			send_signal(href_list["scr_toggle_power"], "toggle_power")

		if(href_list["scr_toggle_scrubbing"])
			send_signal(href_list["scr_toggle_scrubbing"], "toggle_scrubbing")

		if(href_list["scr_toggle_co2_scrub"])
			send_signal(href_list["scr_toggle_co2_scrub"], "toggle_co2_scrub")

		if(href_list["scr_toggle_tox_scrub"])
			send_signal(href_list["scr_toggle_tox_scrub"], "toggle_tox_scrub")

		if(href_list["scr_toggle_n2o_scrub"])
			send_signal(href_list["scr_toggle_n2o_scrub"], "toggle_n2o_scrub")

		if(href_list["scr_toggle_panic_siphon"])
			send_signal(href_list["scr_toggle_panic_siphon"], "toggle_panic_siphon")

		if(href_list["v_toggle_power"])
			send_signal(href_list["v_toggle_power"], "power_toggle")
		if(href_list["v_toggle_checks"])
			send_signal(href_list["v_toggle_checks"], "toggle_checks")

		if(href_list["toggle_panic_siphon_global"])
			for(var/V in sensors)
				send_signal(V, "toggle_panic_siphon")
			for(var/P in vents)
				send_signal(P, "power_off")
			panic = !panic
		if(href_list["reinit_atmos_machinery"])
			var/A = get_area(loc)
			connect_area_atmos_machinery(A)


		spawn(5)
//			attack_hand(usr)
			src.updateUsrDialog()
		return


/obj/machinery/alarm/New()
	..()

	if(!alarm_zone)
		var/area/A = get_area(loc)
		if(A.name)
			alarm_zone = A.name
		else
			alarm_zone = "Unregistered"

/obj/machinery/alarm/process()
	if (src.skipprocess)
		src.skipprocess--
		return

	var/turf/location = src.loc
	var/area/A = src.loc
	A = A.loc
	var/safe = 2

	if(stat & (NOPOWER|BROKEN))
		icon_state = "alarmp"
		return

	use_power(5, ENVIRON)

	if (!( istype(location, /turf) ))
		return 0

	var/datum/gas_mixture/environment = location.return_air()

	var/environment_pressure = environment.return_pressure()

	if((environment_pressure < ONE_ATMOSPHERE*0.90) || (environment_pressure > ONE_ATMOSPHERE*1.10))
		//Pressure sensor
		if((environment_pressure < ONE_ATMOSPHERE*0.80) || (environment_pressure > ONE_ATMOSPHERE*1.20))
			safe = 0
		else safe = 1

	if(safe && ((environment.oxygen < MOLES_O2STANDARD*0.90) || (environment.oxygen > MOLES_O2STANDARD*1.10)))
		//Oxygen Levels Sensor
		if(environment.oxygen < MOLES_O2STANDARD*0.80)
			safe = 0
		else safe = 1

	if(safe && ((environment.temperature < (T20C-10)) || (environment.temperature > (T20C+10))))
		//Oxygen Levels Sensor
		if((environment.temperature < (T20C-20)) || (environment.temperature > (T20C+10)))
			safe = 0
		else safe = 1

	if(safe && (environment.carbon_dioxide > 5))
		//CO2 Levels Sensor
		if(environment.carbon_dioxide > 10)
			safe = 0
		else safe = 1

	if(safe && (environment.toxins > 1))
		//Plasma Levels Sensor
		if(environment.toxins > 2)
			safe = 0
		else safe = 1

	if(safe && environment.trace_gases.len)
		for(var/datum/gas/sleeping_agent/SA in environment.trace_gases)
			var/SA_pp = (SA.moles/environment.total_moles())*environment_pressure
			if(SA_pp > 0.01)
				if(SA_pp > 1)
					safe = 0
				else safe = 1


	if(safe && A.atmosalm)
		safe = 1

	if(!safe)
		src.icon_state = "alarm1"
	else if(safe == 1)
		src.icon_state = "alarm2"
	else
		src.icon_state = "alarm0"


	if(safe == 2) src.skipprocess = 1
	else if(alarm_frequency)
		post_alert(safe)

	if(!safe)
		if (!( istype(A, /area) ))
			return
		A.atmosalert()

	return

/obj/machinery/alarm/proc/post_alert(alert_level)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)

	if(!frequency) return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==0)
		alert_signal.data["alert"] = "severe"
	else
		alert_signal.data["alert"] = "minor"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/attackby(W as obj, user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		stat ^= BROKEN
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		return

	else if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
		if(stat & (NOPOWER|BROKEN))
			user << "It does nothing"
		else
			if(src.allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] the Air Alarm interface."
			else
				user << "\red Access denied."
		return
	return ..()

/obj/machinery/alarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/*/obj/machinery/alarm/Click()
	if(istype(usr, /mob/living/silicon/ai))
		return examine()
	return ..()*/

/obj/machinery/alarm/examine()
	set src in oview(1)
	/*
	if(usr.stat)
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!(istype(usr, /mob/living/carbon/human) || ticker))
		if (!istype(usr, /mob/living/silicon/ai))
			usr << "\red You don't have the dexterity to do this!"
			return
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai))
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			return

		var/turf_total = T.co2 + T.oxygen + T.poison + T.sl_gas + T.n2
		turf_total = max(turf_total, 1)
		usr.show_message("\blue <B>Results:</B>", 1)
		var/t = ""
		var/t1 = turf_total / CELLSTANDARD * 100
		if ((90 < t1 && t1 < 110))
			usr.show_message(text("\blue Air Pressure: []%", t1), 1)
		else
			usr.show_message(text("\blue Air Pressure:\red []%", t1), 1)
		t1 = T.n2 / turf_total * 100
		t1 = round(t1, 0.0010)
		if ((60 < t1 && t1 < 80))
			t += text("<font color=blue>Nitrogen: []</font> ", t1)
		else
			t += text("<font color=red>Nitrogen: []</font> ", t1)
		t1 = T.oxygen / turf_total * 100
		t1 = round(t1, 0.0010)
		if ((20 < t1 && t1 < 24))
			t += text("<font color=blue>Oxygen: []</font> ", t1)
		else
			t += text("<font color=red>Oxygen: []</font> ", t1)
		t1 = T.poison / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 0.5)
			t += text("<font color=blue>Plasma: []</font> ", t1)
		else
			t += text("<font color=red>Plasma: []</font> ", t1)
		t1 = T.co2 / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 1)
			t += text("<font color=blue>CO2: []</font> ", t1)
		else
			t += text("<font color=red>CO2: []</font> ", t1)
		t1 = T.sl_gas / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 5)
			t += text("<font color=blue>NO2: []</font>", t1)
		else
			t += text("<font color=red>NO2: []</font>", t1)
		t1 = T.temp - T0C
		if (T.temp > 326.444 || T.temp < 282.591)
			t += text("<br><font color=red>Temperature: []</font>", t1)
		else
			t += text("<br><font color=blue>Temperature: []</font>", t1)
		usr.show_message(t, 1)
		return
	else
		usr << "\blue <B>You are too far away.</B>"
	*/


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

	use_power(10, ENVIRON)

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
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
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
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Fire alarm"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
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
