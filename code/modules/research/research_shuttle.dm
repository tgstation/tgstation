
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
			var/list/search = fromArea.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(search))
				research_shuttle_moving = 0
				return

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

			if(istype(T, /turf/simulated))
				del(T)
		//Do I really need to explain this loop?
		for(var/atom/A in toArea)
			if(istype(A,/mob/living))
				var/mob/living/unlucky_person = A
				unlucky_person.gib()
			// Weird things happen when this shit gets in the way.
			if(istype(A,/obj/structure/lattice) \
				|| istype(A, /obj/structure/window) \
				|| istype(A, /obj/structure/grille))
				qdel(A)

		fromArea.move_contents_to(toArea)
		if (research_shuttle_location)
			research_shuttle_location = 0
		else
			research_shuttle_location = 1

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.locked_to)
						shake_camera(M, 3, 1) // locked_to, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unlocked_to, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.locked_to)
					M.Weaken(3)

		research_shuttle_moving = 0
	return

/obj/machinery/computer/research_shuttle
	name = "Research Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_research)
	circuit = "/obj/item/weapon/circuitboard/research_shuttle"
	var/location = 0 //0 = station, 1 = research base
	machine_flags = EMAGGABLE | SCREWTOGGLE
	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/research_shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat = "<center>Research shuttle:<br> <b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>"
	user << browse("[dat]", "window=researchshuttle;size=200x100")

/obj/machinery/computer/research_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!src.allowed(usr))
		to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
		return
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				to_chat(usr, "Under directive 7-10, [station_name()] is quarantined until further notice.")
				return
		var/area/A = locate(/area/shuttle/research/station)
		if(!research_shuttle_location)
			var/list/search = A.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(search))
				to_chat(usr, "<span class='notice'>The nuclear disk is too precious for Nanotrasen to send it to an Asteroid.</span>")
				return
		if (!research_shuttle_moving)
			to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")
			move_research_shuttle()
		else
			to_chat(usr, "<span class='notice'>Shuttle is already moving.</span>")

/obj/machinery/computer/research_shuttle/emag(mob/user as mob)
	..()
	src.req_access = list()
	to_chat(usr, "You disable the console's access requirement.")
