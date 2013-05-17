/obj/item/device/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state = "mindflash2"
	w_class = 1.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	var/obj/machinery/camera/current = null
	var/list/bugged_cameras = list()
	var/skip_bugcheck = 0

/obj/item/device/camera_bug/proc/get_cameras()
	return bugged_cameras

/obj/item/device/camera_bug/proc/format_list(var/list/cameras)
	if(!cameras || !cameras.len)
		usr << "No bugged cameras found."
		usr << browse(null,"window=camerabug")
		return
	var/html = "<h3>Select a camera:</h3><hr>"
	for(var/entry in cameras)
		var/obj/machinery/camera/C = cameras[entry]
		html += "<a href='?src=\ref[src];view=\ref[C]'>[entry]</a><br>"
	return html

/obj/item/device/camera_bug/attack_self(mob/user as mob)
	interact()

/obj/item/device/camera_bug/interact()
	var/datum/browser/popup = new(usr, "camerabug","Camera Bug",nref=src)
	popup.set_content(format_list(get_cameras()))
	popup.open()

/obj/item/device/camera_bug/Topic(var/href,var/list/href_list)
	if("close" in href_list)
		usr.reset_view(null)
		usr.unset_machine()
		return // I do not
	if("view" in href_list)
		var/obj/machinery/camera/C = locate(href_list["view"])
		if(istype(C))
			if(!C.can_use())
				usr << "\red Something's wrong with that camera.  You can't get a feed."
				return
			var/turf/T = get_turf(loc)
			if(!T || C.z != T.z)
				usr << "\red You can't get a signal."
				return
			current = C
			if(src.check_eye(usr))
				usr.set_machine(src)
				usr.reset_view(C)
			else
				usr.unset_machine()
				usr.reset_view(null)

	interact()

/obj/item/device/camera_bug/check_eye(var/mob/user as mob)
	if (user.stat || loc != user || !user.canmove || user.blinded || !current || !current.can_use())
		user.reset_view(null)
		user.unset_machine()
		return null

	var/turf/T = get_turf(user.loc)
	if(T.z != current.z || (!skip_bugcheck && current.bug != src))
		user << "You've lost the signal."
		current = null
		user.reset_view(null)
		user.unset_machine()
		return null

	return 1

/obj/item/device/camera_bug/universal
	desc = "For illicit snooping through the camera network.  Has multiple micro-antennae."
	skip_bugcheck = 1
	var/last_update = 0

/obj/item/device/camera_bug/universal/get_cameras()
	bugged_cameras = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(C.bug)
			bugged_cameras[C.c_tag] = C
	return bugged_cameras

/obj/item/device/camera_bug/sabotage
	desc = "For illicit snooping through the camera network.  Has a suspicious button on the side."
/obj/item/device/camera_bug/sabotage/format_list(var/list/cameras)
	if(!cameras || !cameras.len)
		usr << "No bugged cameras found."
		return
	var/html = "<h3>Select a camera:</h3><hr>"
	for(var/entry in cameras)
		var/obj/machinery/camera/C = cameras[entry]
		html += "<a href='?src=\ref[src];view=\ref[C]'>[entry]</a> <a href='?src=\ref[src];emp=\ref[C]'>\[Disable\]</a><br>"
	return html
/obj/item/device/camera_bug/sabotage/Topic(var/href,var/href_list)
	if("emp" in href_list)
		var/obj/machinery/camera/C = locate(href_list["emp"])
		if(istype(C) && C.bug == src)
			C.emp_act(1)
			C.bug = null
			bugged_cameras -= C.c_tag
		interact()
		return
	..(href,href_list)


/obj/item/device/camera_bug/networked
	desc = "For illicit snooping through the camera network.  Has a single large antenna."
	skip_bugcheck = 1
	var/last_update = 0

/obj/item/device/camera_bug/networked/get_cameras()
	if(!bugged_cameras.len || (world.time > (last_update + 50)))
		bugged_cameras = list()
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if("SS13" in C.network)
				bugged_cameras[C.c_tag] = C
	return bugged_cameras


/obj/item/device/camera_bug/tracker
	desc = "For illicit snooping through the camera network.  Has an unusually large screen."
	/*
		Mode 0: No tracking - normal but with report button
		Mode 1: Monitor one camera - reports
		Mode 2: Track one target
	*/
	var/mode = 0
	var/last_tracked = 0

	var/refresh_interval = 100

	var/tracked_name = null
	var/atom/tracking = null

	var/last_found = null
	var/last_seen = null

	var/tmp/list/seen_list = null

/obj/item/device/camera_bug/tracker/New()
	..()
	processing_objects.Add(src)

