//config stuff
#define SYNDICATE_DOCKZ 5          //Z-level of the Dock.
#define SYNDICATE_STATIONZ 1       //Z-level of the Station.
#define SYNDICATE_MOVETIME 150	//Time to station is milliseconds.
#define SYNDICATE_STATION_AREATYPE "/area/syndicate_station/start" //Type of for station
#define SYNDICATE_DOCK_AREATYPE 0	//Type of area for dock

var/syndicate_station_moving_to_station = 0
var/syndicate_station_moving_to_space = 0
var/syndicate_station_at_station = 0
var/syndicate_station_can_send = 1
var/syndicate_station_time = 0
var/syndicate_station_timeleft = 0
var/area/syndicate_loc = null
var/syndicate_out_of_moves = 0
var/bomb_set = 1

/obj/machinery/computer/syndicate_station
	name = "Syndicate Station Terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list()
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0
	var/syndicate_break = 0

/proc/syndicate_begin()
	switch(rand(1,6))
		if(1)
			syndicate_loc = locate(/area/syndicate_station/one)
		if(2)
			syndicate_loc = locate(/area/syndicate_station/two)
		if(3)
			syndicate_loc = locate(/area/syndicate_station/three)
		if(4)
			syndicate_loc = locate(/area/syndicate_station/four)
		if(5)
			syndicate_loc = locate(/area/syndicate_station/five)
		if(6)
			syndicate_loc = locate(/area/syndicate_station/six)

/proc/syndicate_process()
	while(syndicate_station_time - world.timeofday > 0)
		var/ticksleft = syndicate_station_time - world.timeofday

		if(ticksleft > 1e5)
			syndicate_station_time = world.timeofday + 10	// midnight rollover


		syndicate_station_timeleft = (ticksleft / 10)
		sleep(5)
	syndicate_station_moving_to_station = 0
	syndicate_station_moving_to_space = 0

	switch(syndicate_station_at_station)
		if(0)
			syndicate_station_at_station = 1
			if (syndicate_station_moving_to_station || syndicate_station_moving_to_space) return

			if (!syndicate_can_move())
				usr << "\red The syndicate shuttle is unable to leave."
				return

			var/area/start_location = locate(/area/syndicate_station/start)
			var/area/end_location = syndicate_loc

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
			bomb_set = 0



		if(1)
			syndicate_station_at_station = 0
			if (syndicate_station_moving_to_station || syndicate_station_moving_to_space) return

			if (!syndicate_can_move())
				usr << "\red The syndicate shuttle is unable to leave."
				return

			var/area/start_location = syndicate_loc
			var/area/end_location = locate(/area/syndicate_station/start)

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
			syndicate_out_of_moves = 1

/proc/syndicate_can_move()
	if(syndicate_station_moving_to_station || syndicate_station_moving_to_space) return 0
	if(syndicate_out_of_moves) return 0
	if(!bomb_set) return 0
	else return 1

/obj/machinery/computer/syndicate_station/attackby(I as obj, user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/syndicate_station/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag))
		user << "\blue Nothing happens."
	else
		return src.attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_hand(var/mob/user as mob)
	if(!src.allowed(user))
		user << "\red Access Denied."
		return

	if(syndicate_break)
		user << "\red Unable to locate shuttle."
		return

	if(..())
		return
	user.machine = src
	var/dat
	if (src.temp)
		dat = src.temp
	else
		dat += {"<BR><B>Syndicate Shuttle</B><HR>
		\nLocation: [syndicate_station_moving_to_station || syndicate_station_moving_to_space ? "Moving to station ([syndicate_station_timeleft] Secs.)":syndicate_station_at_station ? "Station":"Space"]<BR>
		[syndicate_station_moving_to_station || syndicate_station_moving_to_space ? "\n*Shuttle already called*<BR>\n<BR>":syndicate_station_at_station ? "\n<A href='?src=\ref[src];sendtospace=1'>Send to space</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Send to station</A><BR>\n<BR>"]
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/syndicate_station/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	if (href_list["sendtospace"])
		if(!syndicate_station_at_station|| syndicate_station_moving_to_station || syndicate_station_moving_to_space) return

		if (!syndicate_can_move())
			usr << "\red The syndicate shuttle is unable to leave."
			return

		usr << "\blue The syndicate shuttle will move in [(PRISON_MOVETIME/10)] seconds."

		src.temp += "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()

		syndicate_station_moving_to_space = 1

		syndicate_station_time = world.timeofday + SYNDICATE_MOVETIME
		spawn(0)
			syndicate_process()

	else if (href_list["sendtostation"])
		if(syndicate_station_at_station || syndicate_station_moving_to_station || syndicate_station_moving_to_space) return

		if (!syndicate_can_move())
			usr << "\red The syndicate shuttle is unable to leave."
			return

		usr << "\blue The syndicate shuttle will move in [(SYNDICATE_MOVETIME/10)] seconds."

		src.temp += "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()

		syndicate_station_moving_to_station = 1

		syndicate_station_time = world.timeofday + SYNDICATE_MOVETIME
		spawn(0)
			syndicate_process()

	else if (href_list["mainmenu"])
		src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return