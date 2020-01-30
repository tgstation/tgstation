//Pepperspray Module

/obj/item/reagent_containers/spray/pepper/cyborg
	reagent_flags = NONE
	volume = 50
	list_reagents = list(/datum/reagent/consumable/condensedcapsaicin = 50)
	var/generate_amount = 5
	var/generate_type = /datum/reagent/consumable/condensedcapsaicin
	var/last_generate = 0
	var/generate_delay = 10	//deciseconds
	can_fill_from_container = FALSE

// Fix pepperspraying yourself
/obj/item/reagent_containers/spray/pepper/cyborg/afterattack(atom/A as mob|obj, mob/user)
	if (A.loc == user)
		return
	. = ..()

/obj/item/reagent_containers/spray/pepper/cyborg/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/reagent_containers/spray/pepper/cyborg/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/reagent_containers/spray/pepper/cyborg/process()
	if(world.time < last_generate + generate_delay)
		return
	last_generate = world.time
	generate_reagents()

/obj/item/reagent_containers/spray/pepper/cyborg/empty()
	to_chat(usr, "<span class='warning'>You can not empty this!</span>")
	return

/obj/item/reagent_containers/spray/pepper/cyborg/proc/generate_reagents()
	reagents.add_reagent(generate_type, generate_amount)


/obj/item/handheld_camera_monitor/cyborg

	name = "security camera remote uplink"
	desc = "Used to access the various cameras on the station."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	var/sound = SEC_BODY_CAM_SOUND
	var/last_pic = 1
	var/list/network = list("ss13")
	var/list/watchers = list() //who's using the console, associated with the camera they're on.
	var/long_ranged = FALSE

/obj/item/handheld_camera_monitor/cyborg/Initialize()
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)

/obj/item/handheld_camera_monitor/cyborg/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"

/obj/item/handheld_camera_monitor/cyborg/check_eye(mob/user)
	if( user.incapacitated() || user.eye_blind )
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
	if(iscyborg(user) || long_ranged)
		var/list/viewing = viewers(src)
		if(!viewing.Find(user))
			user.unset_machine()
		return
	if(!issilicon(user) && !Adjacent(user))
		user.unset_machine()
		return

/obj/item/handheld_camera_monitor/cyborg/on_unset_machine(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)

/obj/item/handheld_camera_monitor/cyborg/Destroy()
	if(watchers.len)
		for(var/mob/M in watchers)
			M.unset_machine() //to properly reset the view of the users if the console is deleted.
	return ..()

/obj/item/handheld_camera_monitor/cyborg/attack_self(mob/user)
	if (ismob(user) && !isliving(user)) // ghosts don't need cameras
		return
	if (!network)
		user.unset_machine()
		CRASH("No camera network")
	if (!(islist(network)))
		user.unset_machine()
		CRASH("Camera network is not a list")
	if(..())
		user.unset_machine()
		return

	check_bodycamera_unlock(user) ///Fulpstation Sec Bodycamera PR - Surrealistik Oct 2019; allows access to the body camera network with Sec access.
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
	playsound(loc, sound, get_clamped_volume(), TRUE, -1)
	use_camera_console(user)

/obj/item/handheld_camera_monitor/cyborg/proc/use_camera_console(mob/user)
	check_bodycamera_unlock(user) ///Fulpstation Sec Bodycamera PR - Surrealistik Oct 2019; allows access to the body camera network with Sec access.
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
	if(user.machine != src) //while we were choosing we got disconnected from our computer or are using another machine.
		return
	if(!t)
		user.unset_machine()
		playsound(src, sound, 25, FALSE)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		user.unset_machine()
		playsound(src, sound, 25, FALSE)
		return
	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.machine != src || user.eye_blind || user.incapacitated())
			camera_fail = 1
		else if(iscyborg(user) || long_ranged)
			var/list/viewing = viewers(src)
			if(!viewing.Find(user))
				camera_fail = 1
		else if(!issilicon(user) && !Adjacent(user))
			camera_fail = 1

		if(camera_fail)
			user.unset_machine()
			return 0

		playsound(src, sound, 25, FALSE)
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			user.clear_fullscreen("flash", 5)
		watchers[user] = C
		addtimer(CALLBACK(src, .proc/use_camera_console, user), 5)
	else
		user.unset_machine()

//returns the list of cameras accessible from this computer
/obj/item/handheld_camera_monitor/cyborg/proc/get_available_cameras()
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

/obj/item/handheld_camera_monitor/cyborg/proc/check_bodycamera_unlock(user)
	if(allowed(user))
		network += "sec_bodycameras" //We can tap into the body camera network with appropriate access
	else
		network -= "sec_bodycameras"




/obj/item/borg/upgrade/camera_uplink
	name = "cyborg camera uplink"
	desc = "A module that permits remote access to the station's camera network."
	icon = 'icons/obj/device.dmi'
	icon_state = "camera_bug"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/security)
	var/datum/action/camera_uplink

/obj/item/borg/upgrade/camera_uplink/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/handheld_camera_monitor/cyborg/PP = locate() in R.module
		if(PP)
			to_chat(user, "<span class='warning'>This unit is already equipped with a [PP]!</span>")
			return FALSE

		PP = new(R.module)
		R.module.basic_modules += PP
		R.module.add_module(PP, FALSE, TRUE)
		camera_uplink = new /datum/action/item_action/camera_uplink(src)
		camera_uplink.Grant(R)


/obj/item/borg/upgrade/camera_uplink/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		camera_uplink.Remove(R)
		QDEL_NULL(camera_uplink)
		var/obj/item/handheld_camera_monitor/cyborg/PP = locate() in R.module
		R.module.remove_module(PP, TRUE)

/obj/item/borg/upgrade/camera_uplink/ui_action_click()
	if(..())
		return
	if(issilicon(usr))
		return
	var/mob/living/silicon/robot/R = usr
	var/obj/item/handheld_camera_monitor/cyborg/PP = locate() in R.module
	if(!PP)
		return
	PP.attack_self(usr)

/datum/action/item_action/camera_uplink
	name = "Security Camera Uplink"
	desc = "Uplink to the security camera network."