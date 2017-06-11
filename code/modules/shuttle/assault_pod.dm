/obj/docking_port/mobile/assault_pod
	name = "assault pod"
	id = "steel_rain"
	dwidth = 3
	width = 7
	height = 7

/obj/docking_port/mobile/assault_pod/request()
	if(z == initial(src.z)) //No launching pods that have already launched
		return ..()


/obj/docking_port/mobile/assault_pod/dock(obj/docking_port/stationary/S1)
	..()
	if(!istype(S1, /obj/docking_port/stationary/transit))
		playsound(get_turf(src.loc), 'sound/effects/explosion1.ogg',50,1)



/obj/item/device/assault_pod
	name = "Assault Pod Targetting Device"
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Used to select a landing zone for assault pods."
	var/shuttle_id = "steel_rain"
	var/dwidth = 3
	var/dheight = 0
	var/width = 7
	var/height = 7
	var/lz_dir = 1


/obj/item/device/assault_pod/attack_self(mob/living/user)
	var/target_area
	target_area = input("Area to land", "Select a Landing Zone", target_area) in GLOB.teleportlocs
	var/area/picked_area = GLOB.teleportlocs[target_area]
	if(!src || QDELETED(src))
		return

	var/turf/T = safepick(get_area_turfs(picked_area))
	if(!T)
		return
	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "assault_pod(\ref[src])"
	landing_zone.name = "Landing Zone"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.setDir(lz_dir)

	for(var/obj/machinery/computer/shuttle/S in GLOB.machines)
		if(S.shuttleId == shuttle_id)
			S.possible_destinations = "[landing_zone.id]"

	to_chat(user, "Landing zone set.")

	qdel(src)
