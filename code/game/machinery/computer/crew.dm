/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = /obj/item/weapon/circuitboard/computer/crew
	var/monitor = null	//For VV debugging purposes

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/crew/New()
	monitor = crewmonitor
	return ..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor.show(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor.show(user)

var/global/datum/crewmonitor/crewmonitor = new

/datum/crewmonitor
	var/list/jobs
	var/list/interfaces
	var/list/data
	var/list/tracking

/datum/crewmonitor/New()
	. = ..()

	var/list/new_jobs = list()
	new_jobs["Captain"] = 00
	new_jobs["Head of Personnel"] = 50
	new_jobs["Head of Security"] = 10
	new_jobs["Warden"] = 11
	new_jobs["Security Officer"] = 12
	new_jobs["Detective"] = 13
	new_jobs["Chief Medical Officer"] = 20
	new_jobs["Chemist"] = 21
	new_jobs["Geneticist"] = 22
	new_jobs["Virologist"] = 23
	new_jobs["Medical Doctor"] = 24
	new_jobs["Research Director"] = 30
	new_jobs["Scientist"] = 31
	new_jobs["Roboticist"] = 32
	new_jobs["Chief Engineer"] = 40
	new_jobs["Station Engineer"] = 41
	new_jobs["Atmospheric Technician"] = 42
	new_jobs["Quartermaster"] = 51
	new_jobs["Shaft Miner"] = 52
	new_jobs["Cargo Technician"] = 53
	new_jobs["Bartender"] = 61
	new_jobs["Cook"] = 62
	new_jobs["Botanist"] = 63
	new_jobs["Librarian"] = 64
	new_jobs["Chaplain"] = 65
	new_jobs["Clown"] = 66
	new_jobs["Mime"] = 67
	new_jobs["Janitor"] = 68
	new_jobs["Lawyer"] = 69
	new_jobs["Admiral"] = 200
	new_jobs["Centcom Commander"] = 210
	new_jobs["Custodian"] = 211
	new_jobs["Medical Officer"] = 212
	new_jobs["Research Officer"] = 213
	new_jobs["Emergency Response Team Commander"] = 220
	new_jobs["Security Response Officer"] = 221
	new_jobs["Engineer Response Officer"] = 222
	new_jobs["Medical Response Officer"] = 223
	new_jobs["Assistant"] = 999 //Unknowns/custom jobs should appear after civilians, and before assistants

	jobs = new_jobs
	interfaces = list()
	data = list()
	tracking = list()
	register_asset("crewmonitor.js",'crew.js')
	register_asset("crewmonitor.css",'crew.css')

/datum/crewmonitor/Destroy()
	if (interfaces)
		for (var/datum/html_interface/hi in interfaces)
			qdel(hi)
		interfaces = null

	return ..()

/datum/crewmonitor/proc/show(mob/mob, z)
	if (mob.client)
		sendResources(mob.client)
	if (!z) z = mob.z

	if (z > 0 && interfaces)
		var/datum/html_interface/hi

		if (!interfaces["[z]"])
			interfaces["[z]"] = new/datum/html_interface/nanotrasen(src, "Crew Monitoring", 900, 540, "<link rel=\"stylesheet\" type=\"text/css\" href=\"crewmonitor.css\" /><script type=\"text/javascript\">var z = [z]; var tile_size = [world.icon_size]; var maxx = [world.maxx]; var maxy = [world.maxy];</script><script type=\"text/javascript\" src=\"crewmonitor.js\"></script>")

			hi = interfaces["[z]"]

			hi.updateContent("content", "<div id=\"minimap\"><a href=\"javascript:zoomIn();\" class=\"zoom in\">+</a><a href=\"javascript:zoomOut();\" class=\"zoom\">-</a></div><div id=\"textbased\"></div>")

			update(z, TRUE)
		else
			hi = interfaces["[z]"]
			update(z,TRUE)

		// Debugging purposes
		mob << browse_rsc(file("code/game/machinery/computer/crew.js"), "crew.js")
		mob << browse_rsc(file("code/game/machinery/computer/crew.css"), "crew.css")

		hi = interfaces["[z]"]
		hi.show(mob)
		updateFor(mob, hi, z)

/datum/crewmonitor/proc/updateFor(hclient_or_mob, datum/html_interface/hi, z)
	// This check will succeed if updateFor is called after showing to the player, but will fail
	// on regular updates. Since we only really need this once we don't care if it fails.
	hi.callJavaScript("clearAll", null, hclient_or_mob)

	for (var/list/L in data)
		hi.callJavaScript("add", L, hclient_or_mob)

	hi.callJavaScript("onAfterUpdate", null, hclient_or_mob)

/datum/crewmonitor/proc/update(z, ignore_unused = FALSE)
	if (interfaces["[z]"])
		var/datum/html_interface/hi = interfaces["[z]"]

		if (ignore_unused || hi.isUsed())
			var/list/results = list()
			var/list/new_tracking = list()
			var/obj/item/clothing/under/U
			var/obj/item/weapon/card/id/I
			var/turf/pos
			var/ijob
			var/name
			var/assignment
			var/dam1
			var/dam2
			var/dam3
			var/dam4
			var/area
			var/pos_x
			var/pos_y
			var/life_status
			var/tracking_pos

			for(var/mob/living/carbon/human/H in mob_list)
				// Check if their z-level is correct and if they are wearing a uniform.
				// Accept H.z==0 as well in case the mob is inside an object.
				if ((H.z == 0 || H.z == z) && istype(H.w_uniform, /obj/item/clothing/under))
					U = H.w_uniform

					// Are the suit sensors on?
					if (U.has_sensor && U.sensor_mode)
						pos = H.z == 0 || U.sensor_mode == 3 ? get_turf(H) : null

						// Special case: If the mob is inside an object confirm the z-level on turf level.
						if (H.z == 0 && (!pos || pos.z != z)) continue

						I = H.wear_id ? H.wear_id.GetID() : null

						if (I)
							name = I.registered_name
							assignment = I.assignment
							ijob = jobs[I.assignment]
						else
							name = "<i>Unknown</i>"
							assignment = ""
							ijob = 80

						if (U.sensor_mode >= 1) life_status = (!H.stat ? "true" : "false")
						else                    life_status = null

						if (U.sensor_mode >= 2)
							dam1 = round(H.getOxyLoss(),1)
							dam2 = round(H.getToxLoss(),1)
							dam3 = round(H.getFireLoss(),1)
							dam4 = round(H.getBruteLoss(),1)
						else
							dam1 = null
							dam2 = null
							dam3 = null
							dam4 = null

						if (U.sensor_mode >= 3)
							if (!pos) pos = get_turf(H)
							var/area/player_area = get_area(H)

							area = format_text(player_area.name)
							pos_x = pos.x
							pos_y = pos.y
							tracking_pos = ++new_tracking.len
							new_tracking[tracking_pos] = H
						else
							area = null
							pos_x = null
							pos_y = null
							tracking_pos = null

						results[++results.len] = list(name, assignment, ijob, life_status, dam1, dam2, dam3, dam4, area, pos_x, pos_y, H.can_track(null), tracking_pos)

			data = results
			tracking = new_tracking
			updateFor(null, hi, z) // updates for everyone

/datum/crewmonitor/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	var/z = ""

	for (z in interfaces)
		if (interfaces[z] == hi) break

	if(hclient.client.mob && IsAdminGhost(hclient.client.mob))
		return TRUE

	if (hclient.client.mob && hclient.client.mob.stat == 0 && hclient.client.mob.z == text2num(z))
		if (isAI(hclient.client.mob)) return TRUE
		else if (iscyborg(hclient.client.mob))
			return (locate(/obj/machinery/computer/crew, range(world.view, hclient.client.mob))) || (locate(/obj/item/device/sensor_device, hclient.client.mob.contents))
		else
			return (locate(/obj/machinery/computer/crew, range(1, hclient.client.mob))) || (locate(/obj/item/device/sensor_device, hclient.client.mob.contents))
	else
		return FALSE

/datum/crewmonitor/Topic(href, href_list[], datum/html_interface_client/hclient)
	if (istype(hclient))
		if (hclient && hclient.client && hclient.client.mob && isAI(hclient.client.mob))
			var/mob/living/silicon/ai/AI = hclient.client.mob

			switch (href_list["action"])
				if ("select_person")
					var/tracking_pos = text2num(href_list["trackingpos"])
					var/mob/target = tracking[tracking_pos]
					if(target)
						AI.ai_actual_track(target)

				if ("select_position")
					var/x = text2num(href_list["x"])
					var/y = text2num(href_list["y"])
					var/turf/tile = locate(x, y, AI.z)

					var/obj/machinery/camera/C = locate(/obj/machinery/camera) in range(5, tile)

					if (!C) C = locate(/obj/machinery/camera) in urange(10, tile)
					if (!C) C = locate(/obj/machinery/camera) in urange(15, tile)

					if (C)
						addtimer(CALLBACK(src, .proc/update_ai, AI, C, AI.eyeobj.loc), min(30, get_dist(get_turf(C), AI.eyeobj) / 4))

/datum/crewmonitor/proc/update_ai(mob/living/silicon/ai/AI, obj/machinery/camera/C, turf/current_loc)
	if (AI && AI.eyeobj && current_loc == AI.eyeobj.loc)
		AI.switchCamera(C)

/mob/living/carbon/human/Move()
	if (w_uniform)
		var/old_z = z

		. = ..()

		if (old_z != z) crewmonitor.queueUpdate(old_z)
		crewmonitor.queueUpdate(z)
	else
		return ..()

/datum/crewmonitor/proc/queueUpdate(z)
	addtimer(CALLBACK(crewmonitor, .proc/update, z), 5, TIMER_UNIQUE)

/datum/crewmonitor/proc/sendResources(var/client/client)
	send_asset(client, "crewmonitor.js")
	send_asset(client, "crewmonitor.css")
	SSminimap.send(client)
