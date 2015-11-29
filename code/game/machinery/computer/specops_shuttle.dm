//Config stuff
#define SPECOPS_MOVETIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SPECOPS_STATION_AREATYPE "/area/shuttle/specops/station" //Type of the spec ops shuttle area for station
#define SPECOPS_DOCK_AREATYPE "/area/shuttle/specops/centcom"	//Type of the spec ops shuttle area for dock
#define SPECOPS_RETURN_DELAY 6000 //Time between the shuttle is capable of moving.

var/specops_shuttle_moving_to_station = 0
var/specops_shuttle_moving_to_centcom = 0
var/specops_shuttle_at_station = 0
var/specops_shuttle_can_send = 1
var/specops_shuttle_time = 0
var/specops_shuttle_timeleft = 0

/obj/machinery/computer/specops_shuttle
	name = "Spec. Ops. Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_cent_specops,access_cent_ert)
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0
	var/specops_shuttle_timereset = 0

	light_color = LIGHT_COLOR_CYAN

/proc/specops_return()
	var/obj/item/device/radio/intercom/announcer = announcement_intercom

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "\"THE SPECIAL OPERATIONS SHUTTLE IS PREPARING TO RETURN\""//Initial message shown.
	if(announcer)
		AliceAnnounce(announcer, message)


	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(specops_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "\"ALERT: [rounded_time_left] SECOND[(rounded_time_left!=1)?"S":""] REMAIN\""
				if(rounded_time_left==0)
					message = "\"ALERT: TAKEOFF\""
				AliceAnnounce(announcer, message)
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1

	var/area/start_location = locate(/area/shuttle/specops/station)
	var/area/end_location = locate(/area/shuttle/specops/centcom)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			del(T)

	start_location.move_contents_to(end_location)

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>You have arrived at Central Command. Operation has ended!</span>")

	specops_shuttle_at_station = 0

	for(var/obj/machinery/computer/specops_shuttle/S in machines)
		S.specops_shuttle_timereset = world.time + SPECOPS_RETURN_DELAY

	del(announcer)
/proc/AliceAnnounce(var/atom/movable/announcer,var/message)
	var/datum/speech/speech = announcer.create_speech(message=message, frequency=radiochannels["Response Team"], transmitter=announcer)
	//speech.name="A.L.I.C.E."
	speech.job="Response Team"
	Broadcast_Message(speech,
		data=0,
		compression=0,
		level=list(0,1))
	returnToPool(speech)

/proc/specops_process()
	var/area/centcom/specops/special_ops = locate()//Where is the specops area located?
	var/obj/item/device/radio/intercom/announcer = announcement_intercom

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "\"THE SPECIAL OPERATIONS SHUTTLE IS PREPARING FOR LAUNCH\""//Initial message shown.
	if(announcer)
		AliceAnnounce(announcer, message)
//		message = "ARMORED SQUAD TAKE YOUR POSITION ON GRAVITY LAUNCH PAD"
//		announcer.autosay(message, "A.L.I.C.E.", "A.L.I.C.E.")

	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(specops_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "\"ALERT: [rounded_time_left] SECOND[(rounded_time_left!=1)?"S":""] REMAIN\""
				if(rounded_time_left==0)
					message = "\"ALERT: TAKEOFF\""
				AliceAnnounce(announcer, message)
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1
	if (specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

	if (!specops_can_move())
		to_chat(usr, "<span class='warning'>The Special Operations shuttle is unable to leave.</span>")
		return

	//Begin Marauder launchpad.
	spawn(0)//So it parallel processes it.
		for(var/obj/machinery/door/poddoor/M in special_ops)
			switch(M.id_tag)
				if("ASSAULT0")
					spawn(10)//1 second delay between each.
						M.open()
				if("ASSAULT1")
					spawn(20)
						M.open()
				if("ASSAULT2")
					spawn(30)
						M.open()
				if("ASSAULT3")
					spawn(40)
						M.open()

		sleep(10)

		var/spawn_marauder[] = new()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "Marauder Entry")
				spawn_marauder.Add(L)
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "Marauder Exit")
				var/obj/effect/portal/P = new(L.loc)
				P.invisibility = 101//So it is not seen by anyone.
				P.target = pick(spawn_marauder)//Where the marauder will arrive.
				spawn_marauder.Remove(P.target)

		sleep(10)

		for(var/obj/machinery/mass_driver/M in special_ops)
			switch(M.id_tag)
				if("ASSAULT0")
					spawn(10)
						M.drive()
				if("ASSAULT1")
					spawn(20)
						M.drive()
				if("ASSAULT2")
					spawn(30)
						M.drive()
				if("ASSAULT3")
					spawn(40)
						M.drive()

		sleep(50)//Doors remain open for 5 seconds.

		for(var/obj/machinery/door/poddoor/M in special_ops)
			switch(M.id_tag)//Doors close at the same time.
				if("ASSAULT0")
					spawn(0)
						M.close()
				if("ASSAULT1")
					spawn(0)
						M.close()
				if("ASSAULT2")
					spawn(0)
						M.close()
				if("ASSAULT3")
					spawn(0)
						M.close()
		special_ops.readyreset()//Reset firealarm after the team launched.
	//End Marauder launchpad.

	var/area/start_location = locate(/area/shuttle/specops/centcom)
	var/area/end_location = locate(/area/shuttle/specops/station)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			del(T)

	start_location.move_contents_to(end_location)

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>You have arrived to [station_name]. Commence operation!</span>")

	for(var/obj/machinery/computer/specops_shuttle/S in machines)
		S.specops_shuttle_timereset = world.time + SPECOPS_RETURN_DELAY

	del(announcer)

/proc/specops_can_move()
	if(specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom)
		return 0
	for(var/obj/machinery/computer/specops_shuttle/S in machines)
		if(world.timeofday <= S.specops_shuttle_timereset)
			return 0
	return 1

/obj/machinery/computer/specops_shuttle/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/specops_shuttle/emag(mob/user as mob)
	to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/computer/specops_shuttle/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

	if (sent_strike_team == 0 && send_emergency_team == 0)
		to_chat(usr, "<span class='warning'>The strike team has not yet deployed.</span>")
		return

	if(..())
		return

	user.machine = src
	var/dat
	if (temp)
		dat = temp
	else
		dat += {"<BR><B>Special Operations Shuttle</B><HR>
		\nLocation: [specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "Departing for [station_name] in ([specops_shuttle_timeleft] seconds.)":specops_shuttle_at_station ? "Station":"Dock"]<BR>
		[specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "\n*The Special Ops. shuttle is already leaving.*<BR>\n<BR>":specops_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Shuttle standing by...</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Depart to [station_name]</A><BR>\n<BR>"]
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/specops_shuttle/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	if (href_list["sendtodock"])
		if(!specops_shuttle_at_station|| specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			to_chat(usr, "<span class='notice'>Central Command will not allow the Special Operations shuttle to return yet.</span>")
			if(world.timeofday <= specops_shuttle_timereset)
				if (((world.timeofday - specops_shuttle_timereset)/10) > 60)
					to_chat(usr, "<span class='notice'>[-((world.timeofday - specops_shuttle_timereset)/10)/60] minutes remain!</span>")
				to_chat(usr, "<span class='notice'>[-(world.timeofday - specops_shuttle_timereset)/10] seconds remain!</span>")
			return

		to_chat(usr, "<span class='notice'>The Special Operations shuttle will arrive at Central Command in [(SPECOPS_MOVETIME/10)] seconds.</span>")

		temp += "Shuttle departing.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		updateUsrDialog()

		specops_shuttle_moving_to_centcom = 1
		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_return()

	else if (href_list["sendtostation"])
		if(specops_shuttle_at_station || specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			to_chat(usr, "<span class='warning'>The Special Operations shuttle is unable to leave.</span>")
			return

		to_chat(usr, "<span class='notice'>The Special Operations shuttle will arrive on [station_name] in [(SPECOPS_MOVETIME/10)] seconds.</span>")

		temp += "Shuttle departing.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		updateUsrDialog()

		var/area/centcom/specops/special_ops = locate()
		if(special_ops)
			special_ops.readyalert()//Trigger alarm for the spec ops area.
		specops_shuttle_moving_to_station = 1

		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_process()

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/*//Config stuff
#define SPECOPS_MOVETIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SPECOPS_STATION_AREATYPE "/area/shuttle/specops/station" //Type of the spec ops shuttle area for station
#define SPECOPS_DOCK_AREATYPE "/area/shuttle/specops/centcom"	//Type of the spec ops shuttle area for dock

var/specops_shuttle_moving_to_station = 0
var/specops_shuttle_moving_to_centcom = 0
var/specops_shuttle_at_station = 0
var/specops_shuttle_can_send = 1
var/specops_shuttle_time = 0
var/specops_shuttle_timeleft = 0

/obj/machinery/computer/specops_shuttle
	name = "Spec. Ops. Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_cent_specops)
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0

/proc/specops_process()
	var/area/centcom/control/cent_com = locate()//To find announcer. This area should exist for this proc to work.
	var/area/centcom/specops/special_ops = locate()//Where is the specops area located?
	var/obj/item/device/radio/intercom/announcer = announcement_intercom

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "THE SPECIAL OPERATIONS SHUTTLE IS PREPARING FOR LAUNCH"//Initial message shown.
	if(announcer)
		Broadcast_Message(announcer, null, null, announcer, message, "A.L.I.C.E.", "A.L.I.C.E.", "A.L.I.C.E.", 0, 0, list(0,1), radiochannels["Response Team"])
		message = "ARMORED SQUAD TAKE YOUR POSITION ON GRAVITY LAUNCH PAD"
		Broadcast_Message(announcer, null, null, announcer, message, "A.L.I.C.E.", "A.L.I.C.E.", "A.L.I.C.E."", 0, 0, list(0,1), radiochannels["Response Team"])

	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(specops_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "ALERT: [rounded_time_left] SECOND[(rounded_time_left!=1)?"S":""] REMAIN"
				if(rounded_time_left==0)
					message = "ALERT: TAKEOFF"
				Broadcast_Message(announcer, null, null, announcer, message, "A.L.I.C.E.", "Response Team", "A.L.I.C.E.", 0, 0, list(0,1), radiochannels["Response Team"])
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1
	if (specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

	if (!specops_can_move())
		to_chat(usr, "<span class='warning'>The Special Operations shuttle is unable to leave.</span>")
		return

	//Begin Marauder launchpad.
	spawn(0)//So it parallel processes it.
		for(var/obj/machinery/door/poddoor/M in special_ops)
			switch(M.id)
				if("ASSAULT0")
					spawn(10)//1 second delay between each.
						M.open()
				if("ASSAULT1")
					spawn(20)
						M.open()
				if("ASSAULT2")
					spawn(30)
						M.open()
				if("ASSAULT3")
					spawn(40)
						M.open()

		sleep(10)

		var/spawn_marauder[] = new()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "Marauder Entry")
				spawn_marauder.Add(L)
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "Marauder Exit")
				var/obj/effect/portal/P = new(L.loc)
				P.invisibility = 101//So it is not seen by anyone.
				P.failchance = 0//So it has no fail chance when teleporting.
				P.target = pick(spawn_marauder)//Where the marauder will arrive.
				spawn_marauder.Remove(P.target)

		sleep(10)

		for(var/obj/machinery/mass_driver/M in special_ops)
			switch(M.id)
				if("ASSAULT0")
					spawn(10)
						M.drive()
				if("ASSAULT1")
					spawn(20)
						M.drive()
				if("ASSAULT2")
					spawn(30)
						M.drive()
				if("ASSAULT3")
					spawn(40)
						M.drive()

		sleep(50)//Doors remain open for 5 seconds.

		for(var/obj/machinery/door/poddoor/M in special_ops)
			switch(M.id)//Doors close at the same time.
				if("ASSAULT0")
					spawn(0)
						M.close()
				if("ASSAULT1")
					spawn(0)
						M.close()
				if("ASSAULT2")
					spawn(0)
						M.close()
				if("ASSAULT3")
					spawn(0)
						M.close()
		special_ops.readyreset()//Reset firealarm after the team launched.
	//End Marauder launchpad.

	var/area/start_location = locate(/area/shuttle/specops/centcom)
	var/area/end_location = locate(/area/shuttle/specops/station)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			del(T)

	start_location.move_contents_to(end_location)

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>You have arrived to [station_name]. Commence operation!</span>")

/proc/specops_can_move()
	if(specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return 0
	else return 1

/obj/machinery/computer/specops_shuttle/attackby(I as obj, user as mob)
	return attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/specops_shuttle/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag))
		to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	else
		return attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

//	if (sent_strike_team == 0)
//		to_chat(usr, "<span class='warning'>The strike team has not yet deployed.</span>")
//		return

	if(..())
		return

	user.set_machine(src)
	var/dat
	if (temp)
		dat = temp
	else
		dat += {"<BR><B>Special Operations Shuttle</B><HR>
		\nLocation: [specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "Departing for [station_name] in ([specops_shuttle_timeleft] seconds.)":specops_shuttle_at_station ? "Station":"Dock"]<BR>
		[specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "\n*The Special Ops. shuttle is already leaving.*<BR>\n<BR>":specops_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Shuttle Offline</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Depart to [station_name]</A><BR>\n<BR>"]
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/specops_shuttle/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if (href_list["sendtodock"])
		if(!specops_shuttle_at_station|| specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		to_chat(usr, "<span class='notice'>Central Command will not allow the Special Operations shuttle to return.</span>")
		return

	else if (href_list["sendtostation"])
		if(specops_shuttle_at_station || specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			to_chat(usr, "<span class='warning'>The Special Operations shuttle is unable to leave.</span>")
			return

		to_chat(usr, "<span class='notice'>The Special Operations shuttle will arrive on [station_name] in [(SPECOPS_MOVETIME/10)] seconds.</span>")

		temp += "Shuttle departing.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		updateUsrDialog()

		var/area/centcom/specops/special_ops = locate()
		if(special_ops)
			if(special_ops.master)
				special_ops=special_ops.master
			special_ops.readyalert()//Trigger alarm for the spec ops area.
		specops_shuttle_moving_to_station = 1

		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_process()

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return
	*/