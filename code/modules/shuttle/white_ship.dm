/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/weapon/circuitboard/computer/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland"

/obj/machinery/computer/shuttle/engi_ship
	name = "Engi Ship Console"
	desc = "Used to control the Engi Ship."
	circuit = /obj/item/weapon/circuitboard/computer/engi_ship
	shuttleId = "engi_ship"
	possible_destinations = null
	var/dwidth = 11
	var/dheight = 11
	var/width = 22
	var/height = 22
	var/lz_dir = 1
	var/target_area = null
	var/area/picked_area = null
	var/shuttle_id = "engi_ship"

/obj/machinery/computer/shuttle/engi_ship/attack_hand(mob/user)
	if(..(user))
		return
	src.add_fingerprint(user)

	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			destination_found = 1
			dat += "<A href='?src=\ref[src];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>No Destination Detected</B><br>"
			dat += "<A href='?src=\ref[src];action=select'>Select Location</A><br>"
	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/shuttle/engi_ship/Topic(href, href_list)
	if(href_list["action"])
		if("select")
			target_area = input("Area to land", "Select a Landing Zone", target_area) in teleportlocs
			picked_area = teleportlocs[target_area]
			if(!src || QDELETED(src))
				return
			var/turf/T = safepick(get_area_turfs(picked_area))
			if(!T)
				return
			var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
			landing_zone.id = "engi_ship(\ref[src])"
			landing_zone.name = "Landing Zone"
			landing_zone.dwidth = dwidth
			landing_zone.dheight = dheight
			landing_zone.width = width
			landing_zone.height = height
			landing_zone.setDir(lz_dir)
			for(var/obj/machinery/computer/shuttle/S in machines)
				if(S.shuttleId == shuttle_id)
					S.possible_destinations = "[landing_zone.id]"
			to_chat(usr, "Landing zone set to [landing_zone.id].")
	..()

/obj/docking_port/mobile/engi_ship
	name = "Engineering Ship"
	id = "engi_ship"
	dwidth = 11
	dheight = 11
	width = 22
	height = 22