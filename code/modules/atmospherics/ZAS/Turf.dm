/turf
	var/zone/zone
	var/open_directions

/turf
	var/needs_air_update = 0
	var/datum/gas_mixture/air
	var/list/initial_gas
	var/heat_capacity = 1
	var/thermal_conductivity = 0.05
	var/list/initial_gas_mix
	var/planetary_atmos //Let's just let this exist for now.

///turf/simulated/proc/update_graphic(list/graphic_add = null, list/graphic_remove = null) ZASTURF
/turf/open/proc/update_graphic(list/graphic_add = null, list/graphic_null = null)
	if(graphic_add && graphic_add.len)
		vis_contents += graphic_add
	if(graphic_remove && graphic_remove.len)
		vis_contents -= graphic_remove

/turf/proc/update_air_properties()
	var/block
	ATMOS_CANPASS_TURF(block, src, src)
	if(block & AIR_BLOCKED)
		//dbg(blocked)
		return 1

	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim)
			continue

		block = unsim.c_airblock(src)

		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block = c_airblock(unsim)

		if(r_block & AIR_BLOCKED)
			continue

		//if(istype(unsim, /turf/simulated)) ZASTURF
		if(unsim.simulated)
			//var/turf/simulated/sim = unsim
			if(TURF_HAS_VALID_ZONE(sim))
				SSzas.connect(sim, src)

// Helper for can_safely_remove_from_zone().
//ZASTURF - MACRO IM NOT COMMENTING THIS SHIT OUT
#define GET_ZONE_NEIGHBOURS(T, ret) \
	ret = 0; \
	if (T.zone) { \
		for (var/_gzn_dir in gzn_check) { \
			var/turf/other = get_step(T, _gzn_dir); \
			if (!istype(other, /turf/open/space) && other.zone == T.zone) { \
				var/block; \
				ATMOS_CANPASS_TURF(block, other, T); \
				if (!(block & AIR_BLOCKED)) { \
					ret |= _gzn_dir; \
				} \
			} \
		} \
	}

/*
	Simple heuristic for determining if removing the turf from it's zone will not partition the zone (A very bad thing).
	Instead of analyzing the entire zone, we only check the nearest 3x3 turfs surrounding the src turf.
	This implementation may produce false negatives but it (hopefully) will not produce any false postiives.
*/

///turf/simulated/proc/can_safely_remove_from_zone() ZASTURF
/turf/proc/can_safely_remove_from_zone()
	if(!zone)
		return 1

	var/check_dirs
	GET_ZONE_NEIGHBOURS(src, check_dirs)
	. = check_dirs
	for(var/dir in csrfz_check)
		//for each pair of "adjacent" cardinals (e.g. NORTH and WEST, but not NORTH and SOUTH)
		if((dir & check_dirs) == dir)
			//check that they are connected by the corner turf
			//var/turf/simulated/T = get_step(src, dir) ZASTURF
			var/turf/T = get_step(src, dir)
			//if (!istype(T)) ZASTURF
			if (istype(T, /turf/open/space))
				. &= ~dir
				continue

			var/connected_dirs
			GET_ZONE_NEIGHBOURS(T, connected_dirs)
			if(connected_dirs && (dir & GLOB.reverse_dir[connected_dirs]) == dir)
				. &= ~dir //they are, so unflag the cardinals in question

	//it is safe to remove src from the zone if all cardinals are connected by corner turfs
	. = !.

