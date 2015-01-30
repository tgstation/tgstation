
/obj/machinery/computer/station_alert
	name = "Station Alert Computer"
	desc = "Used to access the station's automated alert system."
	icon_state = "alert:0"
	circuit = "/obj/item/weapon/circuitboard/stationalert"
	l_color = "#7BF9FF"

	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())

	var/list/covered_areas = list()

	var/general_area_name = "Station"

/obj/machinery/computer/station_alert/New()
	..()
	if(src.z != map.zMainStation)
		var/area/A = src.areaMaster
		if(!A)
			A = get_area(src)
		if(!A)
			return
		name = "[A.general_area_name] Alert Computer"
		general_area_name = A.general_area_name

		for(var/areatype in typesof(A.general_area))
			var/area/B = locate(areatype)

			covered_areas += B

	else//very ugly fix until all the main station's areas inherit from /area/station/
		var/blockedtypes = typesof(/area/research_outpost,/area/mine,/area/derelict,/area/djstation,/area/vox_trading_post,/area/tcommsat)
		for(var/atype in (typesof(/area) - blockedtypes))
			var/area/B = locate(atype)

			covered_areas += B

	for(var/area/A in covered_areas)
		A.sendDangerLevel(src)
		A.send_firealert(src)
		A.send_poweralert(src)

/obj/machinery/computer/station_alert/attack_ai(mob/user)
	src.add_hiddenprint(user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)
	return


/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)
	return


/obj/machinery/computer/station_alert/interact(mob/user)
	usr.set_machine(src)

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\station_alert.dm:29: var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	var/dat = {"<HEAD><TITLE>Current [general_area_name] Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
	<A HREF='?src=\ref[user];mach_close=alerts'>Close</A><br><br>"}
	// END AUTOFIX
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\station_alert.dm:39: dat += "<NOBR>"
				dat += {"<NOBR>
					&bull;
					[A.name]"}
				// END AUTOFIX
				if (sources.len > 1)
					dat += text(" - [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"
	user << browse(dat, "window=alerts")
	onclose(user, "alerts")


/obj/machinery/computer/station_alert/Topic(href, href_list)
	if(..())
		return
	return


/obj/machinery/computer/station_alert/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(stat & (BROKEN))
		return
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(stat & (BROKEN))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	return !cleared


/obj/machinery/computer/station_alert/process()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "atmos0"
		return
	var/active_alarms = 0
	for (var/cat in src.alarms)
		var/list/L = src.alarms[cat]
		if(L.len) active_alarms = 1
	if(active_alarms)
		icon_state = "alert:2"
	else
		icon_state = "alert:0"
	..()
	return
