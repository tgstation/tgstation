//Config stuff
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
	icon = 'computer.dmi'
	icon_state = "shuttle"
	req_access = list()
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0

/proc/specops_process()
	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)
		sleep(5)
	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1
	if (specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

	if (!specops_can_move())
		usr << "\red The Special Operations shuttle is unable to leave."
		return

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
		M << "\red You have arrived to [station_name]. Commence operation!"

/proc/specops_can_move()
	if(specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return 0
	else return 1

/obj/machinery/computer/specops_shuttle/attackby(I as obj, user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/specops_shuttle/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag))
		user << "\blue The electronic systems in this console are far too advanced for your primitive hacking peripherals."
	else
		return src.attack_hand(user)

/obj/machinery/computer/specops_shuttle/attack_hand(var/mob/user as mob)
	if(!src.allowed(user))
		user << "\red Access Denied."
		return

	if(..())
		return

	user.machine = src
	var/dat
	if (src.temp)
		dat = src.temp
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
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	if (href_list["sendtodock"])
		if(!specops_shuttle_at_station|| specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		usr << "\blue Central Command will not allow the Special Operations shuttle to return."
		return

	else if (href_list["sendtostation"])
		if(specops_shuttle_at_station || specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			usr << "\red The Special Operations shuttle is unable to leave."
			return

		usr << "\blue The Special Operations shuttle will arrive on [station_name] in [(SPECOPS_MOVETIME/10)] seconds."

		src.temp += "Shuttle departing.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()

		specops_shuttle_moving_to_station = 1

		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_process()

	else if (href_list["mainmenu"])
		src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return