//turf/simulated/update_air_properties() ZAS
/turf/open/update_air_properties()

	if(zone && zone.invalid) //this turf's zone is in the process of being rebuilt
		c_copy_air() //not very efficient :(
		zone = null //Easier than iterating through the list at the zone.

	var/s_block
	ATMOS_CANPASS_TURF(s_block, src, src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose) log_debug("Self-blocked.")
		//dbg(blocked)
		#endif
		if(zone)
			var/zone/z = zone

			if(can_safely_remove_from_zone()) //Helps normal airlocks avoid rebuilding zones all the time
				c_copy_air() //we aren't rebuilding, but hold onto the old air so it can be readded
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed
	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim) //edge of map
			continue

		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) log_debug("[d] is blocked.")
			//dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			//if((previously_open & d) && istype(unsim, /turf/simulated)) ZAS
			if((previously_open & d) && !istype(unsim, /turf/open/space))
				var/turf/sim = unsim
				if(zone && sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		//if(istype(unsim, /turf/simulated)) ZASTURF
		if(!istype(unsim, /turf/open/space))

			var/turf/sim = unsim
			sim.open_directions |= GLOB.reverse_dir[d]

			if(TURF_HAS_VALID_ZONE(sim))

				//Might have assigned a zone, since this happens for each direction.
				if(!zone)

					//We do not merge if
					//    they are blocking us and we are not blocking them, or if
					//    we are blocking them and not blocking ourselves - this prevents tiny zones from forming on doorways.
					if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || ((r_block & ZONE_BLOCKED) && !(s_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
						if(verbose) log_debug("[d] is zone blocked.")

						//dbg(zone_blocked, d)
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed) postponed = list()
						postponed.Add(sim)

					else

						sim.zone.add(src)

						#ifdef ZASDBG
						dbg(assigned)
						if(verbose) log_debug("Added to [zone]")
						#endif

				else if(sim.zone != zone)

					#ifdef ZASDBG
					if(verbose) log_debug("Connecting to [sim.zone]")
					#endif

					SSzas.connect(src, sim)


			#ifdef ZASDBG
				else if(verbose) log_debug("[d] has same zone.")

			else if(verbose) log_debug("[d] has invalid zone.")
			#endif

		else

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(!TURF_HAS_VALID_ZONE(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		SSzas.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections) connections.update_all()

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return 0

/turf/proc/assume_gas(gasid, moles, temp = 0)
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	if(initial_gas)
		GM.gas = initial_gas.Copy()
	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = return_air()
	return GM.remove(amount)

///turf/simulated/assume_air(datum/gas_mixture/giver) ZASTURF
/turf/proc/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

//turf/simulated/assume_gas(gasid, moles, temp = null) ZASTURF
/turf/proc/assume_gas(gasid, moles, temp = null)
	var/datum/gas_mixture/my_air = return_air()

	if(isnull(temp))
		my_air.adjust_gas(gasid, moles)
	else
		my_air.adjust_gas_temp(gasid, moles, temp)

	return 1

//turf/simulated/return_air() ZASTURF
/turf/proc/return_air()
	if(zone)
		if(!zone.invalid)
			SSzas.mark_zone_update(zone)
			return zone.air
		else
			if(!air)
				make_air()
			c_copy_air()
			return air
	else
		if(!air)
			make_air()
		return air

/turf/proc/make_air()
	air = new/datum/gas_mixture
	air.temperature = temperature
	if(initial_gas)
		air.gas = initial_gas.Copy()
	air.update_values()

//turf/simulated/proc/c_copy_air() ZASTURF
/turf/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1

/*/turf/open/space/c_copy_air()
	return
*/

//turf/simulated/proc/atmos_spawn_air(gas_id, amount, initial_temperature) ZASTURF
/turf/proc/atmos_spawn_air(gas_id, amount, initial_temperature)
	var/datum/gas_mixture/new_gas = new
	var/datum/gas_mixture/existing_gas = return_air()
	if(isnull(initial_temperature))
		new_gas.adjust_gas(gas_id, amount)
	else
		new_gas.adjust_gas_temp(gas_id, amount, initial_temperature)
	existing_gas.merge(new_gas)

/turf/open/space/atmos_spawn_air()
	return

/proc/turf_contains_dense_objects(var/turf/T)
	return T.contains_dense_objects()

/turf/proc/contains_dense_objects()
	if(density)
		return 1
	for(var/atom/movable/A as anything in src)
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			return 1
	return 0

/turf/proc/TryGetNonDenseNeighbour()
  for(var/d in GLOB.cardinals)
    var/turf/T = get_step(src, d)
    if (T && !turf_contains_dense_objects(T))
      return T
