/obj/machinery/nuclearbomb
	desc = "Uh oh. RUN!!!!"
	name = "Nuclear Fission Explosive"
	icon = 'stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	var/deployable = 0.0
	var/extended = 0.0
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/weapon/disk/nuclear/auth = null
	flags = FPRINT
	use_power = 0

/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	return

/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if (src.extended)
		user.machine = src
		var/dat = text("<TT><B>Nuclear Fission Explosive</B><BR>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (src.auth ? "++++++++++" : "----------"))
		if (src.auth)
			if (src.yes_code)
				dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\nSafety: [] <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (src.timing ? "Func/Set" : "Functional"), (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src, src, src, src.timeleft, src, src, (src.safety ? "On" : "Off"), src, (src.anchored ? "Engaged" : "Off"), src)
			else
				dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		else
			if (src.timing)
				dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
			else
				dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		var/message = "AUTH"
		if (src.auth)
			message = text("[]", src.code)
			if (src.yes_code)
				message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
		user << browse(dat, "window=nuclearbomb;size=300x400")
		onclose(user, "nuclearbomb")
	else if (src.deployable)
		src.anchored = 1
		flick("nuclearbombc", src)
		src.icon_state = "nuclearbomb1"
		src.extended = 1
	return

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if (src.deployable)
		src.deployable = 0
	else
		src.deployable = 1

/obj/machinery/nuclearbomb/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (!ishuman(usr))
		usr << "\red You don't have the dexterity to do this!"
		return 1
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["auth"])
			if (src.auth)
				src.auth.loc = src.loc
				src.yes_code = 0
				src.auth = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/weapon/disk/nuclear))
					usr.drop_item()
					I.loc = src
					src.auth = I
		if (src.auth)
			if (href_list["type"])
				if (href_list["type"] == "E")
					if (src.code == src.r_code)
						src.yes_code = 1
						src.code = null
					else
						src.code = "ERROR"
				else
					if (href_list["type"] == "R")
						src.yes_code = 0
						src.code = null
					else
						src.code += text("[]", href_list["type"])
						if (length(src.code) > 5)
							src.code = "ERROR"
			if (src.yes_code)
				if (href_list["time"])
					var/time = text2num(href_list["time"])
					src.timeleft += time
					src.timeleft = min(max(round(src.timeleft), 60), 600)
				if (href_list["timer"])
					if (src.timing == -1.0)
						return
					src.timing = !( src.timing )
					if (src.timing)
						src.icon_state = "nuclearbomb2"
						if(!src.safety)
							bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
					else
						src.icon_state = "nuclearbomb1"
						bomb_set = 0
				if (href_list["safety"])
					src.safety = !( src.safety )
				if (href_list["anchor"])
					src.anchored = !( src.anchored )
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	else
		usr << browse(null, "window=nuclearbomb")
		return
	return


/obj/machinery/nuclearbomb/ex_act(severity)
	return


/obj/machinery/nuclearbomb/blob_act()
	if (src.timing == -1.0)
		return
	else
		return ..()
	return


/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		src.timing = 0
		return
	src.timing = -1.0
	src.yes_code = 0
	src.safety = 1
	src.icon_state = "nuclearbomb3"
	playsound(src,'Alarm.ogg',100,0,5)
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

/*
	var/turf/ground_zero = get_turf(loc)
	explosion(ground_zero, 50, 250, 500, 750)

*/
	enter_allowed = 0



	var/off_station = 0
	var/area/A = get_area(src.loc)
	if(A && (istype(A,/area/syndicate_station) || A.type == "/area"))
		off_station = 1
	if (ticker && ticker.mode && ticker.mode.name == "nuclear emergency")
		ticker.mode:herp = syndicate_station_at_station
		ticker.mode:nuke_off_station = off_station

	for(var/mob/M in world)
		if(M.client)
			spawn(0)
				M.client.station_explosion_cinematic(off_station)
	sleep(110)

	for(var/mob/M in world)
		if(M.z==1)
			spawn(0)
				M.gib()

	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 0
		if(ticker.mode.name == "nuclear emergency")
			ticker.mode:nukes_left --
			ticker.mode.station_was_nuked = (off_station==0)

		else
			world << "<B>The station was destoyed by the nuclear blast!</B>"
			ticker.mode.station_was_nuked = 1
			/*
			TODO: derped blast should partially damage nearest objects
			and do not reboot the game. Also make it work properly on other z-levels --rastaf0
			Further TODO: make nuke detonation work with objectives. Right now, you can't track player
			location because they are viewing the cinematic (can't get_turf on them to determine z_level
			as it will return null). Leaving this for you since you apparently plan to work this further. /N
			*/

		if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			world << "<B>Resetting in 30 seconds!</B>"

			feedback_set_details("end_error","nuke - unhandled ending")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(300)
			log_game("Rebooting due to nuclear detonation")
			world.Reboot()
			return


/obj/item/weapon/disk/nuclear/Del()
//	if (ticker.mode && ticker.mode.name == "nuclear emergency")
	if(blobstart.len > 0)
		var/obj/D = new /obj/item/weapon/disk/nuclear(pick(blobstart))
		message_admins("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
		log_game("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
	..()
