/mob/living/silicon/ai/proc/get_camera_list()

	if(src.stat == 2)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()
	T["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track = new()
	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(var/camera in get_camera_list())
	set category = "AI Commands"
	set name = "Show Camera List"

	if(src.stat == 2)
		src << "You can't list the cameras because you are dead!"
		return

	if (!camera || camera == "Cancel")
		return 0

	var/obj/machinery/camera/C = track.cameras[camera]
	track = null
	src.eyeobj.setLoc(C)

	return

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	if(usr.stat == 2)
		return list()

	var/datum/trackable/TB = new()
	for(var/mob/living/M in mob_list)
		// Easy checks first.
		// Don't detect mobs on Centcom. Since the wizard den is on Centcomm, we only need this.
		var/turf/T = get_turf(M)
		if(!T)
			continue
		if(T.z == 2)
			continue
		if(T.z > 6)
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
		if (name in TB.names)
			TB.namecounts[name]++
			name = text("[] ([])", name, TB.namecounts[name])
		else
			TB.names.Add(name)
			TB.namecounts[name] = 1
		if(human)
			TB.humans[name] = M
		else
			TB.others[name] = M

	var/list/targets = sortList(TB.humans) + sortList(TB.others)
	src.track = TB
	return targets

/mob/living/silicon/ai/proc/ai_camera_track(var/target_name in trackable_mobs())
	set category = "AI Commands"
	set name = "Track With Camera"
	set desc = "Select who you would like to track."

	if(src.stat == 2)
		src << "You can't track with camera because you are dead!"
		return
	if(!target_name)
		src.cameraFollow = null

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])
	src.track = null
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

/proc/near_camera(var/mob/living/M)
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
	ai_camera_list()

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