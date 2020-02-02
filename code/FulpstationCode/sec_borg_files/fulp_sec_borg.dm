//Pepperspray Module

/obj/item/reagent_containers/spray/pepper/cyborg
	name = "Integrated Pepperspray"
	desc = "An integrated pepperspray synthesizer. Use for blinding criminal scum. Utilizes your power supply to synthesize capsaicin spray over time."
	reagent_flags = NONE
	volume = 50
	list_reagents = list(/datum/reagent/consumable/condensedcapsaicin = 50)
	var/charge_cost = 50
	var/generate_amount = 5
	var/generate_type = /datum/reagent/consumable/condensedcapsaicin
	var/last_generate = 0
	var/generate_delay = 50	//deciseconds
	var/upgraded = FALSE
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
	if(!issilicon(src.loc))
		return

	var/mob/living/silicon/robot/R = src.loc
	if(!R || !R.cell)
		return

	if(R.cell.charge < R.cell.use(charge_cost)) //Not enough energy to regenerate reagents.
		return

	if(reagents.total_volume >= volume)
		return

	R.cell.use(charge_cost)
	reagents.add_reagent(generate_type, generate_amount)


//SEC CAMERA UPLINK UPGRADE

/obj/item/handheld_camera_monitor/cyborg

	name = "security camera remote uplink"
	desc = "Used to access the various cameras on the station."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	var/sound = SEC_BODY_CAM_SOUND

/obj/item/handheld_camera_monitor/cyborg/attack_self(mob/user)
	for(var/obj/machinery/computer/security/S in GLOB.machines)
		if(istype(S, /obj/machinery/computer/security/telescreen) || S.stat & (NOPOWER|BROKEN)) //Filter out telescreens and broken/depowered consoles
			continue
		else
			playsound(src, sound, get_clamped_volume(), TRUE, -1)
			S.interact(user)
			return

		if(!S)
			playsound(src, 'sound/machines/buzz-two.ogg', get_clamped_volume(), TRUE, -1)
			to_chat(user,"<span class='warning'>ERROR: No functioning security consoles found for uplink.</span>")

	return

/* //Keeping this here but commented just in case unforeseen bugs make this remote access solution untenable.
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
		cancel_camera_view(user)
		return
	if(!(user in watchers))
		cancel_camera_view(user)
		return
	if(!watchers[user])
		cancel_camera_view(user)
		return
	var/obj/machinery/camera/C = watchers[user]
	if(!C.can_use())
		cancel_camera_view(user)
		return
	if(iscyborg(user) || long_ranged)
		var/list/viewing = viewers(src)
		if(!viewing.Find(user))
			cancel_camera_view(user)
		return
	if(!issilicon(user) && !Adjacent(user))
		cancel_camera_view(user)
		return

/obj/item/handheld_camera_monitor/cyborg/proc/cancel_camera_view(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)

/obj/item/handheld_camera_monitor/cyborg/Destroy()
	if(watchers.len)
		for(var/mob/M in watchers)
			cancel_camera_view(M) //to properly reset the view of the users if the console is deleted.
	return ..()

/obj/item/handheld_camera_monitor/cyborg/attack_self(mob/user)
	if (ismob(user) && !isliving(user)) // ghosts don't need cameras
		return
	if (!network)
		cancel_camera_view(user)
		CRASH("No camera network")
	if (!(islist(network)))
		cancel_camera_view(user)
		CRASH("Camera network is not a list")
	if(..())
		cancel_camera_view(user)
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
			cancel_camera_view(user) // no usable camera on the network, we disconnect the user from the computer.
			return
	playsound(loc, sound, get_clamped_volume(), TRUE, -1)
	use_camera_console(user)

/obj/item/handheld_camera_monitor/cyborg/proc/use_camera_console(mob/user)
	check_bodycamera_unlock(user) ///Fulpstation Sec Bodycamera PR - Surrealistik Oct 2019; allows access to the body camera network with Sec access.
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list

	if(!t)
		cancel_camera_view(user)
		playsound(src, sound, 25, FALSE)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		cancel_camera_view(user)
		playsound(src, sound, 25, FALSE)
		return
	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.eye_blind || user.incapacitated())
			camera_fail = 1

		if(camera_fail)
			cancel_camera_view(user)
			return 0

		playsound(src, sound, 25, FALSE)
		user.reset_perspective(C)
		user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		user.clear_fullscreen("flash", 5)
		watchers[user] = C
		addtimer(CALLBACK(src, .proc/use_camera_console, user), 5)
	else
		cancel_camera_view(user)

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
		network -= "sec_bodycameras"*/

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
	if(!issilicon(usr))
		return
	var/mob/living/silicon/robot/R = usr
	var/obj/item/handheld_camera_monitor/cyborg/PP = locate() in R.module
	if(!PP)
		return
	PP.attack_self(R)

/datum/action/item_action/camera_uplink
	name = "Camera Uplink"
	desc = "Uplink to the station's camera network."

//SEC HOLOBARRIER UPGRADE

/obj/item/borg/upgrade/sec_holobarrier
	name = "cyborg security holobarrier projector"
	desc = "A module that permits creation of holographic security barriers."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_sec"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/security)

/obj/item/borg/upgrade/sec_holobarrier/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/holosign_creator/security/cyborg/E = locate() in R.module.modules
		if(E)
			to_chat(user, "<span class='warning'>This unit already has a [E] installed!</span>")
			return FALSE

		E = new(R.module)
		R.module.basic_modules += E
		R.module.add_module(E, FALSE, TRUE)

/obj/item/borg/upgrade/sec_holobarrier/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/holosign_creator/security/cyborg/E = locate() in R.module.modules
		if (E)
			R.module.remove_module(E, TRUE)

