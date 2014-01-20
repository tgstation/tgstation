
/obj/item/device/ano_scanner
	name = "Alden-Saraspova counter"
	desc = "Aids in triangulation of exotic particles."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "flashgun"
	item_state = "lampgreen"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25

/obj/item/device/ano_scanner/New()
	..()
	spawn(0)
		scan()

/obj/item/device/ano_scanner/attack_self(var/mob/user as mob)
	return src.interact(user)

/obj/item/device/ano_scanner/interact(var/mob/user as mob)
	var/message = "Background radiation levels detected."
	if(nearest_artifact_distance >= 0)
		message = "Exotic energy detected on wavelength '[nearest_artifact_id]' in a radius of [nearest_artifact_distance]m"
	user << "<span class='info'>[message]</span>"
	if(world.time - last_scan_time >= scan_delay)
		spawn(0)
			scan()

/obj/item/device/ano_scanner/proc/scan()
	set background = 1

	last_scan_time = world.time
	nearest_artifact_distance = -1
	var/turf/cur_turf = get_turf(src)
	if(master_controller) //Sanity check due to runtimes ~Z
		for(var/turf/simulated/mineral/T in master_controller.artifact_spawning_turfs)
			if(T.artifact_find)
				if(T.z == cur_turf.z)
					var/cur_dist = get_dist(cur_turf, T) * 2
					if( (nearest_artifact_distance < 0 || cur_dist < nearest_artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range )
						nearest_artifact_distance = cur_dist + rand() * 2 - 1
						nearest_artifact_id = T.artifact_find.artifact_id
			else
				master_controller.artifact_spawning_turfs.Remove(T)
	cur_turf.visible_message("<span class='info'>[src] clicks.</span>")
