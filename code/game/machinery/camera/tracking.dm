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
		if(M.loc.z > 6)
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
		if(!near_camera(M))
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
			if (istype(target, /mob/living/carbon/human))
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

			if(istype(target.loc,/obj/effect/dummy))
				U << "Follow camera mode ended."
				U.cameraFollow = null
				return

			if (!near_camera(target))
				U << "Target is not near any active cameras."
				sleep(100)
				continue

			if(U.eyeobj)
				U.eyeobj.setLoc(get_turf(target))
			else
				view_core()
				return
			sleep(10)

/proc/near_camera(var/mob/M)
	if (!isturf(M.loc))
		return 0
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!cameranet.checkCameraVis(M))
		return 0
	return 1

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user))
		return
	if (!src.can_use())
		return
	user.eyeobj.setLoc(get_turf(src))


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