#define TAXI_SHUTTLE_MOVE_TIME 240
#define TAXI_SHUTTLE_COOLDOWN 300

////////////////////
// TAXI SHUTTLES  //
////////////////////

/obj/machinery/computer/taxi_shuttle
	name = "taxi shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_taxi)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0
	var/id_tag = ""
	var/letter = ""

	l_color = "#B40000"

/obj/machinery/computer/taxi_shuttle/proc/taxi_move_to(area/destination as area, area/transit as area, var/wait_time)
	if(moving)
		return
	if(lastMove + TAXI_SHUTTLE_COOLDOWN > world.time)
		return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)
		return

	broadcast("Taxi [letter] will move in [wait_time / 10] seconds.")
	sleep(wait_time)
	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(transit)
		curr_location.move_contents_to(transit_location)
		curr_location = get_area(src)
		sleep(TAXI_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = get_area(src) //test code. Manually setting curr is bad
	moving = 0
	return 1

/obj/machinery/computer/taxi_shuttle/proc/broadcast(var/message = "")
	if(message)
		src.visible_message("\icon [src]" + message)
	for(var/obj/machinery/door_control/taxi/TB in world)
		if(id_tag == TB.id_tag)
			TB.visible_message("\icon [TB] " + message)

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
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + TAXI_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + TAXI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><br>
	<a href='?src=\ref[src];med_sili=1'>Medical and Silicon Station</a><br>
	<a href='?src=\ref[src];engi_cargo=1'>Engineering and Cargo Station</a><br>
	<a href='?src=\ref[src];sec_sci=1'>Security and Science Station</a><br>
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


/obj/machinery/computer/taxi_shuttle/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	for(var/place in href_list)
		if(href_list[place])
			callTo(place, 30)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/taxi_shuttle/proc/callTo(var/place = "")
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
	curr_location= locate(/area/shuttle/taxi_a/engineering_cargo_station)

/obj/machinery/computer/taxi_shuttle/taxi_a/callTo(var/place = "", var/wait_time)
	switch(place)
		if("med_sili")
			if (taxi_move_to(/area/shuttle/taxi_a/medcal_silicon_station, /area/shuttle/taxi_a/transit, wait_time))
				return 1
		if("engi_cargo")
			if (taxi_move_to(/area/shuttle/taxi_a/engineering_cargo_station, /area/shuttle/taxi_a/transit, wait_time))
				return 1
		if("sec_sci")
			if (taxi_move_to(/area/shuttle/taxi_a/security_science_station, /area/shuttle/taxi_a/transit, wait_time))
				return 1
		if("abandoned")
			if (taxi_move_to(/area/shuttle/taxi_a/abandoned_station, /area/shuttle/taxi_a/transit, wait_time))
				return 1
	return

////////////////////
// TAXI SHUTTLE B //
////////////////////

/obj/machinery/computer/taxi_shuttle/taxi_b
	name = "taxi shuttle terminal B"
	id_tag = "taxi_b"
	letter = "B"

/obj/machinery/computer/taxi_shuttle/taxi_b/New()
	curr_location= locate(/area/shuttle/taxi_b/engineering_cargo_station)

/obj/machinery/computer/taxi_shuttle/taxi_b/callTo(var/place = "", var/wait_time)
	switch(place)
		if("med_sili")
			if (taxi_move_to(/area/shuttle/taxi_b/medcal_silicon_station, /area/shuttle/taxi_b/transit, wait_time))
				return 1
		if("engi_cargo")
			if (taxi_move_to(/area/shuttle/taxi_b/engineering_cargo_station, /area/shuttle/taxi_b/transit, wait_time))
				return 1
		if("sec_sci")
			if (taxi_move_to(/area/shuttle/taxi_b/security_science_station, /area/shuttle/taxi_b/transit, wait_time))
				return 1
		if("abandoned")
			if (taxi_move_to(/area/shuttle/taxi_b/abandoned_station, /area/shuttle/taxi_b/transit, wait_time))
				return 1
	return