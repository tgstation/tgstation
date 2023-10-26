/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	var/suffix
	/**
	 * Port ID is the place this template should be docking at, set on '/obj/docking_port/stationary'
	 * Because getShuttle() compares port_id to shuttle_id to find an already existing shuttle,
	 * you should set shuttle_id to be the same as port_id if you want them to be replacable.
	 */
	var/port_id
	/// ID of the shuttle, make sure it matches port_id if necessary.
	var/shuttle_id
	/// Information to display on communication console about the shuttle
	var/description
	/// The recommended occupancy limit for the shuttle (count chairs, beds, and benches then round to 5)
	var/occupancy_limit
	/// Description of the prerequisition that has to be achieved for the shuttle to be purchased
	var/prerequisites
	/// Shuttle warnings and hazards to the admin who spawns the shuttle
	var/admin_notes
	/// How much does this shuttle cost the cargo budget to purchase? Put in terms of CARGO_CRATE_VALUE to properly scale the cost with the current balance of cargo's income.
	var/credit_cost = INFINITY
	/// What job accesses can buy this shuttle? If null, this shuttle cannot be bought.
	var/list/who_can_purchase = list(ACCESS_CAPTAIN)
	/// Whether or not this shuttle is locked to emags only.
	var/emag_only = FALSE
	/// If set, overrides default movement_force on shuttle
	var/list/movement_force

	var/port_x_offset
	var/port_y_offset
	var/extra_desc = ""

/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New()
	shuttle_id = "[port_id]_[suffix]"
	mappath = "[prefix][shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	var/offset = discover_offset(/obj/docking_port/mobile)

	port_x_offset = offset[1]
	port_y_offset = offset[2]

	if(!cache)
		cached_map = null

/datum/map_template/shuttle/load(turf/T, centered, register=TRUE)
	. = ..()
	if(!.)
		return
	var/list/turfs = block( locate(.[MAP_MINX], .[MAP_MINY], .[MAP_MINZ]),
							locate(.[MAP_MAXX], .[MAP_MAXY], .[MAP_MAXZ]))
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(isspaceturf(place)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue

		if (place.count_baseturfs() < 2) // Some snowflake shuttle shit
			continue

		place.insert_baseturf(3, /turf/baseturf_skipover/shuttle)

		for(var/obj/docking_port/mobile/port in place)
			port.calculate_docking_port_information(src)
			// initTemplateBounds explicitly ignores the shuttle's docking port, to ensure that it calculates the bounds of the shuttle correctly
			// so we need to manually initialize it here
			SSatoms.InitializeAtoms(list(port))
			if(register)
				port.register()

//Whatever special stuff you want
/datum/map_template/shuttle/post_load(obj/docking_port/mobile/M)
	if(movement_force)
		M.movement_force = movement_force.Copy()
	M.linkup()
