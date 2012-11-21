#define SYNDICATE_SHUTTLE_MOVE_TIME 240
#define SYNDICATE_SHUTTLE_COOLDOWN 200

/obj/machinery/computer/syndicate_station
	name = "syndicate shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list()
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0


/obj/machinery/computer/syndicate_station/New()
	curr_location= locate(/area/syndicate_station/start)


/obj/machinery/computer/syndicate_station/proc/syndicate_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/syndicate_station/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(SYNDICATE_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/syndicate_station/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/syndicate_station/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "<span class='notice'>Access Denied.</span>"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	<a href='?src=\ref[src];syndicate=1'>Syndicate Space</a><br>
	<a href='?src=\ref[src];station_nw=1'>North West of SS13</a> |
	<a href='?src=\ref[src];station_n=1'>North of SS13</a> |
	<a href='?src=\ref[src];station_ne=1'>North East of SS13</a><br>
	<a href='?src=\ref[src];station_sw=1'>South West of SS13</a> |
	<a href='?src=\ref[src];station_s=1'>South of SS13</a> |
	<a href='?src=\ref[src];station_se=1'>South East of SS13</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/syndicate_station/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["syndicate"])
		syndicate_move_to(/area/syndicate_station/start)
	else if(href_list["station_nw"])
		syndicate_move_to(/area/syndicate_station/two)
	else if(href_list["station_n"])
		syndicate_move_to(/area/syndicate_station/five)
	else if(href_list["station_ne"])
		syndicate_move_to(/area/syndicate_station/three)
	else if(href_list["station_sw"])
		syndicate_move_to(/area/syndicate_station/one)
	else if(href_list["station_s"])
		syndicate_move_to(/area/syndicate_station/six)
	else if(href_list["station_se"])
		syndicate_move_to(/area/syndicate_station/four)

	add_fingerprint(usr)
	updateUsrDialog()
	return