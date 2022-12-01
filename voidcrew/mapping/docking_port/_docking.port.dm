/**
 * The main docking port that all voidcrew ships should be using.
 */
/obj/docking_port/mobile/voidcrew
	launch_status = UNLAUNCHED

	/// Makes sure we dont run linking logic more than once
	VAR_PRIVATE/cached_z_level
	var/z_levels_above = 0
	var/z_levels_below = 0

	///The linked overmap object, if there is one
	var/obj/structure/overmap/ship/current_ship

	///List of spawn points on the ship.
	var/list/obj/machinery/cryopod/spawn_points = list()

/obj/docking_port/mobile/voidcrew/Destroy(force)
	current_ship.shuttle = null
	current_ship = null
	spawn_points.Cut()
	unlink_from_z_level()
	return ..()

/obj/docking_port/mobile/voidcrew/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	link_to_z_level()
	return ..()

/obj/docking_port/mobile/voidcrew/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	unlink_from_z_level()
	for(var/area/area as anything in shuttle_areas)
		area.area_flags &= ~VALID_TERRITORY // don't want anyone dropped in mid shuttle move
	return ..()

/obj/docking_port/mobile/voidcrew/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	link_to_z_level()
	recalculate_shuttle_areas() // this also readds VALID_TERRITORY
	return ..()

/// Links to the Z level to ensure that if there are more than one ships on a z level when one leaves it doesnt clear the z trait
/obj/docking_port/mobile/voidcrew/proc/link_to_z_level()
	unlink_from_z_level()
	RegisterSignal(SSmapping, COMSIG_GLOB_Z_SHIP_PROBE, PROC_REF(respond_to_z_port_probe))
	var/bottom_z = z - z_levels_below
	var/top_z = z + z_levels_above
	for(var/z_level in bottom_z to top_z)
		LAZYORASSOCLIST(SSmapping.z_trait_levels, ZTRAIT_STATION, z_level)
		GLOB.station_levels_cache[z_level] = TRUE
	GLOB.the_station_areas |= shuttle_areas

/// Unlinks from the z level
/obj/docking_port/mobile/voidcrew/proc/unlink_from_z_level()
	var/bottom_z = z - z_levels_below
	var/top_z = z + z_levels_above
	for(var/z_level in bottom_z to top_z)
		if(SEND_SIGNAL(SSmapping, COMSIG_GLOB_Z_SHIP_PROBE, z_level))
			continue
		LAZYREMOVEASSOC(SSmapping.z_trait_levels, ZTRAIT_STATION, z_level)
		GLOB.station_levels_cache[z_level] = FALSE
	GLOB.the_station_areas -= shuttle_areas

/// Signal Handler for checking if anyone else is linked to a z level
/obj/docking_port/mobile/voidcrew/proc/respond_to_z_port_probe(datum/source, z_level)
	SIGNAL_HANDLER
	return (z_level == cached_z_level)

/**
 * ##get_all_humans
 *
 * Returns a list of all the living humans on the ship, as long as they have a mind and a client.
 */
/obj/docking_port/mobile/voidcrew/proc/get_all_humans()
	var/list/humans_to_add = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/turf/turf as anything in all_turfs)
		var/mob/living/carbon/human/human_to_add = locate() in turf.contents
		if(isnull(human_to_add))
			continue
		if(human_to_add.stat == DEAD)
			continue
		if(!human_to_add.client || !human_to_add.mind)
			continue
		humans_to_add.Add(human_to_add)
	return humans_to_add

/**
 * Scuttle the ship
 *
 * Delete all of the areas, and delete any cryopods
 */
/obj/docking_port/mobile/voidcrew/proc/mothball()
	if(length(get_all_humans()) > 0)
		return
	var/obj/docking_port/stationary/current_dock = get_docked()

	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA
	if(current_dock && current_dock.area_type)
		underlying_area_type = current_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)

	var/area/underlying_area = GLOB.areas_by_type[underlying_area_type]
	if(!underlying_area)
		underlying_area = new underlying_area_type(null)

	for(var/turf/oldT in old_turfs)
		if(!oldT || !istype(oldT.loc, area_type))
			continue
		var/obj/machinery/cryopod/pod = locate() in oldT.contents
		if(pod)
			qdel(pod) // we don't want anyone respawning now do we
		var/obj/machinery/computer/helm/helm = locate() in oldT.contents
		if(helm)
			qdel(helm) // we don't want anyone respawning now do we

		var/area/old_area = oldT.loc
		underlying_area.contents += oldT
		oldT.transfer_area_lighting(old_area, underlying_area)

	message_admins("\[SHUTTLE]: [current_ship?.name] has been turned into a ruin!")
	log_admin("\[SHUTTLE]: [current_ship?.name] has been turned into a ruin!")

	qdel(src, force = TRUE)

/obj/docking_port/mobile/voidcrew/proc/recalculate_shuttle_areas()
	for(var/area/area as anything in shuttle_areas)
		area.area_flags |= VALID_TERRITORY
	// TODO - UPSTREAM - RECALCULATE BOUNDS
