<<<<<<< HEAD
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
	else if(isrobot(user))
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
	if (!(istype(network,/list)))
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
	use_camera_console(user)

/obj/machinery/computer/security/proc/use_camera_console(mob/user)
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
	if(user.machine != src) //while we were choosing we got disconnected from our computer or are using another machine.
		return
	if(!t)
		user.unset_machine()
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		user.unset_machine()
		return
	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.machine != src || user.eye_blind || user.incapacitated())
			camera_fail = 1
		else if(isrobot(user))
			var/list/viewing = viewers(src)
			if(!viewing.Find(user))
				camera_fail = 1
		else if(!issilicon(user))
			if(!Adjacent(user))
				camera_fail = 1

		if(camera_fail)
			user.unset_machine()
			return 0

		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			user.reset_perspective(C)
		watchers[user] = C
		use_power(50)
		addtimer(src, "use_camera_console", 5, FALSE, user)
	else
		user.unset_machine()

//returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if((z > ZLEVEL_SPACEMAX || C.z > ZLEVEL_SPACEMAX) && (C.z != z))//if on away mission, can only recieve feed from same z_level cameras
			continue
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			spawn(0)
				throw EXCEPTION("Camera in a cameranet has no camera network")
			continue
		if(!(istype(C.network,/list)))
			spawn(0)
				throw EXCEPTION("Camera in a cameranet has a non-list camera network")
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
	density = 0
	circuit = null
	clockwork = TRUE //it'd look very weird

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
	density = 0
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
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/tv_monitors = list()

/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/security"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list("SS13")
	var/mapping = 0//For the overview file, interesting bit of code.

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security/New()
	..()
	tv_monitors += src

/obj/machinery/computer/security/Destroy()
	tv_monitors -= src
	..()

/obj/machinery/computer/security/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)


/obj/machinery/computer/security/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if ((!Adjacent(user) || user.isStunned() || user.blinded || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
		return null
	user.reset_view(current)
	return 1


/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	if(stat & (NOPOWER|BROKEN))	return

	if(!isAI(user))
		user.set_machine(src)

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!istype(C.network, /list))
			var/turf/T = get_turf(C)
			WARNING("[C] - Camera at ([T.x],[T.y],[T.z]) has a non list for network, [C.network]")
			C.network = list(C.network)
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D
	if(!t || t == "Cancel")
		user.cancel_camera()
		return 0
	user.set_machine(src)

	var/obj/machinery/camera/C = D[t]

	if(C)
		if ((!Adjacent(user) || user.machine != src || user.blinded || user.isStunned() || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)))
			if(!C.can_use() && !isAI(user))
				src.current = null
			user.cancel_camera()
			return 0
		else
			if(isAI(user))
				var/mob/living/silicon/ai/A = user
				A.eyeobj.forceMove(get_turf(C))
				A.client.eye = A.eyeobj
			else
				src.current = C
				use_power(50)

			spawn(5)
				attack_hand(user)
	return



/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching arena fights and variety shows."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = 0
	circuit = null

	light_color = null

/obj/machinery/computer/security/telescreen/examine(mob/user)
	..()
	to_chat(user, "Looks like the current channel is \"<span class='info'>[current.c_tag]</span>\"")

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have chicken-channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list("thunder", "courtroom")
	density = 0
	circuit = null

	light_color = null

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"

	light_color = null

/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")
	circuit = "/obj/item/weapon/circuitboard/mining"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = "/obj/item/weapon/circuitboard/security/engineering"

	light_color = LIGHT_COLOR_YELLOW
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
