/turf/simulated/var/zone/zone
/turf/simulated/var/open_directions
/turf/simulated/var/gas_graphic

/turf/var/needs_air_update = 0
/turf/var/datum/gas_mixture/air

/turf/simulated/proc/set_graphic(new_graphic)
	if(isnum(new_graphic))
		if(new_graphic == 1) new_graphic = plmaster
		else if(new_graphic == 2) new_graphic = slmaster
	if(gas_graphic) overlays -= gas_graphic
	if(new_graphic) overlays += new_graphic
	gas_graphic = new_graphic

/turf/proc/update_air_properties()
	var/block = c_airblock(src)
	if(block & AIR_BLOCKED)
		//dbg(blocked)
		return 1

	#ifdef ZLEVELS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)
		block = unsim.c_airblock(src)

		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block = c_airblock(unsim)

		if(r_block & AIR_BLOCKED)
			continue

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(air_master.has_valid_zone(sim))

				air_master.connect(sim, src)

/turf/simulated/update_air_properties()
	if(zone && zone.invalid)
		c_copy_air()
		zone = null //Easier than iterating through the list at the zone.

	var/s_block = c_airblock(src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose) world << "Self-blocked."
		//dbg(blocked)
		#endif
		if(zone)
			var/zone/z = zone
			if(locate(/obj/machinery/door/airlock) in src) //Hacky, but prevents normal airlocks from rebuilding zones all the time
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed
	#ifdef ZLEVELS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)
		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) world << "[d] is blocked."
			//unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose) world << "[d] is blocked."
			//dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && istype(unsim, /turf/simulated))
				var/turf/simulated/sim = unsim
				if(sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(air_master.has_valid_zone(sim))

				//Might have assigned a zone, since this happens for each direction.
				if(!zone)

					//if((block & ZONE_BLOCKED) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
					if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
						if(verbose) world << "[d] is zone blocked."
						//dbg(zone_blocked, d)
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed) postponed = list()
						postponed.Add(sim)

					else

						sim.zone.add(src)

						#ifdef ZASDBG
						dbg(assigned)
						if(verbose) world << "Added to [zone]"
						#endif

				else if(sim.zone != zone)

					#ifdef ZASDBG
					if(verbose) world << "Connecting to [sim.zone]"
					#endif

					air_master.connect(src, sim)


			#ifdef ZASDBG
				else if(verbose) world << "[d] has same zone."

			else if(verbose) world << "[d] has invalid zone."
			#endif

		else

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(!air_master.has_valid_zone(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		air_master.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections) connections.update_all()

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	GM.oxygen = oxygen
	GM.carbon_dioxide = carbon_dioxide
	GM.nitrogen = nitrogen
	GM.toxins = toxins

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = new

	var/sum = oxygen + carbon_dioxide + nitrogen + toxins
	if(sum>0)
		GM.oxygen = (oxygen/sum)*amount
		GM.carbon_dioxide = (carbon_dioxide/sum)*amount
		GM.nitrogen = (nitrogen/sum)*amount
		GM.toxins = (toxins/sum)*amount

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/simulated/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

/turf/simulated/remove_air(amount as num)
	var/datum/gas_mixture/my_air = return_air()
	return my_air.remove(amount)

/turf/simulated/return_air()
	if(zone)
		if(!zone.invalid)
			air_master.mark_zone_update(zone)
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
	air.adjust(oxygen, carbon_dioxide, nitrogen, toxins)
	air.group_multiplier = 1
	air.volume = CELL_VOLUME

/turf/simulated/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1