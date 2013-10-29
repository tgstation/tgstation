var/labor_shuttle_tickstomove = 10
var/labor_shuttle_moving = 0
var/labor_shuttle_location = 0 // 0 = station 13, 1 = labor station

proc/move_labor_shuttle() //TODO: Security Access only; add moving the shuttle to the station to the release button.

	if(labor_shuttle_moving)	return
	labor_shuttle_moving = 1
	spawn(labor_shuttle_tickstomove*10)
		var/area/fromArea
		var/area/toArea
		if (labor_shuttle_location == 1)
			fromArea = locate(/area/shuttle/siberia/outpost)
			toArea = locate(/area/shuttle/siberia/station)

		else
			fromArea = locate(/area/shuttle/siberia/station)
			toArea = locate(/area/shuttle/siberia/outpost)

		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/turf/T in toArea)
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
				// NOTE: Commenting this out to avoid recreating mass driver glitch
				/*
				spawn(0)
					AM.throw_at(E, 1, 1)
					return
				*/

			if(istype(T, /turf/simulated))
				del(T)

		for(var/mob/living/carbon/bug in toArea) // If someone somehow is still in the shuttle's docking area...
			bug.gib()

		fromArea.move_contents_to(toArea)
		if (labor_shuttle_location)
			labor_shuttle_location = 0
		else
			labor_shuttle_location = 1

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 3, 1) // buckled, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		labor_shuttle_moving = 0
	return

/obj/machinery/computer/labor_shuttle
	name = "Labor Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = "/obj/item/weapon/circuitboard/labor_shuttle"
	var/location = 0 //0 = station, 1 = labor camp
	req_access = list(access_brig)
	var/hacked = 0

/obj/machinery/computer/labor_shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat
	dat = text("<center><A href='?src=\ref[src];move=[1]'>Send Labor Shuttle</A></center>")
	//user << browse("[dat]", "window=laborshuttle;size=200x100")
	var/datum/browser/popup = new(user, "laborshuttle", name, 200, 140)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/labor_shuttle/Topic(href, href_list)
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(!allowed(usr))
			usr << "\red Access denied."
			return
		if (!labor_shuttle_moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			move_labor_shuttle()
		else
			usr << "\blue Shuttle is already moving."

/obj/machinery/computer/labor_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		hacked = 1
		usr << "You fried the consoles ID checking system. It's now available to everyone!"

	else
		..()



/obj/machinery/computer/labor_shuttle/one_way
	name = "Prisoner Shuttle Console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labor camp."
	circuit = "/obj/item/weapon/circuitboard/one_way_shuttle"
	req_access = list( )

/obj/machinery/computer/labor_shuttle/one_way/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat
	dat = text("<center><A href='?src=\ref[src];move=[1]'>Summon Labor Shuttle</A></center>")
	//user << browse("[dat]", "window=laborshuttle;size=200x100")
	var/datum/browser/popup = new(user, "laborshuttle", name, 200, 140)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/labor_shuttle/one_way/Topic(href, href_list)
	if(href_list["move"] && labor_shuttle_location == 1)
		usr << "\blue Shuttle is already at the outpost."
		return
	..()