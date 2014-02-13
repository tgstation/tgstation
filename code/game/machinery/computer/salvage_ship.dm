#define SALVAGE_SHIP_MOVE_TIME 300
#define SALVAGE_SHIP_COOLDOWN 800

/obj/machinery/computer/salvage_ship
	name = "salvage ship terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_salvage_captain)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0


/obj/machinery/computer/salvage_ship/New()
	curr_location= locate(/area/shuttle/salvage/start)


/obj/machinery/computer/salvage_ship/proc/salvage_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + SALVAGE_SHIP_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/salvage/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(SALVAGE_SHIP_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/salvage_ship/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/salvage_ship/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/salvage_ship/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/salvage_ship/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + SALVAGE_SHIP_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + SALVAGE_SHIP_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];start=1'>Middle of Nowhere</a><br>
	<a href='?src=\ref[src];arrivals=1'>Station Auxiliary Docking</a> |
	<a href='?src=\ref[src];north=1'>North of the Station</a> |
	<a href='?src=\ref[src];east=1'>East of the Station</a> |
	<a href='?src=\ref[src];south=1'>South of the Station</a><br>
	<a href='?src=\ref[src];mining=1'>South-west of the Mining Asteroid</a> |
	<a href='?src=\ref[src];trading_post=1'>Trading Post</a><br>
	<a href='?src=\ref[src];clown_asteroid=1'>Clown Asteroid</a> |
	<a href='?src=\ref[src];derelict=1'>Derelict Station</a> |
	<a href='?src=\ref[src];djstation=1'>Ruskie DJ Station</a><br>
	<a href='?src=\ref[src];commssat=1'>Communications Satellite</a> |
	<a href='?src=\ref[src];abandoned_ship=1'>Abandoned Ship</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/salvage_ship/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["salvage"])
		salvage_move_to(/area/shuttle/salvage/start)
	else if(href_list["start"])
		salvage_move_to(/area/shuttle/salvage/start)
	else if(href_list["arrivals"])
		salvage_move_to(/area/shuttle/salvage/arrivals)
	else if(href_list["derelict"])
		salvage_move_to(/area/shuttle/salvage/derelict)
	else if(href_list["djstation"])
		salvage_move_to(/area/shuttle/salvage/djstation)
	else if(href_list["north"])
		salvage_move_to(/area/shuttle/salvage/north)
	else if(href_list["east"])
		salvage_move_to(/area/shuttle/salvage/east)
	else if(href_list["south"])
		salvage_move_to(/area/shuttle/salvage/south)
	else if(href_list["commssat"])
		salvage_move_to(/area/shuttle/salvage/commssat)
	else if(href_list["mining"])
		salvage_move_to(/area/shuttle/salvage/mining)
	else if(href_list["abandoned_ship"])
		salvage_move_to(/area/shuttle/salvage/abandoned_ship)
	else if(href_list["clown_asteroid"])
		salvage_move_to(/area/shuttle/salvage/clown_asteroid)
	else if(href_list["trading_post"])
		salvage_move_to(/area/shuttle/salvage/trading_post)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/salvage_ship/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")