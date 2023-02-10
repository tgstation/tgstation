/// An override of the parent so we can grab it from the current ship instead
/datum/traitor_objective/locate_weakpoint/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	scan_areas = list()
	var/mob/living/tot = generating_for.current
	if(!istype(tot))
		return FALSE

	var/obj/docking_port/mobile/voidcrew/ship_port = SSshuttle.getShuttle(tot)
	if(!istype(ship_port))
		return FALSE

	var/obj/structure/overmap/ship/ship = ship_port.current_ship
	if(!istype(ship))
		return FALSE

	var/list/area/ship_areas = ship.shuttle.shuttle_areas?.Copy()
	if(!ship_areas || (ship_areas.len < 3))
		return FALSE

	for(var/i in 1 to 2)
		scan_areas[pick_n_take(ship_areas)] = TRUE
	weakpoint_area = pick_n_take(ship_areas)

	var/area/scan_area1 = scan_areas[1]
	var/area/scan_area2 = scan_areas[2]
	replace_in_name("%AREA1%", initial(scan_area1.name))
	replace_in_name("%AREA2%", initial(scan_area2.name))
	RegisterSignal(SSdcs, COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED, PROC_REF(on_global_obj_completed))
	return TRUE
