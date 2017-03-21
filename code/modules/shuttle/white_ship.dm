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


/obj/machinery/computer/shuttle/engi_ship/Topic(href, href_list)
	if(href_list["move"])
		if(z == ZLEVEL_CENTCOM)
			to_chat(usr, "<span class='warning'>Centcom has barred your ship from leaving!</span>")
			return 0
	..()



/obj/docking_port/mobile/engi_ship
	name = "engi ship"
	id = "engi_ship"
	dwidth = 11
	dheight = 11
	width = 24
	height = 24


/obj/item/device/engi_ship
	name = "Ass Pod Targetting Device"
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Used to select a landing zone for assault pods."
	var/shuttle_id = "engi_ship"
	var/dwidth = 11
	var/dheight = 11
	var/width = 24
	var/height = 24
	var/lz_dir = 1


/obj/item/device/engi_ship/attack_self(mob/living/user)
	var/target_area
	target_area = input("Area to land", "Select a Landing Zone", target_area) in teleportlocs
	var/area/picked_area = teleportlocs[target_area]
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

	to_chat(user, "Landing zone set.")
	qdel(src)