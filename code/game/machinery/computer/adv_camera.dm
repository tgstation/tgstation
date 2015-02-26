/obj/machinery/computer/security/advanced
	name = "Advanced Security Cameras"
	desc = "Used to access the various cameras on the station with an interactive user interface."
	circuit = "/obj/item/weapon/circuitboard/security/advanced"

/obj/item/weapon/circuitboard/security/advanced
	name = "Circuit board (Advanced Security)"
	build_path = /obj/machinery/computer/security/advanced

/obj/machinery/computer/security/advanced/attack_hand(var/mob/user as mob)
	if (src.z > 6)
		user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return
	if(stat & (NOPOWER|BROKEN))	return
	ui_interact(user)

	return

/obj/machinery/computer/security/advanced/check_eye(var/mob/user as mob)
	if (( ( get_dist(user, src) > 1 ) || !( user.canmove ) || ( user.blinded )) && (!istype(user, /mob/living/silicon)))
		return null
	if(stat & (NOPOWER|BROKEN)) return null
	user.reset_view(current)
	return 1

/obj/machinery/computer/security/advanced/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if((user.stat && !isobserver(user)) || !check_eye(user))
		if(current)
			user.reset_view(null)
		return
	if(current)
		if(!( current.status )  || (current.stat & (EMPED)))
			user << "<span class='warning'>The screen bursts into static!</span>"
			user.reset_view(null)
			current = null
		else
			user.reset_view(current)
	var/list/data[0]
	data["camera"]=null
	if(current)
		data["camera"] = "\ref[current]"

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/cams=list()
	for(var/obj/machinery/camera/C in L) // removing sortAtom because nano updates it just enough for the lag to happen
		var/turf/pos = get_turf(C)
		var/list/camera_data=list()
		camera_data["ID"]="\ref[C]"
		camera_data["status"] = ((C.stat & (NOPOWER|BROKEN|EMPED)) ? 2 : (C.status ? 0 : 1))
		camera_data["name"] = text("[]", C.c_tag)
		camera_data["area"] = get_area(C)
		camera_data["x"] = pos.x
		camera_data["y"] = pos.y
		camera_data["z"] = pos.z
		cams+=list(camera_data)
	data["cameras"]=cams

	if (!ui) // no ui has been passed, so we'll search for one
		ui = nanomanager.get_open_ui(user, src, ui_key)

	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "adv_camera.tmpl", name, 900, 800)
		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "adv_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "adv_camera_map_header.tmpl")
		// When the UI is first opened this is the data it will use
		// we want to show the map by default
		ui.set_show_map(1)

		ui.set_initial_data(data)

		ui.open()
		// Auto update every Master Controller tick
		if(current)
			ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/computer/security/advanced/Topic(href, href_list)
	if(..())
		return 0

	if(href_list["cancel"])
		usr.reset_view(null)
		current = null
	if(href_list["close"])
		usr.reset_view(null)
		if(usr.machine == src)
			usr.unset_machine()
	if(href_list["view"])
		var/obj/machinery/camera/cam = locate(href_list["view"])
		if(cam)
			if(isAI(usr))
				var/mob/living/silicon/ai/A = usr
				A.eyeobj.setLoc(get_turf(cam))
				A.client.eye = A.eyeobj
			else
				use_power(50)
				current = cam
				usr.reset_view(current)
	return 1