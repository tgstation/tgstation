#define TAXI_SHUTTLE_MOVE_TIME 240
#define TAXI_SHUTTLE_COOLDOWN 300

////////////////////
// TAXI SHUTTLE A //
////////////////////

/obj/machinery/computer/taxi_shuttle_a
	name = "taxi shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_taxi)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0

	l_color = "#B40000"

/obj/machinery/computer/taxi_shuttle_a/New()
	curr_location= locate(/area/shuttle/taxi_a/engineering_cargo_station)


/obj/machinery/computer/taxi_shuttle_a/proc/taxi_a_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + TAXI_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/taxi_a/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(TAXI_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/taxi_shuttle_a/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_a/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_a/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_a/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + TAXI_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + TAXI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><br>
	<a href='?src=\ref[src];med_sili=1'>Medical and Silicon Station</a><br>
	<a href='?src=\ref[src];engi_cargo=1'>Engineering and Cargo Station</a><br>
	<a href='?src=\ref[src];sec_sci=1'>Security and Science Station</a><br>
	<a href='?src=\ref[src];abandoned=1'>Abandoned Station</a><br>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/taxi_shuttle_a/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["med_sili"])
		taxi_a_move_to(/area/shuttle/taxi_a/medcal_silicon_station)
	else if(href_list["engi_cargo"])
		taxi_a_move_to(/area/shuttle/taxi_a/engineering_cargo_station)
	else if(href_list["sec_sci"])
		taxi_a_move_to(/area/shuttle/taxi_a/security_science_station)
	else if(href_list["abandoned"])
		taxi_a_move_to(/area/shuttle/taxi_a/abandoned_station)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/taxi_shuttle_a/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")


////////////////////
// TAXI SHUTTLE B //
////////////////////

/obj/machinery/computer/taxi_shuttle_b
	name = "taxi shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_taxi)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0

	l_color = "#B40000"

/obj/machinery/computer/taxi_shuttle_b/New()
	curr_location= locate(/area/shuttle/taxi_b/engineering_cargo_station)


/obj/machinery/computer/taxi_shuttle_b/proc/taxi_b_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + TAXI_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/taxi_b/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(TAXI_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/taxi_shuttle_b/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_b/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_b/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/taxi_shuttle_b/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + TAXI_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + TAXI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><br>
	<a href='?src=\ref[src];med_sili=1'>Medical and Silicon Station</a><br>
	<a href='?src=\ref[src];engi_cargo=1'>Engineering and Cargo Station</a><br>
	<a href='?src=\ref[src];sec_sci=1'>Security and Science Station</a><br>
	<a href='?src=\ref[src];abandoned=1'>Abandoned Station</a><br>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/taxi_shuttle_b/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["med_sili"])
		taxi_b_move_to(/area/shuttle/taxi_b/medcal_silicon_station)
	else if(href_list["engi_cargo"])
		taxi_b_move_to(/area/shuttle/taxi_b/engineering_cargo_station)
	else if(href_list["sec_sci"])
		taxi_b_move_to(/area/shuttle/taxi_b/security_science_station)
	else if(href_list["abandoned"])
		taxi_b_move_to(/area/shuttle/taxi_b/abandoned_station)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/taxi_shuttle_b/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
