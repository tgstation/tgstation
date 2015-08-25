/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked = list(  )
	var/track_special_role

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 2

/obj/machinery/computer/crew/New()
	tracked = list()
	html_machines += src
	..()

/obj/machinery/computer/crew/Destroy()
	..()
	html_machines -= src

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor.show(user)

/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

var/global/datum/interactive_map/crewmonitor/crewmonitor = new

/datum/interactive_map/crewmonitor
	var/list/jobs

/datum/interactive_map/crewmonitor/New()
	. = ..()

	var/list/jobs = new/list()
	jobs["Captain"] = 00
	jobs["Head of Personnel"] = 50
	jobs["Head of Security"] = 10
	jobs["Warden"] = 11
	jobs["Security Officer"] = 12
	jobs["Detective"] = 13
	jobs["Chief Medical Officer"] = 20
	jobs["Chemist"] = 21
	jobs["Geneticist"] = 22
	jobs["Virologist"] = 23
	jobs["Medical Doctor"] = 24
	jobs["Research Director"] = 30
	jobs["Scientist"] = 31
	jobs["Roboticist"] = 32
	jobs["Chief Engineer"] = 40
	jobs["Station Engineer"] = 41
	jobs["Atmospheric Technician"] = 42
	jobs["Quartermaster"] = 51
	jobs["Shaft Miner"] = 52
	jobs["Cargo Technician"] = 53
	jobs["Bartender"] = 61
	jobs["Cook"] = 62
	jobs["Botanist"] = 63
	jobs["Librarian"] = 64
	jobs["Chaplain"] = 65
	jobs["Clown"] = 66
	jobs["Mime"] = 67
	jobs["Janitor"] = 68
	jobs["Lawyer"] = 69
	jobs["Admiral"] = 200
	jobs["Centcom Commander"] = 210
	jobs["Emergency Response Team Commander"] = 220
	jobs["Security Response Officer"] = 221
	jobs["Engineer Response Officer"] = 222
	jobs["Medical Response Officer"] = 223
	jobs["Assistant"] = 999 //Unknowns/custom jobs should appear after civilians, and before assistants

	src.jobs = jobs

/datum/interactive_map/crewmonitor/show(mob/mob, z, datum/html_interface/currui = null)
	if (!z) z = mob.z
	if (z == CENTCOMM_Z) return

	if (z > 0 && src.interfaces)
		var/datum/html_interface/hi

		if (!src.interfaces["[z]"])
			src.interfaces["[z]"] = new/datum/html_interface/nanotrasen(src, "Crew Monitoring", 900, 800, "[MAPHEADER] <link rel=\"stylesheet\" type=\"text/css\" href=\"crewmonitor.css\" /></script><script type=\"text/javascript\">var z = [z]; var tile_size = [world.icon_size]; var maxx = [world.maxx]; var maxy = [world.maxy];</script><script type=\"text/javascript\" src=\"crewmonitor.js\"></script>")

			hi = src.interfaces["[z]"]

			hi.updateContent("content", MAPCONTENT)

			src.update(z, TRUE)
		else
			hi = src.interfaces["[z]"]
			src.update(z, TRUE)

		hi = src.interfaces["[z]"]
		hi.show(mob, currui)
		src.updateFor(mob, hi, z)

/datum/interactive_map/crewmonitor/updateFor(hclient_or_mob, datum/html_interface/hi, z)
	..()

/datum/interactive_map/crewmonitor/update(z, ignore_unused = FALSE)
	if (src.interfaces["[z]"])
		var/datum/html_interface/hi = src.interfaces["[z]"]

		if (ignore_unused || hi.isUsed())
			var/list/results = list()
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
			var/see_pos_x
			var/see_pos_y
			var/life_status

			for(var/mob/living/carbon/human/H in mob_list)
				if(H.iscorpse) continue
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
							see_pos_x = pos.x - WORLD_X_OFFSET[z]
							see_pos_y = pos.y - WORLD_Y_OFFSET[z]
						else
							area = null
							pos_x = null
							pos_y = null
							see_pos_x = null
							see_pos_y = null
						results[++results.len] = list(name, assignment, ijob, life_status, dam1, dam2, dam3, dam4, area, pos_x, pos_y, H.monitor_check(), see_pos_x, see_pos_y)
			for(var/mob/living/carbon/brain/B in mob_list)
				var/obj/item/device/mmi/M = B.loc
				pos = get_turf(B)
				if(pos && pos.z != CENTCOMM_Z && (pos.z == z) && istype(M) && M.brainmob == B && !isrobot(M.loc) )

					var/area/parea = get_area(B)
					area = format_text(parea.name)
					see_pos_x = pos.x - WORLD_X_OFFSET[z]
					see_pos_y = pos.y - WORLD_Y_OFFSET[z]

					results[++results.len] = list(M.name, "MMI", 80, (B.stat || !B.key ? "false" : "true"), null, null, null, null, area, pos.x, pos.y, 1, see_pos_x, see_pos_y)

			src.data = results
			src.updateFor(null, hi, z) // updates for everyone

/mob/living/carbon/human/proc/monitor_check()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/carbon/human/proc/monitor_check() called tick#: [world.time]")
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	if(T.z == CENTCOMM_Z) //dont detect mobs on centcomm
		return 0
	if(T.z >= map.zLevels.len)
		return 0
	. = 1

/datum/interactive_map/crewmonitor/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
/*	zlevel limit removed on /vg/
	var/z = ""

	for (z in src.interfaces)
		if (src.interfaces[z] == hi) break
*/
	return ( ..() /*&& hclient.client.mob.z == text2num(z)*/ && hclient.client.mob.html_mob_check(/obj/machinery/computer/crew))

/datum/interactive_map/crewmonitor/Topic(href, href_list[], datum/html_interface_client/hclient)
	if(..()) return // Our parent handled it the topic call
	if (istype(hclient))
		if (hclient && hclient.client && hclient.client.mob && isAI(hclient.client.mob))
			var/mob/living/silicon/ai/AI = hclient.client.mob

			switch (href_list["action"])
				if ("select_person")
					AI.ai_camera_track(href_list["name"])

				if ("select_position")
					var/x = text2num(href_list["x"])
					var/y = text2num(href_list["y"])
					var/turf/tile = locate(x, y, AI.z)

					var/obj/machinery/camera/C = locate(/obj/machinery/camera) in range(5, tile)

					if (!C) C = locate(/obj/machinery/camera) in range(10, tile)
					if (!C) C = locate(/obj/machinery/camera) in range(15, tile)

					if (C)
						var/turf/current_loc = AI.eyeobj.loc

						spawn(min(30, get_dist(get_turf(C), AI.eyeobj) / 4))
							if (AI && AI.eyeobj && current_loc == AI.eyeobj.loc)
								AI.switchCamera(C)
				if ("crewclick")
					var/x = text2num(href_list["x"])
					var/y = text2num(href_list["y"])
					var/turf/tile = locate(x, y, AI.z)
					if(tile)
						AI.eyeobj.forceMove(tile)

/datum/interactive_map/crewmonitor/queueUpdate(z)
	var/datum/controller/process/html/html = processScheduler.getProcess("html")
	html.queue(crewmonitor, "update", z)

/datum/interactive_map/crewmonitor/sendResources(client/C)
	..()
	C << browse_rsc('crewmonitor.js')
	C << browse_rsc('crewmonitor.css')
