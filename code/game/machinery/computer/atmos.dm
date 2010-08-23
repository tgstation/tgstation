/*CONTENTS
Gas Sensor
Siphon computer
Atmos alert computer
*/



//the atmos alerts computer
/obj/machinery/computer/atmosphere/alerts/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/atmosphere/alerts/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/atmosphere/alerts/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/atmospherealerts/M = new /obj/item/weapon/circuitboard/atmospherealerts( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/atmospherealerts/M = new /obj/item/weapon/circuitboard/atmospherealerts( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return


/obj/machinery/computer/atmosphere/alerts/proc/interact(mob/user)
	usr.machine = src
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[user];mach_close=alerts'>Close</A><br><br>"
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "[A.name]"
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"
	user << browse(dat, "window=alerts")
	onclose(user, "alerts")

/obj/machinery/computer/atmosphere/alerts/Topic(href, href_list)
	if(..())
		return
	return

/obj/machinery/computer/atmosphere/alerts/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(stat & (BROKEN|NOPOWER))
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

/obj/machinery/computer/atmosphere/alerts/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(stat & (BROKEN|NOPOWER))
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