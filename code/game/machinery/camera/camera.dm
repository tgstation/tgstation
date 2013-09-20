/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5

	var/datum/wires/camera/wires = null // Wires datum
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/panel_open = 0 // 0 = Closed / 1 = Open
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/item/weapon/camera_assembly/assembly = null

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

/obj/machinery/camera/New()
	wires = new(src)

	assembly = new(src)
	assembly.state = 4
	assembly.anchored = 1
	assembly.update_icon()

	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			world.log << "[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]"
	*/
	..()

/obj/machinery/camera/initialize()
	if(z == 1 && prob(3))
		deactivate()

/obj/machinery/camera/Del()
	if(istype(bug))
		bug.bugged_cameras -= src.c_tag
	..()

/obj/machinery/camera/emp_act(severity)
	if(!isEmpProof())
		if(prob(100/severity))
			icon_state = "[initial(icon_state)]emp"
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			stat |= EMPED
			SetLuminosity(0)
			triggerCameraAlarm()
			emped = emped+1  //Increase the number of consecutive EMP's
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
					network = previous_network
					icon_state = initial(icon_state)
					stat &= ~EMPED
					cancelCameraAlarm()
					if(can_use())
						cameranet.addCamera(src)
					emped = 0 //Resets the consecutive EMP count
			for(var/mob/O in mob_list)
				if (O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_view(null)
					O << "The screen bursts into static."
			..()


/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	del(src)
	return

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(var/mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	status = 0
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	icon_state = "[initial(icon_state)]1"
	add_hiddenprint(user)
	deactivate(user,0)

/obj/machinery/camera/attackby(W as obj, mob/living/user as mob)

	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/screwdriver))
		//user << "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>"
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		panel_open = !panel_open
		user.visible_message("<span class='warning'>[user] screws the camera's panel [panel_open ? "open" : "closed"]!</span>",
		"<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

	else if((istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool)) && panel_open)
		wires.Interact(user)

	else if(istype(W, /obj/item/weapon/weldingtool) && wires.CanDeconstruct())
		if(weld(W, user))
			if(assembly)
				assembly.loc = src.loc
				assembly.state = 1
			del(src)


	// OTHER
	else if ((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
		var/mob/living/U = user
		var/obj/item/weapon/paper/X = null
		var/obj/item/device/pda/P = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			X = W
			itemname = X.name
			info = X.info
		else
			P = W
			itemname = P.name
			info = P.notehtml
		U << "You hold \the [itemname] up to the camera ..."
		for(var/mob/O in player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(U.name == "Unknown") AI << "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				else AI << "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if (O.client && O.client.eye == src)
				O << "[U] holds \a [itemname] up to one of the cameras ..."
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
	else if (istype(W, /obj/item/device/camera_bug))
		if (!src.can_use())
			user << "\blue Camera non-functional"
			return
		if(istype(src.bug))
			user << "\blue Camera bug removed."
			src.bug.bugged_cameras -= src.c_tag
			src.bug = null
		else
			user << "\blue Camera bugged."
			src.bug = W
			src.bug.bugged_cameras[src.c_tag] = src
	else if(istype(W, /obj/item/weapon/melee/energy/blade))//Putting it here last since it's a special case. I wonder if there is a better way to do these than type casting.
		deactivate(user,2)//Here so that you can disconnect anyone viewing the camera, regardless if it's on or off.
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)
		visible_message("\blue The camera has been sliced apart by [] with an energy blade!")
		del(src)
	else if(istype(W, /obj/item/device/laser_pointer))
		var/obj/item/device/laser_pointer/L = W
		L.laser_act(src, user)
	else
		..()
	return

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !( src.status )
		if (!(src.status))
			if(user)
				visible_message("\red [user] has deactivated [src]!")
				add_hiddenprint(user)
			else
				visible_message("\red \The [src] deactivates!")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = "[initial(icon_state)]1"

		else
			if(user)
				visible_message("\red [user] has reactivated [src]!")
				add_hiddenprint(user)
			else
				visible_message("\red \the [src] reactivates!")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = initial(icon_state)

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			O << "The screen bursts into static."

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", get_area(src), list(src), src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.dir = SOUTH
				if(SOUTH)
					src.dir = NORTH
				if(WEST)
					src.dir = EAST
				if(EAST)
					src.dir = WEST
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)

	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)

	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	user << "<span class='notice'>You start to weld the [src]..</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 100))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0
