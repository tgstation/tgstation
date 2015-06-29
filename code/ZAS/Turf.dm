/turf/var/zone/zone
/turf/var/open_directions
/turf/var/list/gasGraphics

/turf/var/needs_air_update = 0
/turf/var/datum/gas_mixture/air

/turf/proc/set_graphic(const/newGraphics)
	if (!isnum(newGraphics))
		return

	if (!newGraphics) // Clear overlay, or simply 0.
		if (gasGraphics)
			overlays -= gasGraphics
			gasGraphics = null

		return

	var/list/overlayGraphics = list()

	if (GRAPHICS_PLASMA & newGraphics)
		overlayGraphics += SSair.plasma_overlay

	if (GRAPHICS_N2O & newGraphics)
		overlayGraphics += SSair.sleeptoxin_overlay

//	if (GRAPHICS_COLD & newGraphics)
//		overlayGraphics += SSair.ice_overlay

	if (overlayGraphics.len)
		if (gasGraphics)
			overlays -= gasGraphics
			gasGraphics = null

		overlays += overlayGraphics
		gasGraphics = overlayGraphics.Copy()

/turf/proc/update_air_properties()
	var/block = c_airblock(src)
	if(block & AIR_BLOCKED)
//		dbg(blocked)
		return 1

	#ifdef ZLEVELS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim) // Edge of map.
			continue

		block = unsim.c_airblock(src)

		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block = c_airblock(unsim)

		if(r_block & AIR_BLOCKED)
			continue

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(SSair.has_valid_zone(sim))

				SSair.connect(sim, src)

/turf/simulated/update_air_properties()
	if(zone && zone.invalid)
		c_copy_air()
		zone = null //Easier than iterating through the list at the zone.

	var/s_block = c_airblock(src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
//		if(verbose) world << "Self-blocked."
		dbg(blocked)
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

		if(!unsim) // Edge of map.
			continue

		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
//			if(verbose) world << "[d] is blocked."
			unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
//			if(verbose) world << "[d] is blocked."
			dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && istype(unsim, /turf/simulated))
				var/turf/simulated/sim = unsim
				if(istype(zone) && sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(SSair.has_valid_zone(sim))

				//Might have assigned a zone, since this happens for each direction.
				if(!zone)

					//if((block & ZONE_BLOCKED) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
					if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
//						if(verbose) world << "[d] is zone blocked."
						dbg(zone_blocked, d)
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed) postponed = list()
						postponed.Add(sim)

					else

						sim.zone.add(src)

						#ifdef ZASDBG
						dbg(assigned)
//						if(verbose) world << "Added to [zone]"
						#endif

				else if(sim.zone != zone)

					#ifdef ZASDBG
//					if(verbose) world << "Connecting to [sim.zone]"
					#endif

					SSair.connect(src, sim)


			#ifdef ZASDBG
//				else if(verbose) world << "[d] has same zone."

//			else if(verbose) world << "[d] has invalid zone."
			#endif

		else

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(!SSair.has_valid_zone(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		SSair.connect(src, T)

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
	SSair.mark_for_update(src)

/turf/simulated/remove_air(amount as num)
	var/datum/gas_mixture/my_air = return_air()
	SSair.mark_for_update(src)
	return my_air.remove(amount)

/turf/simulated/return_air()
	if(zone)
		if(!zone.invalid)
			SSair.mark_zone_update(zone)
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

/turf/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1

turf/simulated/proc/copy_air_with_tile(turf/simulated/T)
	if(!air)
		make_air()
	if(istype(T))
		air.copy_from(T.return_air())
		air.group_multiplier = 1


/turf/attack_hand(mob/user as mob)
	user.Move_Pulled(src)