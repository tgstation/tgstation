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
	var/list/records = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	track.names.Cut()
	track.namecounts.Cut()
	track.records.Cut()

	if(stat == DEAD)
		return list()

	for(var/datum/data/record/G in data_core.general)
		var/record_id = G.fields["id"]
		if(!(G.fields["faceprint"] && record_id))
			continue
		var/name = G.fields["name"]
		if(!name)
			name = "&lt;NAME MISSING&gt;"
		if (name in track.names)
			track.namecounts[name]++
			name = text("[] ([])", name, track.namecounts[name])
		else
			track.names.Add(name)
			track.namecounts[name] = 1
		track.records[name] = record_id
	var/list/targets = sortList(track.records)

	return targets

/mob/living/silicon/ai/proc/ai_track_href(atom/A, record_id)
	if(record_id)
		. = ";track=[record_id]"
	else
		var/turf/T = get_turf(A)
		if(T)
			. = ";trackfromcoords=1;X=[T.x];Y=[T.y];Z=[T.z]"
		else
			. = ";notrace=1"

/mob/living/silicon/ai/proc/mobs_from_record(datum/data/record/R)
	if(!R)
		return
	var/list/found = list()
	var/R_faceprint = R.fields["faceprint"]
	if(!R_faceprint)
		return
	for(var/mob/living/L in mob_list)
		if(!(L.can_see_face() && L.can_track(src)))
			continue
		var/L_faceprint = L.get_faceprint()
		if(L_faceprint == R_faceprint)
			found += L
	. = found.len ? found : null

/mob/living/silicon/ai/verb/ai_camera_track(target_name in trackable_mobs())
	set name = "track"
	set hidden = 1 //Don't display it on the verb lists. This verb exists purely so you can type "track Oldman Robustin" and follow his ass

	if(!target_name)
		return

	var/record_id = track.records[target_name]
	if(!record_id)
		return
	var/datum/data/record/G = find_record("id", record_id, data_core.general)
	if(!G)
		src << "<span class='notice'>Unable to locate [target_name] in crew records.</span>"
		return
	var/list/targets = mobs_from_record(G)
	if(targets && targets.len)
		ai_actual_track(pick(targets))
	else
		src << "<span class='notice'>[target_name]'s facial signature was not detected on the camera network.</span>"

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target))
		return

	if(!(target && target.can_track(src)))
		to_chat(src, "<span class='warning'>Target is not near any active cameras.</span>")
		return

	cameraFollow = target
	tracking = 1

	var/cameraticks = 0
	spawn(0)
		while(cameraFollow == target)
			if(cameraFollow == null)
				return

			if(!target.can_track(src))
				tracking = 1
				if(!cameraticks)
					to_chat(src, "<span class='warning'>Target is not near any active cameras. Attempting to reacquire...</span>")
				cameraticks++
				if(cameraticks > 9)
					cameraFollow = null
					to_chat(src, "<span class='warning'>Unable to reacquire, cancelling track...</span>")
					tracking = 0
					return
				else
					sleep(10)
					continue

			else
				cameraticks = 0
				tracking = 0

			if(eyeobj)
				eyeobj.setLoc(get_turf(target))

			else
				view_core()
				cameraFollow = null
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
