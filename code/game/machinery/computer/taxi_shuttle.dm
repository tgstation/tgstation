////////////////////
// TAXI SHUTTLES  //
////////////////////

var/global/list/taxi_computers = list()

/obj/machinery/computer/taxi_shuttle
	name = "taxi shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_taxi)

	machine_flags = EMAGGABLE | MULTITOOL_MENU | SHUTTLEWRENCH //Can be emagged, can be wrenched to shuttles (they SHOULDN'T get unwrenched, but who knows what might happen)

	var/datum/shuttle/taxi/shuttle //The shuttle this computer is connected to

	var/id_tag = ""
	var/letter = ""
	var/list/connected_buttons = list()

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/taxi_shuttle/New()
	..()
	taxi_computers += src

/obj/machinery/computer/taxi_shuttle/Destroy()
	taxi_computers -= src
	connected_buttons = list()
	..()


/obj/machinery/computer/taxi_shuttle/update_icon()
	..()
	icon_state = "syndishuttle"

/obj/machinery/computer/taxi_shuttle/proc/taxi_move_to(var/obj/structure/docking_port/destination/destination, var/wait_time)
	/*if(shuttle.moving)
		return
	if(!shuttle.can_move())
		return
	if(shuttle.current_port == destination)
		return

	broadcast("[capitalize(shuttle.name)] will move in [wait_time / 10] second\s.")

	sleep(wait_time)

	shuttle.move_to_dock(destination)

	if(shuttle.current_port == destination)
		return 1*/
	if(shuttle.moving)
		return
	if(!shuttle.can_move())
		return
	if(shuttle.current_port == destination)
		return

	shuttle.pre_flight_delay = wait_time

	broadcast("[capitalize(shuttle.name)] will move in [wait_time / 10] second\s.")

	return shuttle.travel_to(destination)


/obj/machinery/computer/taxi_shuttle/proc/broadcast(var/message = "")
	if(message)
		src.visible_message("[bicon(src)]" + message)
	else
		return
	for(var/obj/machinery/door_control/taxi/TB in connected_buttons)
		TB.visible_message("[bicon(TB)]" + message)

/obj/machinery/computer/taxi_shuttle/attackby(obj/item/I as obj, mob/user as mob)
	if(..())
		return 1
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle/attack_hand(mob/user as mob)

	user.set_machine(src)

	var/dat

	if(shuttle.lockdown)
		dat += "<h2><font color='red'>THIS TAXI IS LOCKED DOWN</font></h2><br>"
		if(istext(shuttle.lockdown))
			dat += shuttle.lockdown
		else
			dat += "Additional information has not been provided."
	else if(!shuttle.linked_area)
		dat = "<h2><font color='red'>UNABLE TO FIND [uppertext(shuttle.name)]</font></h2>"
	else if(!shuttle.linked_port)	//User friendly interface
		dat += "<h2><font color='red'>ERROR: Unable to find the docking port. Please contact tech support.</font></h2><br>"
	else if(shuttle.moving)
		dat += "<center><h3>Currently moving [shuttle.destination_port.areaname ? "to [shuttle.destination_port.areaname]" : ""]</h3></center>"
	else
		dat = {"[shuttle.current_port ? "Location: [shuttle.current_port.areaname]" : "Location: UNKNOWN"]<br>
			Ready to move[max(shuttle.last_moved + shuttle.cooldown - world.time, 0) ? " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds" : ": now"]<br><br>
			<a href='?src=\ref[src];med_sili=1'>[shuttle.dock_medical_silicon.areaname]</a><br>
			<a href='?src=\ref[src];engi_cargo=1'>[shuttle.dock_engineering_cargo.areaname]</a><br>
			<a href='?src=\ref[src];sec_sci=1'>[shuttle.dock_security_science.areaname]</a><br>
			[emagged ? "<a href='?src=\ref[src];abandoned=1'>Abandoned Station</a><br>" : ""]"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/taxi_shuttle/emag(mob/user)
	if(!emagged)
		emagged = 1
		req_access = list()
		return 1
	return 0

/obj/machinery/computer/taxi_shuttle/power_change()
	return

/obj/machinery/computer/taxi_shuttle/Topic(href, href_list)
	if(..())	return 1
	var/mob/user = usr

	user.set_machine(src)

	for(var/place in href_list)
		if(href_list[place])
			if(!allowed(user))
				callTo(place, shuttle.move_time_no_access)
			else
				callTo(place, shuttle.move_time_access) //otherwise, double quick time

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/taxi_shuttle/proc/callTo(var/place = "", var/wait_time)
	switch(place)
		if("med_sili")
			if (taxi_move_to(shuttle.dock_medical_silicon, wait_time))
				return 1
		if("engi_cargo")
			if (taxi_move_to(shuttle.dock_engineering_cargo, wait_time))
				return 1
		if("sec_sci")
			if (taxi_move_to(shuttle.dock_security_science, wait_time))
				return 1
		if("abandoned")
			if (taxi_move_to(shuttle.dock_abandoned, wait_time))
				return 1
	return

/obj/machinery/computer/taxi_shuttle/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")


////////////////////
// TAXI SHUTTLE A //
////////////////////
/obj/machinery/computer/taxi_shuttle/taxi_a
	name = "taxi shuttle terminal A"
	id_tag = "taxi_a"
	letter = "A"

/obj/machinery/computer/taxi_shuttle/taxi_a/New()
	..()
	shuttle = taxi_a

////////////////////
// TAXI SHUTTLE B //
////////////////////

/obj/machinery/computer/taxi_shuttle/taxi_b
	name = "taxi shuttle terminal B"
	id_tag = "taxi_b"
	letter = "B"

/obj/machinery/computer/taxi_shuttle/taxi_b/New()
	..()
	shuttle = taxi_b