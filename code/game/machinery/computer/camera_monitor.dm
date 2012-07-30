
/obj/machinery/computer/security
	New()
		if(network)
			networks = list(network)
		else
			switch(department)
				if("Security")
					networks = list("Arrivals","SS13","Engineering","Research","Medbay","Tcomsat","Mess Hall","Security","Prison Wing","Atmospherics","Cargo","Command","Solars","Robotics","Chapel","Hydroponics", "Dormitory","Theatre","Library")
				if("Engineering")
					networks = list("Engineering","Tcomsat","Singularity","Atmospherics","Solars","Robotics")
				if("Research")
					networks = list("Research","Bomb Testing","Outpost")
				if("Medbay")
					networks = list("Medbay")
				if("Cargo")
					networks = list("Mine","Cargo")
				if("Mining")
					networks = list("Mine")
				if("Thunderdome")
					networks = list("thunder")
				if("CREED")
					networks = list("CREED")

/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	if(src.current)
		user.reset_view(src.current)

	var/list/L = new/list
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_network_sort(L)

	var/list/D = new()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if ( C.network in src.networks )
			D[text("[]: [][]", C.network, C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if(!t)
		user.machine = null
		user.reset_view(null)
		return 0

	var/obj/machinery/camera/C = D[t]

	if (t == "Cancel")
		user.cancel_camera()
		return 0

	if (C)
		if ((get_dist(user, src) > 1 || user.machine != src || user.blinded || !( user.canmove ) || !( C.status )) && (!istype(user, /mob/living/silicon/ai)))
			return 0
		else
			src.current = C
			use_power(50)
			user.reset_view(C)

			spawn( 5 )
				attack_hand(user)
