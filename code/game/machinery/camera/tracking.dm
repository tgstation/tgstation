/mob/living/silicon/ai/proc/get_camera_list()

	track.cameras.Cut()

	if(src.stat == 2)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network&src.network
		if (tempnetwork.len)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(camera)
	if (!camera)
		return 0

	var/obj/machinery/camera/C = track.cameras[camera]
	src.eyeobj.setLoc(C)

	return

/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	track.names.Cut()
	track.namecounts.Cut()
	track.humans.Cut()
	track.others.Cut()

	if(usr.stat == 2)
		return list()

	for(var/mob/living/M in mob_list)
		if(!M.can_track(usr))
			continue

		// Human check
		var/human = 0
		if(ishuman(M))
			human = 1

		var/name = M.name
		if (name in track.names)
			track.namecounts[name]++
			name = text("[] ([])", name, track.namecounts[name])
		else
			track.names.Add(name)
			track.namecounts[name] = 1
		if(human)
			track.humans[name] = M
		else
			track.others[name] = M

	var/list/targets = sortList(track.humans) + sortList(track.others)

	return targets

/mob/living/silicon/ai/verb/ai_camera_track(target_name in trackable_mobs())
	set name = "track"
	set hidden = 1 //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	if(!target_name)
		return

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])

	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target))
		return
	var/mob/living/silicon/ai/U = usr

	U.cameraFollow = target
	U.tracking = 1

	if(!target || !target.can_track(usr))
		to_chat(U, "<span class='warning'>Target is not near any active cameras.</span>")
		U.cameraFollow = null
		return

	to_chat(U, "<span class='notice'>Now tracking [target.get_visible_name()] on camera.</span>")

	var/cameraticks = 0
	spawn(0)
		while(U.cameraFollow == target)
			if(U.cameraFollow == null)
				return

			if(!target.can_track(usr))
				U.tracking = 1
				if(!cameraticks)
					to_chat(U, "<span class='warning'>Target is not near any active cameras. Attempting to reacquire...</span>")
				cameraticks++
				if(cameraticks > 9)
					U.cameraFollow = null
					to_chat(U, "<span class='warning'>Unable to reacquire, cancelling track...</span>")
					tracking = 0
					return
				else
					sleep(10)
					continue

			else
				cameraticks = 0
				U.tracking = 0

			if(U.eyeobj)
				U.eyeobj.setLoc(get_turf(target))

			else
				view_core()
				U.cameraFollow = null
				return

			sleep(10)

/proc/near_camera(mob/living/M)
	if (!isturf(M.loc))
		return 0
	if(iscyborg(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!cameranet.checkCameraVis(M))
		return 0
	return 1

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!src.can_use())
		return
	user.eyeobj.setLoc(get_turf(src))


/mob/living/silicon/ai/attack_ai(mob/user)
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
