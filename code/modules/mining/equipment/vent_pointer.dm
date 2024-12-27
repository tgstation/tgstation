/obj/item/pinpointer/vent
	name = "ventpointer"
	desc = "A handheld tracking device. It will locate and point to nearby vents. A bit unreliable though."
	icon_state = "pinpointer_vent"
	minimum_range = 14 //gotta use them eyes

/obj/item/pinpointer/vent/scan_for_target()
	var/closest_dist = INFINITY

	for(var/obj/structure/ore_vent/vent in SSore_generation.possible_vents)
		if(vent.discovered || vent.tapped)
			continue
		if(vent.z != loc.z)
			continue

		var/target_dist = get_dist(src, vent)
		if(target_dist < closest_dist)
			closest_dist = target_dist
			target = vent
