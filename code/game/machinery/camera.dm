/mob/living/silicon/ai/proc/ai_camera_list()
	set category = "AI Commands"
	set name = "Show Camera List"

	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	attack_ai(src)

/mob/living/silicon/ai/proc/ai_camera_track()
	set category = "AI Commands"
	set name = "Track With Camera"
	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()

	for(var/mob/living/M in mob_list)
		// Easy checks first.
		// Don't detect mobs on Centcom. Since the wizard den is on Centcomm, we only need this.
		if(M.loc.z == 2)
			continue
		if(M == usr)
			continue
		if(M.invisibility)//cloaked
			continue
		if(M.digitalcamo)
			continue

		// Human check
		var/human = 0
		if(istype(M, /mob/living/carbon/human))
			human = 1
			var/mob/living/carbon/human/H = M
			//Cameras can't track people wearing an agent card or a ninja hood.
			if(istype(H.wear_id, /obj/item/weapon/card/id/syndicate))
				continue
		 	if(istype(H.head, /obj/item/clothing/head/helmet/space/space_ninja))
		 		var/obj/item/clothing/head/helmet/space/space_ninja/hood = H.head
	 			if(!hood.canremove)
	 				continue
		 // Now, are they viewable by a camera? (This is last because it's the most intensive check)
		if(!cameranet.checkCameraVis(M))
			continue

		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = text("[] ([])", name, namecounts[name])
		else
			names.Add(name)
			namecounts[name] = 1
		if(human)
			humans[name] = M
		else
			others[name] = M

	var/list/targets = sortList(humans) + sortList(others)
	var/target_name = input(usr, "Which creature should you track?") as null|anything in targets

	if (!target_name)
		usr:cameraFollow = null
		return

	var/mob/target = (isnull(humans[target_name]) ? others[target_name] : humans[target_name])
	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target as mob)
	if(!istype(target))	return
	var/mob/living/silicon/ai/U = usr

	U.cameraFollow = target
	//U << text("Now tracking [] on camera.", target.name)
	//if (U.machine == null)
	//	U.machine = U
	U << "Now tracking [target.name] on camera."

	spawn (0)
		while (U.cameraFollow == target)
			if (U.cameraFollow == null)
				return
			else if (istype(target, /mob/living/carbon/human))
				if(istype(target:wear_id, /obj/item/weapon/card/id/syndicate))
					U << "Follow camera mode terminated."
					U.cameraFollow = null
					return
		 		if(istype(target:head, /obj/item/clothing/head/helmet/space/space_ninja) && !target:head:canremove)
		 			U << "Follow camera mode terminated."
					U.cameraFollow = null
					return
				if(target.digitalcamo)
					U << "Follow camera mode terminated."
					U.cameraFollow = null
					return

			else if(istype(target.loc,/obj/effect/dummy))
				U << "Follow camera mode ended."
				U.cameraFollow = null
				return
			else if (!target || !istype(target.loc, /turf)) //in a closet
				U << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(30) //because we're sleeping another second after this (a few lines down)
				continue
			else if(!cameranet.checkCameraVis(target))
				U << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(30) //because we're sleeping another second after this (a few lines down)
				continue

			U.eyeobj.setLoc(get_turf(target))
			sleep(10)

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L

/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	if (user != src)
		return

	if (stat == 2)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			D[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if (!t || t == "Cancel")
		return 0

	var/obj/machinery/camera/C = D[t]
	src.eyeobj.setLoc(C)

	return

/obj/machinery/camera/emp_act(severity)
	if(prob(100/(hardened + severity)))
		icon_state = "cameraemp"
		network = null                   //Not the best way but it will do. I think.
		cameranet.removeCamera(src)
		stat |= EMPED
		SetLuminosity(0)
		spawn(900)
			network = initial(network)
			icon_state = initial(icon_state)
			stat &= ~EMPED
			if(can_use())
				cameranet.addCamera(src)
		for(var/mob/O in mob_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O.machine = null
					O.reset_view(null)
					O << "The screen bursts into static."
		..()

/obj/machinery/camera/emp_proof/emp_act(severity)
	return

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	return

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user))
		return
	if (!src.can_use())
		return
	user.eyeobj.setLoc(get_turf(src))

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	status = 0
	for(var/mob/O in viewers(user, null))
		O.show_message("<span class='warning'>\The [user] slashes at [src]!</span>", 1)
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	icon_state = "camera1"
	add_hiddenprint(user)
	deactivate(user,0)

/obj/machinery/camera/attackby(W as obj, user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		deactivate(user)
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
		U << "You hold \a [itemname] up to the camera ..."
		for(var/mob/living/silicon/ai/O in player_list)
			//if (O.current == src)
			if(U.name == "Unknown") O << "<b>[U]</b> holds \a [itemname] up to one of your cameras ..."
			else O << "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></b> holds \a [itemname] up to one of your cameras ..."
			O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		for(var/mob/O in player_list)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O << "[U] holds \a [itemname] up to one of the cameras ..."
					O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
	else if (istype(W, /obj/item/weapon/wrench)) //Adding dismantlable cameras to go with the constructable ones. --NEO
		if(src.status)
			user << "\red You can't dismantle a camera while it is active."
		else
			user << "\blue Dismantling camera..."
			if(do_after(user, 20))
				var/obj/item/weapon/grenade/chem_grenade/case = new /obj/item/weapon/grenade/chem_grenade(src.loc)
				case.name = "Camera Assembly"
				case.icon = 'icons/obj/monitors.dmi'
//JESUS WHAT THE FUCK EVERYTHING TO DO WITH CAMERAS IS TERRIBLE FUCK
				case.icon_state = "cameracase"
				case.path = 2
				case.state = 5
				case.circuit = new /obj/item/device/multitool
				if (istype(src, /obj/machinery/camera/motion))
					case.motion = 1
				del(src)
	else if (istype(W, /obj/item/weapon/camera_bug))
		if (!src.can_use())
			user << "\blue Camera non-functional"
			return
		if (src.bugged)
			user << "\blue Camera bug removed."
			src.bugged = 0
		else
			user << "\blue Camera bugged."
			src.bugged = 1
	else if(istype(W, /obj/item/weapon/melee/energy/blade))//Putting it here last since it's a special case. I wonder if there is a better way to do these than type casting.
		deactivate(user,2)//Here so that you can disconnect anyone viewing the camera, regardless if it's on or off.
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)

		var/obj/item/weapon/grenade/chem_grenade/case = new /obj/item/weapon/grenade/chem_grenade(loc)
		case.name = "Camera Assembly"
		case.icon = 'icons/obj/monitors.dmi'
		case.icon_state = "cameracase"
		case.path = 2
		case.state = 5
		case.circuit = new /obj/item/device/multitool
		if (istype(src, /obj/machinery/camera/motion))
			case.motion = 1

		for(var/mob/O in viewers(user, 3))
			O.show_message(text("\blue The camera has been sliced apart by [] with an energy blade!", user), 1, text("\red You hear metal being sliced and sparks flying."), 2)
		del(src)
	else
		..()
	return

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !( src.status )
		if (!(src.status))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] has deactivated []!", user, src), 1)
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = "camera1"
			add_hiddenprint(user)
		else
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] has reactivated []!", user, src), 1)
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = "camera"
			add_hiddenprint(user)
	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if (istype(O.machine, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/S = O.machine
			if (S.current == src)
				O.machine = null
				O.reset_view(null)
				O << "The screen bursts into static."

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(!isnull(T) && istype(T))
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