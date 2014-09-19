/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = /obj/item/weapon/circuitboard/labor_shuttle
	id = "laborcamp"
	req_access = list(access_brig)


/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labor camp."
	circuit = /obj/item/weapon/circuitboard/labor_shuttle/one_way
	req_access = list( )

/obj/machinery/computer/shuttle/labor/one_way/Topic(href, href_list)
	if(href_list["move"])
		var/datum/shuttle_manager/s = shuttles["laborcamp"]
		if(s.location == /area/shuttle/laborcamp/outpost)
			usr << "<span class='notice'>Shuttle is already at the outpost.</span>"
			return 0
	..()