/obj/item/device/camera_bug/tracker/format_list(var/list/cameras)
	var/dat = ""
	switch(mode)
		if(0)
			if(!cameras || !cameras.len)
				usr << "No bugged cameras found."
				return
			var/html = "<h3>Select a camera:</h3><hr>"
			for(var/entry in cameras)
				var/obj/machinery/camera/C = cameras[entry]
				html += "<a href='?src=\ref[src];view=\ref[C]'>[entry]</a> <a href='?src=\ref[src];monitor=\ref[C]'>\[Monitor\]</a><br>"
			return html
		if(1)
			if(current)
				dat = "Analyzing Camera '[current.c_tag]' <a href='?\ref[src];mode=0'>\[Select Camera\]</a><br>"
				dat += camera_report()
			else
				dat = "No camera selected. <a href='?\ref[src];mode=0'>\[Select Camera\]</a><br>"
		if(2)
			if(tracking)
				dat += "Tracking '[tracked_name]'  <a href='?\ref[src];mode=0'>\[Cancel Tracking\]</a><br>"
				if(last_found)
					var/time_diff = round((world.time - last_seen) / 600)
					var/obj/machinery/camera/C = bugged_cameras[last_found]
					var/outstring
					if(C)
						outstring = "<a href='?\ref[src];view=\ref[C]'>[last_found]</a>"
					else
						outstring = last_found
					if(!time_diff)
						dat += "Last seen near [outstring] (now)<br>"
					else
						dat += "Last seen near [outstring] ([time_diff] minute\s ago)<br>"
				else
					dat += "Not yet seen."
			else
				mode = 0
				return .()
	return dat

/obj/item/device/camera_bug/tracker/proc/camera_report()
	// this should only be called if current exists
	var/dat = ""
	if(current && current.can_use())
		var/list/seen = current.can_see()
		seen_list = seen
		var/list/names = list()
		for(var/obj/machinery/singularity/S in seen) // god help you if you see more than one
			if(S.name in names)
				names[S.name]++
				dat += "[S.name] ([names[S.name]])"
			else
				names[S.name] = 1
				dat += "[S.name]"
			var/stage = round(S.current_size / 2)+1
			dat += " (Stage [stage])"
			dat += " <a href='?\ref[src];track=\ref[S]'>\[Track\]</a><br>"

		for(var/obj/mecha/M in seen)
			if(M.name in names)
				names[M.name]++
				dat += "[M.name] ([names[M.name]])"
			else
				names[M.name] = 1
				dat += "[M.name]"
			dat += " <a href='?\ref[src];track=\ref[M]'>\[Track\]</a><br>"


		for(var/mob/living/M in seen)
			if(M.name in names)
				names[M.name]++
				dat += "[M.name] ([names[M.name]])"
			else
				names[M.name] = 1
				dat += "[M.name]"
			if(M.buckled && !M.lying)
				dat += " (Sitting)"
			if(M.lying)
				dat += " (Laying down)"
			dat += " <a href='?\ref[src];track=\ref[M]'>\[Track\]</a><br>"
		if(length(dat) == 0)
			dat += "No motion detected."
		return dat
	else
		return "Camera Offline<br>"

/obj/item/device/camera_bug/tracker/process()
	if(mode == 0 || (world.time < (last_tracked + refresh_interval)))
		return
	last_tracked = world.time
	if(mode==2) // search for user
		// Note that it will be tricked if your name appears to change.
		// This is not optimal but it is better than tracking you relentlessly despite everything.
		if(!tracking || tracking.name != tracked_name)
			updateDialog()
			return

		var/list/tracking_cams = list()
		var/list/b_cams = get_cameras()
		for(var/entry in b_cams)
			tracking_cams += b_cams[entry]
		var/list/target_region = view(tracking)

		for(var/obj/machinery/camera/C in (target_region & tracking_cams))
			if(C.can_use())
				last_found = C.c_tag
				last_seen = world.time
				updateUsrDialog()
				return
	updateDialog()

/obj/item/device/camera_bug/tracker/Topic(var/href,var/list/href_list)
	if("mode" in href_list)
		mode = text2num(href_list["mode"])
	if("monitor" in href_list)
		var/obj/machinery/camera/C = locate(href_list["monitor"])
		if(C)
			current = C
			usr.reset_view(null)
			mode = 1
			interact()
	if("track" in href_list)
		var/atom/A = locate(href_list["track"])
		if(A)
			tracking = A
			tracked_name = A.name
			last_found = current.c_tag
			last_seen = world.time
			mode = 2
	..(href,href_list)