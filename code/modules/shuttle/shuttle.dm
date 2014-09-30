var/obj/list/shuttles = list(("escape" = new /datum/shuttle_manager(/area/shuttle/escape/centcom, 0)), ("pod1" =  new /datum/shuttle_manager(/area/shuttle/escape_pod1/station, 0)), ("pod2" = new /datum/shuttle_manager(/area/shuttle/escape_pod2/station, 0)), ("pod3" = new /datum/shuttle_manager(/area/shuttle/escape_pod3/station, 0)), ("pod4" = new /datum/shuttle_manager(/area/shuttle/escape_pod4/station, 0)), ("mining" = new /datum/shuttle_manager(/area/shuttle/mining/station, 10)), ("laborcamp" = new /datum/shuttle_manager(/area/shuttle/laborcamp/station, 10)), ("ferry" = new /datum/shuttle_manager(/area/shuttle/transport1/centcom, 0)))
		//Pre-made shuttles should have non-number keys, so that buildable shuttles can use numbered keys without allowing 'I build a shuttle console with the escape number as its ID.'
datum/shuttle_manager
	var/tickstomove = 10 //How long does it take to move the shuttle?
	var/moving = 0 //Is it moving?
	var/area/shuttle/location //The current location of the actual shuttle

datum/shuttle_manager/New(var/area, var/delay) //Create a new shuttle manager for the shuttle starting area, "area" and with a movement delay of tickstomove
	location = area
	tickstomove = delay
	var/area/A = locate(location)
	A.has_gravity = 1


datum/shuttle_manager/proc/move_shuttle(var/override_delay)
	if(moving)	return 0
	moving = 1
	spawn(override_delay == null ? tickstomove*10 : override_delay)
		var/area/shuttle/fromArea
		var/area/shuttle/toArea
		fromArea = locate(location) //the location of the shuttle
		toArea = locate(fromArea.destination)

		toArea.clear_docking_area()

		fromArea.move_contents_to(toArea)
		location = toArea.type

		fromArea.has_gravity = 0
		toArea.has_gravity = 1

		for(var/obj/machinery/door/D in toArea) //Close any doors on the shuttle
			spawn(0)
				D.close()

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1) // turn it down a bit come on
					else
						shake_camera(M, 7, 1)
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		moving = 0
	return 1


/obj/machinery/computer/shuttle
	name = "Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list( )
	circuit = /obj/item/weapon/circuitboard/shuttle
	var/id

/obj/machinery/computer/shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat
	dat = text("<center><A href='?src=\ref[src];move=[1]'>Send Shuttle</A></center>")
	//user << browse("[dat]", "window=miningshuttle;size=200x100")
	var/datum/browser/popup = new(user, "miningshuttle", name, 200, 140)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!allowed(usr))
		usr << "<span class='danger'>Access denied.</span>"
		return
	if(href_list["move"])
		if(id in shuttles)
			var/datum/shuttle_manager/s = shuttles[id]
			if (s.move_shuttle())
				usr << "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>"
			else
				usr << "<span class='notice'>Shuttle is already moving.</span>"
		else
			usr << "<span class='warning'>Invalid shuttle requested.</span>"


/obj/machinery/computer/shuttle/attackby(I as obj, user as mob)

	if (istype(I, /obj/item/weapon/card/emag))
		src.req_access = list()
		emagged = 1
		usr << "You fried the consoles ID checking system."
	else
		..()
	return

/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry
	id = "ferry"

/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/weapon/circuitboard/ferry/request
	var/cooldown //prevents spamming admins

/obj/machinery/computer/shuttle/ferry/request/Topic(href, href_list)
	if(href_list["move"])
		if(cooldown)
			return
		cooldown = 1
		usr << "<span class='notice'>Docking locks are engaged. Requesting authorization..."
		var/datum/shuttle_manager/s = shuttles["ferry"]
		admins << "<b>FERRY: <font color='blue'>[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[usr]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=moveferry'>Move</a>)</b> is requesting to move the transport ferry to [s.location == /area/shuttle/transport1/centcom ? "the station" : "Centcom"].</font>"
		spawn(600) //One minute cooldown
			cooldown = 0