<<<<<<< HEAD
#define CAMERA_UPGRADE_XRAY 1
#define CAMERA_UPGRADE_EMP_PROOF 2
#define CAMERA_UPGRADE_MOTION 4

=======
var/list/camera_names=list()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
<<<<<<< HEAD
	layer = WALL_OBJ_LAYER

	var/health = 50
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = 1
	var/start_active = 0 //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/machinery/camera_assembly/assembly = null
=======
	layer = 5

	var/datum/wires/camera/wires = null // Wires datum
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/invuln = null
	var/bugged = 0
	var/obj/item/weapon/camera_assembly/assembly = null
	var/light_on = 0

	machine_flags = SCREWTOGGLE //| WIREJACK Needs work
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	//OTHER

	var/view_range = 7
	var/short_range = 2

<<<<<<< HEAD
	var/alarm_on = 0
	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

	// Upgrades bitflag
	var/upgrades = 0

/obj/machinery/camera/New()
	..()
	assembly = new(src)
	assembly.state = 4
	cameranet.cameras += src
	cameranet.addCamera(src)
	add_to_proximity_list(src, 1) //1 was default of everything
	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			world.log << "[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]"
	*/

/obj/machinery/camera/initialize()
	if(z == 1 && prob(3) && !start_active)
		toggle_cam()

/obj/machinery/camera/Move()
	remove_from_proximity_list(src, 1)
	return ..()

/obj/machinery/camera/Destroy()
	toggle_cam(null, 0) //kick anyone viewing out
	remove_from_proximity_list(src, 1)
	if(assembly)
		qdel(assembly)
		assembly = null
	if(bug)
		bug.bugged_cameras -= src.c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	cameranet.cameras -= src
	cameranet.removeCamera(src)
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			update_icon()
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			stat |= EMPED
			SetLuminosity(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			update_icon()
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(loc) //qdel limbo
					triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
					if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
						network = previous_network
						stat &= ~EMPED
						update_icon()
						if(can_use())
							cameranet.addCamera(src)
						emped = 0 //Resets the consecutive EMP count
						addtimer(src, "cancelCameraAlarm", 100)
			for(var/mob/O in mob_list)
				if (O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_perspective(null)
					O << "The screen bursts into static."
			..()


/obj/machinery/camera/ex_act(severity, target)
	if(src.invuln)
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, 0)
		else
			take_damage(rand(30,60), BRUTE, 0)

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
=======
	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0

	var/hear_voice = 0

	var/vision_flags = SEE_SELF //Only applies when viewing the camera through a console.

/obj/machinery/camera/update_icon()
	var/EMPd = stat & EMPED
	var/deactivated = !status
	var/camtype = "camera"
	if(assembly)
		camtype = isXRay() ? "xraycam" : "camera" // Thanks to Krutchen for the icons.

	if (deactivated)
		icon_state = "[camtype]1"
	else if (EMPd)
		icon_state = "[camtype]emp"
	else
		icon_state = "[camtype]"

/obj/machinery/camera/proc/update_hear()//only cameras with voice analyzers can hear, to reduce the number of unecessary /mob/virtualhearer
	if(!hear_voice && isHearing())
		hear_voice = 1
		addHear()
	if(hear_voice && !isHearing())
		hear_voice = 0
		removeHear()

/obj/machinery/camera/proc/update_upgrades()//Called when an upgrade is added or removed.
	if(isXRay())
		vision_flags |= SEE_TURFS | SEE_MOBS | SEE_OBJS
	else
		vision_flags &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)

/obj/machinery/camera/New()
	wires = new(src)

	assembly = new(src)
	assembly.state = 4

	if(!src.network || src.network.len < 1)
		if(loc)
			error("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			error("[src.name] in [get_area(src)]has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)

	if(!c_tag)
		name_camera()
	..()
	if(adv_camera && adv_camera.initialized && !(src in adv_camera.camerasbyzlevel["[z]"]))
		adv_camera.update(z, 0, src, adding=1)

	update_hear()

/obj/machinery/camera/proc/name_camera()
	var/area/A=get_area(src)
	var/basename=A.name
	var/nethash=english_list(network)
	var/suffix = 0
	while(!suffix || nethash+c_tag in camera_names)
		c_tag = "[basename]"
		if(suffix)
			c_tag += " [suffix]"
		suffix++
	camera_names[nethash+c_tag]=src

/obj/machinery/camera/change_area(oldarea, newarea)
	var/nethash=english_list(network)
	camera_names[nethash+c_tag]=null
	..()
	if(name != replacetext(name,oldarea,newarea))
		name_camera()

