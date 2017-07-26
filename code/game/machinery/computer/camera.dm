/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/weapon/circuitboard/computer/security
	var/last_pic = 1
	var/list/network = list("SS13")
	var/mapping = 0//For the overview file, interesting bit of code.
	var/list/watchers = list() //who's using the console, associated with the camera they're on.

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security/check_eye(mob/user)
	if( (stat & (NOPOWER|BROKEN)) || user.incapacitated() || user.eye_blind )
		user.unset_machine()
		return
	if(!(user in watchers))
		user.unset_machine()
		return
	if(!watchers[user])
		user.unset_machine()
		return
	var/obj/machinery/camera/C = watchers[user]
	if(!C.can_use())
		user.unset_machine()
		return
	if(!issilicon(user))
		if(!Adjacent(user))
			user.unset_machine()
			return
	else if(iscyborg(user))
		var/list/viewing = viewers(src)
		if(!viewing.Find(user))
			user.unset_machine()

/obj/machinery/computer/security/on_unset_machine(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)

/obj/machinery/computer/security/Destroy()
	if(watchers.len)
		for(var/mob/M in watchers)
			M.unset_machine() //to properly reset the view of the users if the console is deleted.
	return ..()

/obj/machinery/computer/security/attack_hand(mob/user)
	if(stat)
		return
	if (!network)
		throw EXCEPTION("No camera network")
		user.unset_machine()
		return
	if (!(islist(network)))
		throw EXCEPTION("Camera network is not a list")
		user.unset_machine()
		return
	if(..())
		user.unset_machine()
		return

	var/list/camera_list = get_available_cameras()
	if(!(user in watchers))
		for(var/Num in camera_list)
			var/obj/machinery/camera/CAM = camera_list[Num]
			if(istype(CAM))
				if(CAM.can_use())
					watchers[user] = CAM //let's give the user the first usable camera, and then let him change to the camera he wants.
					break
		if(!(user in watchers))
			user.unset_machine() // no usable camera on the network, we disconnect the user from the computer.
			return
	playsound(src, 'sound/machines/terminal_prompt.ogg', 25, 0)
	use_camera_console(user)

/obj/machinery/computer/security/proc/use_camera_console(mob/user)
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
	if(user.machine != src) //while we were choosing we got disconnected from our computer or are using another machine.
		return
	if(!t)
		user.unset_machine()
		playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		user.unset_machine()
		playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)
		return
	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.machine != src || user.eye_blind || user.incapacitated())
			camera_fail = 1
		else if(iscyborg(user))
			var/list/viewing = viewers(src)
			if(!viewing.Find(user))
				camera_fail = 1
		else if(!issilicon(user))
			if(!Adjacent(user))
				camera_fail = 1

		if(camera_fail)
			user.unset_machine()
			return 0

		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			user.clear_fullscreen("flash", 5)
		watchers[user] = C
		use_power(50)
		addtimer(CALLBACK(src, .proc/use_camera_console, user), 5)
	else
		user.unset_machine()

//returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((z > ZLEVEL_SPACEMAX || C.z > ZLEVEL_SPACEMAX) && (C.z != z))//if on away mission, can only recieve feed from same z_level cameras
			continue
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network&network
		if(tempnetwork.len)
			D["[C.c_tag][(C.status ? null : " (Deactivated)")]"] = C
	return D

/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = FALSE
	circuit = null
	clockwork = TRUE //it'd look very weird

	light_power = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the /tg/ channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list("thunder")
	density = FALSE
	circuit = null

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	clockwork = TRUE //it'd look weird


/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list("MINE")
	circuit = /obj/item/weapon/circuitboard/computer/mining
