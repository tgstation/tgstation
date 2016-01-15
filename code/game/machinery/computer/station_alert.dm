
/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/weapon/circuitboard/stationalert
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	if(..())
		return
	interact(user)
	return


/obj/machinery/computer/station_alert/interact(mob/user)
	usr.set_machine(src)
	var/dat = ""
	for (var/cat in src.alarms)
		dat += text("<h2>[]</h2>", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "&bull; "
				dat += "[format_text(A.name)]"
				if (sources.len > 1)
					dat += text(" - [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"
	//user << browse(dat, "window=alerts")
	//onclose(user, "alerts")
	var/datum/browser/popup = new(user, "alerts", "Station Alert Console")
	popup.add_head_content("<META HTTP-EQUIV='Refresh' CONTENT='10'>")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/station_alert/Topic(href, href_list)
	if(..())
		return
	return


/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, O, obj/alarmsource)
	if(alarmsource.z != z)
		return
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
	L[A.name] = list(A, (C ? C : O), list(alarmsource))
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
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
	update_icon()
	..()
	return

/obj/machinery/computer/station_alert/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	var/active_alarms = 0
	for (var/cat in src.alarms)
		var/list/L = src.alarms[cat]
		if(L.len) active_alarms = 1
	if(active_alarms)
		overlays += "alert:2"