/obj/machinery/camera/Destroy()
	deactivate(null, 0) //kick anyone viewing out
	if(assembly)
		qdel(assembly)
		assembly = null
	wires = null
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	if(adv_camera)
		for(var/key in adv_camera.camerasbyzlevel)
			adv_camera.camerasbyzlevel[key] -= src
	..()

/obj/machinery/camera/emp_act(severity)
	if(isEmpProof())
		return
	if(prob(100/severity))
		var/list/previous_network = network
		network = list()
		cameranet.removeCamera(src)
		stat |= EMPED
		set_light(0)
		triggerCameraAlarm()
		update_icon()
		spawn(900)
			network = previous_network
			stat &= ~EMPED
			cancelCameraAlarm()
			update_icon()
			if(can_use())
				cameranet.addCamera(src)
				adv_camera.update(z, 0, src, adding=1)
		for(var/mob/O in mob_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O.unset_machine()
					O.reset_view(null)
					to_chat(O, "The screen bursts into static.")
		..()

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	qdel(src)
	return

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/shock(var/mob/living/user)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!istype(user))
		return
	user.electrocute_act(10, src)

<<<<<<< HEAD
/obj/machinery/camera/attackby(obj/W, mob/living/user, params)
	var/msg = "<span class='notice'>You attach [W] into the assembly's inner circuits.</span>"
	var/msg2 = "<span class='notice'>[src] already has that upgrade!</span>"

	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		user << "<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>"
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

	if(panel_open)
		if(istype(W, /obj/item/weapon/wirecutters)) //enable/disable the camera
			toggle_cam(user, 1)
			health = initial(health) //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.
			return

		else if(istype(W, /obj/item/device/multitool)) //change focus
			setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
			user << "<span class='notice'>You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus.</span>"
			return

		else if(istype(W, /obj/item/weapon/weldingtool))
			if(weld(W, user))
				visible_message("<span class='warning'>[user] unwelds [src], leaving it as just a frame screwed to the wall.</span>", "<span class='warning'>You unweld [src], leaving it as just a frame screwed to the wall</span>")
				if(!assembly)
					assembly = new()
				assembly.loc = src.loc
				assembly.state = 1
				assembly.setDir(src.dir)
				assembly = null
				qdel(src)
			return

		else if(istype(W, /obj/item/device/analyzer))
			if(!isXRay())
				if(!user.drop_item(W))
					return
				upgradeXRay()
				qdel(W)
				user << "[msg]"
			else
				user << "[msg2]"
			return

		else if(istype(W, /obj/item/stack/sheet/mineral/plasma))
			if(!isEmpProof())
				upgradeEmpProof()
				user << "[msg]"
				qdel(W)
			else
				user << "[msg2]"
			return

		else if(istype(W, /obj/item/device/assembly/prox_sensor))
			if(!isMotion())
				upgradeMotion()
				user << "[msg]"
				qdel(W)
			else
				user << "[msg2]"
			return

	// OTHER
	if((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
=======
/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	if(!status)
		return
	status = 0
	update_icon()
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(get_turf(src), 'sound/weapons/slash.ogg', 100, 1)
	add_hiddenprint(user)
	deactivate(user,0)

/obj/machinery/camera/attackby(W as obj, mob/living/user as mob)

	// DECONSTRUCTION
	if(isscrewdriver(W))
//		to_chat(user, "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>")
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		togglePanelOpen(W, user, icon_state, icon_state)

	else if(panel_open && iswiretool(W))
		wires.Interact(user)

	else if(istype(W, /obj/item/weapon/weldingtool) && wires.CanDeconstruct())
		if(weld(W, user))
			if(assembly)
				assembly.state = 1
				assembly.loc = src.loc
				assembly = null

			qdel(src)

	// Upgrades!
	else if(is_type_in_list(W, assembly.possible_upgrades)) // Is a possible upgrade
		if (is_type_in_list(W, assembly.upgrades))
			to_chat(user, "The camera already has \a [W] inside!")
			return
		if (!panel_open)
			to_chat(user, "You can't reach into the camera's circuitry while the maintenance panel is closed.")
			return
		/*if (!wires.CanDeconstruct())
			to_chat(user, "You can't reach into the camera's circuitry with the wires on the way.")
			return*/
		if (istype(W, /obj/item/stack))
			var/obj/item/stack/sheet/mineral/plasma/s = W
			s.use(1)
			assembly.upgrades += new /obj/item/stack/sheet/mineral/plasma
		else
			if(!user.drop_item(W, src)) return
			assembly.upgrades += W
		to_chat(user, "You attach the [W] into the camera's inner circuits.")
		update_upgrades()
		update_icon()
		update_hear()
		cameranet.updateVisibility(src, 0)
		return

	// Taking out upgrades
	else if(iscrowbar(W))
		if (!panel_open)
			to_chat(user, "You can't reach into the camera's circuitry while the maintenance panel is closed.")
			return
		/*if (!wires.CanDeconstruct())
			to_chat(user, "You can't reach into the camera's circuitry with the wires on the way.")
			return*/
		if (assembly.upgrades.len)
			var/obj/U = locate(/obj) in assembly.upgrades
			if(U)
				to_chat(user, "You unattach \the [U] from the camera.")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				U.loc = get_turf(src)
				assembly.upgrades -= U
				update_upgrades()
				update_icon()
				update_hear()
				cameranet.updateVisibility(src, 0)
			return
		else //Camera deconned, no upgrades
			to_chat(user, "The camera is firmly welded to the wall.")//User might be trying to deconstruct the camera with a crowbar, let them know what's wrong

			return

	// OTHER
	else if ((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
		user.delayNextAttack(5)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
		U << "<span class='notice'>You hold \the [itemname] up to the camera...</span>"
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					AI << "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				else
					AI << "<b><a href='?src=\ref[AI];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if (O.client && O.client.eye == src)
				O << "[U] holds \a [itemname] up to one of the cameras ..."
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		return

	else if(istype(W, /obj/item/device/camera_bug))
		if(!can_use())
			user << "<span class='notice'>Camera non-functional.</span>"
			return
		if(bug)
			user << "<span class='notice'>Camera bug removed.</span>"
			bug.bugged_cameras -= src.c_tag
			bug = null
		else
			user << "<span class='notice'>Camera bugged.</span>"
			bug = W
			bug.bugged_cameras[src.c_tag] = src
		return

	else if(istype(W, /obj/item/weapon/pai_cable))
		var/obj/item/weapon/pai_cable/cable = W
		cable.plugin(src, user)
		return

	return ..()

/obj/machinery/camera/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(src, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	if(damage < 10) //camera has a damage resistance threshold
		return
	health = max(0, health - damage)
	if(!health && status)
		triggerCameraAlarm()
		toggle_cam(null, 0)

/obj/machinery/camera/update_icon()
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else if (stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = 1)
	status = !status
	if(can_use())
		cameranet.addCamera(src)
	else
		SetLuminosity(0)
		cameranet.removeCamera(src)
	cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"
		triggerCameraAlarm()
		addtimer(src, "cancelCameraAlarm", 100)
	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
	update_icon()

=======
		to_chat(U, "You hold \a [itemname] up to the camera ...")
		for(var/mob/living/silicon/ai/O in living_mob_list)
			if(!O.client) continue
			if(U.name == "Unknown") to_chat( O, "<span class='name'>[U]</span> holds \a [itemname] up to one of your cameras ...")
			else to_chat(O, "<span class='name'><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></span> holds \a [itemname] up to one of your cameras ...")

			O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		for(var/mob/O in player_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
					O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
	else
		..()
	return

/obj/machinery/camera/attack_pai(mob/user as mob)
	wirejack(user)

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !( src.status )
		update_icon()
		if (!(src.status))
			if(user)
				visible_message("<span class='warning'>[user] has deactivated [src]!</span>")
				add_hiddenprint(user)
			else
				visible_message("<span class='warning'> \The [src] deactivates!</span>")
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			add_hiddenprint(user)
		else
			if(user)
				visible_message("<span class='warning'> [user] has reactivated [src]!</span>")
				add_hiddenprint(user)
			else
				visible_message("<span class='warning'> \The [src] reactivates!</span>")
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			add_hiddenprint(user)
		cameranet.updateVisibility(src, 0)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
<<<<<<< HEAD
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_perspective(null)
			O << "The screen bursts into static."

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", get_area(src), src)
=======
		if (istype(O.machine, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/S = O.machine
			if (S.current == src)
				O.unset_machine()
				O.reset_view(null)
				to_chat(O, "The screen bursts into static.")
	if(choice && can_use()) //camera reactivated
		adv_camera.update(z, 0, src, adding=1)
	else //either deactivated OR being destroyed
		adv_camera.update(z, 0, src, adding=2)

/obj/machinery/camera/proc/triggerCameraAlarm()
	if(!alarm_on)
		adv_camera.update(z, 0, src, adding=4) //1 is alarming, 0 is nothing wrong
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", areaMaster, list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	if(alarm_on)
		adv_camera.update(z, 0, src, adding=4) //1 is alarming, 0 is nothing wrong
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", areaMaster, src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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
		see = get_hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
<<<<<<< HEAD
	var/turf/closed/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.setDir(SOUTH)
				if(SOUTH)
					src.setDir(NORTH)
				if(WEST)
					src.setDir(EAST)
				if(EAST)
					src.setDir(WEST)
=======
	var/turf/simulated/wall/T = null

	for (var/direction in cardinal)
		T = get_ranged_target_turf(src, direction, 1)

		if (istype(T))
			dir = reverse_direction(direction)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
=======


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

<<<<<<< HEAD
/obj/machinery/camera/proc/weld(obj/item/weapon/weldingtool/WT, mob/living/user)
	if(busy)
		return 0
	if(!WT.remove_fuel(0, user))
		return 0

	user << "<span class='notice'>You start to weld [src]...</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	busy = 1
	if(do_after(user, 100, target = src))
=======
/obj/machinery/camera/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)


	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to weld the [src].</span>")
	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, src, 100))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

<<<<<<< HEAD
/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A in ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		src.SetLuminosity(AI_CAMERA_LUMINOSITY)
	else
		src.SetLuminosity(0)

/obj/machinery/camera/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/New()
	..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = 0
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(cameranet && get_turf(src) != prev_turf)
		cameranet.updatePortableCamera(src)
		prev_turf = get_turf(src)

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	if(isXRay())
		user.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		user.see_in_dark = max(user.see_in_dark, 8)
	else
		user.sight = 0
		user.see_in_dark = 2
	return 1
=======
/obj/machinery/camera/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		P.set_machine(P)
		P.current = src
		P.reset_view(src)
		return 1
	return 0

/obj/machinery/camera/proc/tv_message(var/atom/movable/hearer, var/datum/speech/speech)
	speech.wrapper_classes.Add("tv")
	hearer.Hear(speech)

	/*
	var/namepart =  "[speaker.GetVoice()][speaker.get_alt_name()] "
	var/messagepart = "<span class='message'>[hearer.lang_treat(speaker, speaking, raw_message)]</span>"

	return "<span class='game say'><span class='name'>[namepart]</span>[messagepart]</span>"
	*/

/obj/machinery/camera/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(isHearing())
		for(var/obj/machinery/computer/security/S in tv_monitors)
			if(S.current == src)
				if(istype(S, /obj/machinery/computer/security/telescreen))
					for(var/mob/M in viewers(world.view,S))
						to_chat(M, "<span style='color:grey'>[bicon(S)][tv_message(M, speech, rendered_speech)]</span>")
				else
					for(var/mob/M in viewers(1,S))
						to_chat(M, "<span style='color:grey'>[bicon(S)][tv_message(M, speech, rendered_speech)]</span>")

/obj/machinery/camera/arena
	name = "arena camera"
	desc = "A camera anchored to the floor, designed to survive hits and explosions of any size. What's it made of anyway?"
	icon_state = "camerarena"
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	layer = 2.1

/obj/machinery/camera/arena/New()
	..()
	pixel_x = 0
	pixel_y = 0
	upgradeXRay()
	upgradeHearing()

/obj/machinery/camera/arena/attackby(W as obj, mob/living/user as mob)
	if(isscrewdriver(W))
		to_chat(user, "<span class='warning'>There aren't any visible screws to unscrew.</span>")
	else
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W] but it doesn't seem to affect it in the least.</span>","<span class='warning'>You hit \the [src] with \the [W] but it doesn't seem to affect it in the least</span>")
	return

/obj/machinery/camera/arena/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	user.visible_message("<span class='warning'>\The [user] slashes at \the [src], but that didn't affect it at all.</span>","<span class='warning'>You slash at \the [src], but that didn't affect it at all.</span>")
	return

/obj/machinery/camera/arena/update_icon()
	return

/obj/machinery/camera/arena/emp_act(severity)
	return

/obj/machinery/camera/arena/ex_act(severity)
	return

/obj/machinery/camera/arena/blob_act(severity)
	return

/obj/machinery/camera/arena/singularity_act(severity)//those are really good cameras
	return

/obj/structure/planner/arena/cultify()
	return

/obj/machinery/camera/arena/attack_pai(mob/user as mob)
	return

/obj/machinery/camera/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	H.apply_damage(rand(1,2), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
