/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

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
	var/const/MAX_ICON_DIMENSION = 1024
	var/const/ICON_SIZE = 4
	var/initialized = FALSE

/datum/crewmonitor/New()
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
	jobs["Custodian"] = 211
	jobs["Medical Officer"] = 212
	jobs["Research Officer"] = 213
	jobs["Emergency Response Team Commander"] = 220
	jobs["Security Response Officer"] = 221
	jobs["Engineer Response Officer"] = 222
	jobs["Medical Response Officer"] = 223
	jobs["Assistant"] = 999 //Unknowns/custom jobs should appear after civilians, and before assistants

	src.jobs = jobs
	src.interfaces = list()
	src.data = list()

/datum/crewmonitor/Destroy()
	if (src.interfaces)
		for (var/datum/html_interface/hi in interfaces)
			qdel(hi)
		src.interfaces = null

	return ..()

/datum/crewmonitor/proc/show(mob/mob, z)
	if (!z) z = mob.z

	if (z > 0 && src.interfaces)
		var/datum/html_interface/hi

		if (!src.interfaces["[z]"])
			src.interfaces["[z]"] = new/datum/html_interface/nanotrasen(src, "Crew Monitoring", 900, 540, "<link rel=\"stylesheet\" type=\"text/css\" href=\"crewmonitor.css\" /><script type=\"text/javascript\">var z = [z]; var tile_size = [world.icon_size]; var maxx = [world.maxx]; var maxy = [world.maxy];</script><script type=\"text/javascript\" src=\"crewmonitor.js\"></script>")

			hi = src.interfaces["[z]"]

			hi.updateContent("content", "<div id=\"minimap\"><a href=\"javascript:zoomIn();\" class=\"zoom in\">+</a><a href=\"javascript:zoomOut();\" class=\"zoom\">-</a></div><div id=\"textbased\"></div>")

			src.update(z, TRUE)
		else
			hi = src.interfaces["[z]"]

		// Debugging purposes
		mob << browse_rsc(file("code/game/machinery/computer/crew.js"), "crew.js")
		mob << browse_rsc(file("code/game/machinery/computer/crew.css"), "crew.css")

		hi = src.interfaces["[z]"]
		hi.show(mob)
		src.updateFor(mob, hi, z)

/datum/crewmonitor/proc/updateFor(hclient_or_mob, datum/html_interface/hi, z)
	// This check will succeed if updateFor is called after showing to the player, but will fail
	// on regular updates. Since we only really need this once we don't care if it fails.
	hi.callJavaScript("clearAll", null, hclient_or_mob)

	for (var/list/L in data)
		hi.callJavaScript("add", L, hclient_or_mob)

	hi.callJavaScript("onAfterUpdate", null, hclient_or_mob)

/datum/crewmonitor/proc/update(z, ignore_unused = FALSE)
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
			var/life_status

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
						else
							area = null
							pos_x = null
							pos_y = null

						results[++results.len] = list(name, assignment, ijob, life_status, dam1, dam2, dam3, dam4, area, pos_x, pos_y, H.can_track(null))

			src.data = results
			src.updateFor(null, hi, z) // updates for everyone

/datum/crewmonitor/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	var/z = ""

	for (z in src.interfaces)
		if (src.interfaces[z] == hi) break

	if (hclient.client.mob && hclient.client.mob.stat == 0 && hclient.client.mob.z == text2num(z))
		if (isAI(hclient.client.mob)) return TRUE
		else if (isrobot(hclient.client.mob))
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

/mob/living/carbon/human/Move()
	if (src.w_uniform)
		var/old_z = src.z

		. = ..()

		if (old_z != src.z) crewmonitor.queueUpdate(old_z)
		crewmonitor.queueUpdate(src.z)
	else
		return ..()

/datum/crewmonitor/proc/queueUpdate(z)
	procqueue.schedule(50, crewmonitor, "update", z)

/datum/crewmonitor/proc/generateMiniMaps()
	spawn
		for (var/z = 1 to world.maxz) src.generateMiniMap(z)

		world << "<span class='boldannounce'>All minimaps have been generated."

		for (var/client/C in clients)
			src.sendResources(C)

		src.initialized = TRUE

/datum/crewmonitor/proc/sendResources(client/C)
	C << browse_rsc('crew.js', "crewmonitor.js")
	C << browse_rsc('crew.css', "crewmonitor.css")
	for (var/z = 1 to world.maxz) C << browse_rsc(file("[getMinimapFile(z)].png"), "minimap_[z].png")

/datum/crewmonitor/proc/getMinimapFile(z)
	return "data/minimaps/map_[z]"

// Activate this to debug tile mismatches in the minimap.
// This will store the full information on each tile and compare it the next time you run the minimap.
// It can be used to find out what's changed since the last iteration.
// Only activate this when you need it - this should never be active on a live server!
// #define MINIMAP_DEBUG

