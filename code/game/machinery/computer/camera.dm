/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	var/last_pic = 1
	var/list/network = list("ss13")
	var/list/watchers = list() //who's using the console, associated with the camera they're on.

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security/Initialize()
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)

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
	. = ..()
	if(.)
		return
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
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
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

// SECURITY MONITORS

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the station's camera network."
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list("mine", "auxbase")
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "research camera console"
	desc = "Used to access the various cameras in science."
	network = list("rd")
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/hos
	name = "Head of Security's camera console"
	desc = "A custom security console with added access to the labor camp network."
	network = list("ss13", "labor")
	circuit = null

/obj/machinery/computer/security/labor
	name = "labor camp monitoring"
	desc = "Used to access the various cameras on the labor camp."
	network = list("labor")
	circuit = null

/obj/machinery/computer/security/qm
	name = "Quartermaster's camera console"
	desc = "A console with access to the mining, auxillary base and vault camera networks."
	network = list("mine", "auxbase", "vault")
	circuit = null

// TELESCREENS

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

/obj/machinery/computer/security/telescreen/rd
	name = "Research Director's telescreen"
	desc = "Used for watching the AI and the RD's goons from the safety of his office."
	network = list("rd", "aicore", "aiupload", "minisat", "xeno", "test")

/obj/machinery/computer/security/telescreen/circuitry
	name = "circuitry telescreen"
	desc = "Used for watching the other eggheads from the safety of the circuitry lab."
	network = list("rd")

/obj/machinery/computer/security/telescreen/ce
	name = "Chief Engineer's telescreen"
	desc = "Used for watching the engine, telecommunications and the minisat."
	network = list("engine", "singularity", "tcomms", "minisat")

/obj/machinery/computer/security/telescreen/cmo
	name = "Chief Medical Officer's telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list("medbay")

/obj/machinery/computer/security/telescreen/vault
	name = "Vault monitor"
	desc = "A telescreen that connects to the vault's camera network."
	network = list("vault")

/obj/machinery/computer/security/telescreen/toxins
	name = "Bomb test site monitor"
	desc = "A telescreen that connects to the bomb test site's camera."
	network = list("toxin")

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network."
	network = list("engine")

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = "A telescreen that connects to the turbine's camera."
	network = list("turbine")

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = "A telescreen that connects to the interrogation room's camera."
	network = list("interrogation")

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "A telescreen that connects to the permabrig's camera network."
	network = list("prison")

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxillary base monitor"
	desc = "A telescreen that connects to the auxillary base's camera."
	network = list("auxbase")

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "A telescreen that connects to the minisat's camera network."
	network = list("minisat")

/obj/machinery/computer/security/telescreen/aiupload
	name = "AI upload monitor"
	desc = "A telescreen that connects to the AI upload's camera network."
	network = list("aiupload")