/obj/item/holosign_creator/security/cyborg
	name = "Security Holobarrier Projector"
	desc = "A hard light projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 15
	max_signs = 9
	var/shock = 0

/obj/item/holosign_creator/security/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, "<span class='notice'>You clear all active holograms, and reset your projector to normal.</span>")
			holosign_type = /obj/structure/holosign/barrier
			creation_time = 5
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged&&!shock)
			to_chat(user, "<span class='warning'>You clear all active holograms, and overload your energy projector!</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(signs.len)
				for(var/H in signs)
					qdel(H)
				to_chat(user, "<span class='notice'>You clear all active holograms.</span>")
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")


//INTEGRATED E-BOLA (lol) LAUNCHER

/obj/item/gun/energy/e_gun/e_bola/cyborg
	name = "\improper Integrated E-BOLA Launcher"
	desc = "An integrated e-bola launcher that draws from a cyborg's power cell."
	can_charge = FALSE
	use_cyborg_cell = TRUE
	charge_delay = 8
	ammo_type = list(/obj/item/ammo_casing/energy/bola)

/obj/item/borg/upgrade/e_bola
	name = "cyborg energy bola launcher"
	desc = "A module that permits firing energy bolas."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "dragnet"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/security)

/obj/item/borg/upgrade/e_bola/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/e_gun/e_bola/cyborg/E = locate() in R.module.modules
		if(E)
			to_chat(user, "<span class='warning'>This unit already has a [E] installed!</span>")
			return FALSE

		E = new(R.module)
		R.module.basic_modules += E
		R.module.add_module(E, FALSE, TRUE)

/obj/item/borg/upgrade/e_bola/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/e_gun/e_bola/cyborg/E = locate() in R.module.modules
		if (E)
			R.module.remove_module(E, TRUE)

/obj/item/ammo_casing/energy/bola
	projectile_type = /obj/projectile/energy/trap/cyborg
	select_name = "bola"
	e_cost = 400
	harmful = FALSE

//CYBORG PEPPERSPRAY IMPROVED SYNTHESIZER

/obj/item/borg/upgrade/peppersprayupgrade
	name = "cyborg improved capsaicin synthesizer module"
	desc = "Enhances a security cyborg's integrated pepper spray synthesizer, improving capacity and synthesizing efficiency."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/security)

/obj/item/borg/upgrade/peppersprayupgrade/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/reagent_containers/spray/pepper/cyborg/T = locate() in R.module.modules
		if(!T)
			to_chat(user, "<span class='warning'>There's no pepper spray synthesizer in this unit!</span>")
			return FALSE
		if(T.upgraded)
			to_chat(R, "<span class='warning'>A [T] unit is already installed!</span>")
			to_chat(user, "<span class='warning'>There's no room for another [T]!</span>")
			return FALSE

		T.generate_amount += initial(T.generate_amount)
		T.volume += initial(T.volume)
		T.upgraded = TRUE

/obj/item/borg/upgrade/peppersprayupgrade/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/reagent_containers/spray/pepper/cyborg/T = locate() in R.module.modules
		if(!T)
			return FALSE
		T.generate_amount = initial(T.generate_amount)
		T.volume = initial(T.volume)
		T.upgraded = FALSE

//Records Uplink

/obj/item/handheld_sec_record_uplink/cyborg

	name = "security record remote uplink"
	desc = "Used to access the various cameras on the station."
	icon = 'icons/obj/device.dmi'
	icon_state	= "gangtool-red"
	var/sound = SEC_BODY_CAM_SOUND

/obj/item/handheld_sec_record_uplink/cyborg/attack_self(mob/user)
	for(var/obj/machinery/computer/secure_data/S in GLOB.machines)
		if(S.stat & (NOPOWER|BROKEN)) //Filter out telescreens and broken/depowered consoles
			continue
		else
			playsound(src, sound, get_clamped_volume(), TRUE, -1)
			S.ui_interact(user)
			return

		if(!S)
			playsound(src, 'sound/machines/buzz-two.ogg', get_clamped_volume(), TRUE, -1)
			to_chat(user,"<span class='warning'>ERROR: No functioning security consoles found for uplink.</span>")

	return


/obj/item/handheld_sec_record_uplink/cyborg/ui_action_click()
	if(..())
		return
	if(!issilicon(usr))
		return
	var/mob/living/silicon/robot/R = usr
	var/obj/item/handheld_sec_record_uplink/cyborg/PP = locate() in R.module
	if(!PP)
		return
	PP.attack_self(R)


/datum/action/item_action/sec_record_uplink
	name = "Security Record Uplink"
	desc = "Uplink to the station's security record database."


//CYBORG DESIGN DATUMS

/datum/design/borg_upgrade_cameralink
	name = "Cyborg Upgrade (Camera Uplink)"
	id = "borg_upgrade_cameralink"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/camera_uplink
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_secprojector
	name = "Cyborg Upgrade (Sec Barrier Projector)"
	id = "borg_upgrade_secprojector"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/sec_holobarrier
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_ebola
	name = "Cyborg Upgrade (Integrated E-BOLA Launcher)"
	id = "borg_upgrade_e-bola"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/e_bola
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 2000, /datum/material/gold = 2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_pepperupgrade
	name = "Cyborg Upgrade (Improved Capsaicin Synthesizer)"
	id = "borg_upgrade_pepperspray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/peppersprayupgrade
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")


//TECHWEB ENTRIES

/datum/techweb_node/cyborg_upg_sec
	id = "cyborg_upg_sec"
	display_name = "Cyborg Upgrades: Security"
	description = "Security upgrades for cyborgs."
	prereq_ids = list("sec_basic")
	design_ids = list("borg_upgrade_cameralink", "borg_upgrade_secprojector", "borg_upgrade_e-bola", "borg_upgrade_pepperspray")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000