/datum/crewmonitor/proc/generateMiniMap(z, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	var/result_path = "[src.getMinimapFile(z)].png"
	var/hash_path = "[src.getMinimapFile(z)].md5"
	var/list/tiles = block(locate(x1, y1, z), locate(x2, y2, z))
	var/hash = ""
	var/temp
	var/obj/obj

	#ifdef MINIMAP_DEBUG
	var/tiledata_path = "data/minimaps/debug_tiledata_[z].sav"
	var/savefile/F = new/savefile(tiledata_path)
	#endif

	// Note for future developer: If you have tiles on the map with random or dynamic icons this hash check will fail
	// every time. You'll have to modify this code to generate a unique hash for your object.
	// Don't forget to modify the minimap generation code to use a default icon (or skip generation altogether).
	for (var/turf/tile in tiles)
		if      (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/simulated/mineral) || (istype(tile.loc, /area/space) && istype(tile, /turf/simulated/floor/plating/asteroid)))
			temp = "/area/asteroid"
		else if (istype(tile.loc, /area/mine) && istype(tile, /turf/simulated/floor/plating/asteroid))
			temp = "/area/mine/explored"
		else if (tile.loc.type == /area/start || (tile.type == /turf/space && !(locate(/obj/structure/lattice) in tile)) || istype(tile, /turf/space/transit))
			temp = "/turf/space"
			if (locate(/obj/structure/lattice/catwalk) in tile)

			else
		else if (tile.type == /turf/space)
			if (locate(/obj/structure/lattice/catwalk) in tile)
				temp = "/obj/structure/lattice/catwalk"
			else
				temp = "/obj/structure/lattice"
		else if (tile.type == /turf/simulated/floor/plating/abductor)
			temp = "/turf/simulated/floor/plating/abductor"
		else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/window/shuttle) in tile))
			temp = "/obj/structure/window/shuttle"
		else
			temp = "[tile.icon][tile.icon_state][tile.dir]"

		obj = locate(/obj/structure/transit_tube) in tile

		if (obj) temp = "[temp]/obj/structure/transit_tube[obj.icon_state][obj.dir]"

		#ifdef MINIMAP_DEBUG
		if (F["/[tile.y]/[tile.x]"] && F["/[tile.y]/[tile.x]"] != temp)
			CRASH("Mismatch: [tile.type] at [tile.x],[tile.y],[tile.z] ([tile.icon], [tile.icon_state], [tile.dir])")
		else
			F["/[tile.y]/[tile.x]"] << temp
		#endif

		hash = md5("[hash][temp]")

	if (fexists(result_path))
		if (!fexists(hash_path) || trim(file2text(hash_path)) != hash)
			fdel(result_path)
			fdel(hash_path)

	if (!fexists(result_path))
		ASSERT(x1 > 0)
		ASSERT(y1 > 0)
		ASSERT(x2 <= world.maxx)
		ASSERT(y2 <= world.maxy)

		var/icon/map_icon = new/icon('html/mapbase1024.png')

		// map_icon is fine and contains only 1 direction at this point.

		ASSERT(map_icon.Width() == MAX_ICON_DIMENSION && map_icon.Height() == MAX_ICON_DIMENSION)


		var/i = 0
		var/icon/turf_icon
		var/icon/obj_icon
		var/old_icon
		var/old_icon_state
		var/old_dir
		var/new_icon
		var/new_icon_state
		var/new_dir

		for (var/turf/tile in tiles)
			if (tile.loc.type != /area/start && (tile.type != /turf/space || (locate(/obj/structure/lattice) in tile) || (locate(/obj/structure/transit_tube) in tile)) && !istype(tile, /turf/space/transit))
				if (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/simulated/mineral) || (istype(tile.loc, /area/space) && istype(tile, /turf/simulated/floor/plating/asteroid)))
					new_icon = 'icons/turf/mining.dmi'
					new_icon_state = "rock"
					new_dir = 2
				else if (istype(tile.loc, /area/mine) && istype(tile, /turf/simulated/floor/plating/asteroid))
					new_icon = 'icons/turf/floors.dmi'
					new_icon_state = "asteroid"
					new_dir = 2
				else if (tile.type == /turf/simulated/floor/plating/abductor)
					new_icon = 'icons/turf/floors.dmi'
					new_icon_state = "alienpod1"
					new_dir = 2
				else if (tile.type == /turf/space)
					obj = locate(/obj/structure/lattice) in tile

					if (!obj) obj = locate(/obj/structure/transit_tube) in tile

					ASSERT(obj != null)

					if (obj)
						new_icon = obj.icon
						new_dir = obj.dir
						new_icon_state = obj.icon_state
				else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/window/shuttle) in tile))
					new_icon = 'icons/obj/structures.dmi'
					new_dir = 2
					new_icon_state = "swindow"
				else
					new_icon = tile.icon
					new_icon_state = tile.icon_state
					new_dir = tile.dir

				if (new_icon != old_icon || new_icon_state != old_icon_state || new_dir != old_dir)
					old_icon = new_icon
					old_icon_state = new_icon_state
					old_dir = new_dir

					turf_icon = new/icon(new_icon, new_icon_state, new_dir, 1, 0)
					turf_icon.Scale(ICON_SIZE, ICON_SIZE)

				if (tile.type != /turf/space || (locate(/obj/structure/lattice) in tile))
					obj = locate(/obj/structure/transit_tube) in tile

					if (obj)
						obj_icon = new/icon(obj.icon, obj.icon_state, obj.dir, 1, 0)
						obj_icon.Scale(ICON_SIZE, ICON_SIZE)
						turf_icon.Blend(obj_icon, ICON_OVERLAY)

				map_icon.Blend(turf_icon, ICON_OVERLAY, ((tile.x - 1) * ICON_SIZE), ((tile.y - 1) * ICON_SIZE))

				if ((++i) % 512 == 0) sleep(1) // deliberate delay to avoid lag spikes

			else
				sleep(-1) // avoid sleeping if possible: prioritize pending procs

		// BYOND BUG: map_icon now contains 4 directions? Create a new icon with only a single state.
		var/icon/result_icon = new/icon()

		result_icon.Insert(map_icon, "", SOUTH, 1, 0)

		fcopy(result_icon, result_path)
		text2file(hash, hash_path)

#ifdef MINIMAP_DEBUG
#undef MINIMAP_DEBUG
#endif
