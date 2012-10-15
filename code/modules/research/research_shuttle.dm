
/**********************Shuttle Computer**************************/

//copy paste from the mining shuttle

var/research_shuttle_tickstomove = 10
var/research_shuttle_moving = 0
var/research_shuttle_location = 0 // 0 = station 13, 1 = research station

proc/move_research_shuttle()
	if(research_shuttle_moving)	return
	research_shuttle_moving = 1
	spawn(research_shuttle_tickstomove*10)
		var/area/fromArea
		var/area/toArea
		if (research_shuttle_location == 1)
			fromArea = locate(/area/shuttle/research/outpost)
			toArea = locate(/area/shuttle/research/station)
		else
			fromArea = locate(/area/shuttle/research/station)
			toArea = locate(/area/shuttle/research/outpost)


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
		if (research_shuttle_location)
			research_shuttle_location = 0
		else
			research_shuttle_location = 1
		research_shuttle_moving = 0
	return

/obj/machinery/computer/research_shuttle
	name = "Research Shuttle Console"
	icon = 'computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_research)
	circuit = "/obj/item/weapon/circuitboard/research_shuttle"
	var/hacked = 0
	var/location = 0 //0 = station, 1 = research base

/obj/machinery/computer/research_shuttle/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>Research shuttle: <b><A href='?src=\ref[src];move=1'>Send</A></b></center><br>"

	user << browse("[dat]", "window=researchshuttle;size=200x100")

/obj/machinery/computer/research_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
				return

		if (!research_shuttle_moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			move_research_shuttle()
		else
			usr << "\blue Shuttle is already moving."

/obj/machinery/computer/research_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		src.req_access = list()
		hacked = 1
		usr << "You fried the consoles ID checking system. It's now available to everyone!"

	else if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/weapon/circuitboard/research_shuttle/M = new /obj/item/weapon/circuitboard/research_shuttle( A )
			for (var/obj/C in src)
				C.loc = src.loc
			A.circuit = M
			A.anchored = 1

			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				user << "\blue You disconnect the monitor."
				A.state = 4
				A.icon_state = "4"

			del(src)
