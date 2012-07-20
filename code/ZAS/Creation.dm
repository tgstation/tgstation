zone
	New(turf/start)
		//Get the turfs that are part of the zone using a floodfill method
		if(istype(start,/list))
			contents = start
		else
			contents = FloodFill(start)

		//Change all the zone vars of the turfs, check for space to be added to space_tiles.
		for(var/turf/T in contents)
			if(T.zone && T.zone != src)
				T.zone.RemoveTurf(T)
			T.zone = src
			if(istype(T,/turf/space))
				AddSpace(T)

		//Generate the gas_mixture for use in this zone by using the average of the gases
		//defined at startup.
		air = new
		var/members = contents.len
		for(var/turf/simulated/T in contents)
			air.oxygen += T.oxygen / members
			air.nitrogen += T.nitrogen / members
			air.carbon_dioxide += T.carbon_dioxide / members
			air.toxins += T.toxins / members
			air.temperature += T.temperature / members
		air.group_multiplier = contents.len
		air.update_values()

		//Add this zone to the global list.
		zones.Add(src)

	Del()
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/turf/simulated/T in contents)
			if(T.zone && T.zone == src)
				T.zone = null
				air_master.tiles_to_update |= T
		for(var/zone/Z in connected_zones)
			if(src in Z.connected_zones)
				Z.connected_zones.Remove(src)
		for(var/connection/C in connections)
			del C
		zones.Remove(src)
		. = ..()

proc/FloodFill(turf/start)
	if(!istype(start))
		return list()
	var
		list
			open = list(start)
			closed = list()
			doors = list()

	while(open.len)
		for(var/turf/T in open)
			//Stop if there's a door, even if it's open. These are handled by indirect connection.
			if(!T.HasDoor())

				for(var/d in cardinal)
					var/turf/O = get_step(T,d)
					//Simple pass check.
					if(O.ZCanPass(T) && !(O in open) && !(O in closed))
						open += O
			else
				doors += T
				open -= T
				continue

			open -= T
			closed += T

	for(var/turf/T in doors)
		var/turf/O = get_step(T,NORTH)
		if(O in closed)
			closed += T
		O = get_step(T,WEST)
		if(O in closed)
			closed += T

	return closed

turf/proc/ZCanPass(turf/T, var/include_space = 0)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.

	if(istype(T,/turf/space) && !include_space) return 0
	else
		if(T.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(0, T, 1.5, 1))
				return 0

		for(var/obj/obstacle in T)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(0, src, 1.5, 1))
				return 0

		return 1