#define VOX_SHUTTLE_MOVE_TIME 260
#define VOX_SHUTTLE_COOLDOWN 460

//Copied from Syndicate shuttle.
var/global/vox_shuttle_location

/obj/machinery/computer/vox_station
	name = "vox skipjack terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0
	var/warning //Warning about the end of the round.

	l_color = "#B40000"

/obj/machinery/computer/vox_station/New()
	curr_location= locate(/area/shuttle/vox/station)


/obj/machinery/computer/vox_station/proc/vox_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + VOX_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/vox_station/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(VOX_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0

	return 1


/obj/machinery/computer/vox_station/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + VOX_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + VOX_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];start=1'>Return to dark space</a><br>
	<a href='?src=\ref[src];solars_fore_port=1'>Fore port solar</a> |
	<a href='?src=\ref[src];solars_aft_port=1'>Aft port solar</a> |
	<a href='?src=\ref[src];solars_fore_starboard=1'>Fore starboard solar</a><br>
	<a href='?src=\ref[src];solars_aft_starboard=1'>Aft starboard solar</a> |
	<a href='?src=\ref[src];mining=1'>Mining Asteroid</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/vox_station/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	vox_shuttle_location = "station"
	if(href_list["start"])
		if(ticker && (istype(ticker.mode,/datum/game_mode/heist)))
			if(!warning)
				user << "\red Returning to dark space will end your raid and report your success or failure. If you are sure, press the button again."
				warning = 1
				return
		vox_move_to(/area/shuttle/vox/station)
		vox_shuttle_location = "start"
	else if(href_list["solars_fore_starboard"])
		vox_move_to(/area/vox_station/northeast_solars)
	else if(href_list["solars_fore_port"])
		vox_move_to(/area/vox_station/northwest_solars)
	else if(href_list["solars_aft_starboard"])
		vox_move_to(/area/vox_station/southeast_solars)
	else if(href_list["solars_aft_port"])
		vox_move_to(/area/vox_station/southwest_solars)
	else if(href_list["mining"])
		vox_move_to(/area/vox_station/mining)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/vox_station/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")