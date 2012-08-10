zone
	New(turf/start)
		. = ..()
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

//LEGACY, DO NOT USE.
	Del()
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/turf/simulated/T in contents)
			RemoveTurf(T)
			air_master.tiles_to_reconsider_zones += T
		for(var/zone/Z in connected_zones)
			if(src in Z.connected_zones)
				Z.connected_zones.Remove(src)
		for(var/connection/C in connections)
			air_master.connections_to_check += C
		zones.Remove(src)
		air = null
		. = ..()

//Handles deletion via garbage collection.
	proc/SoftDelete()
		zones.Remove(src)
		air = null
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/turf/simulated/T in contents)
			RemoveTurf(T)
			air_master.tiles_to_reconsider_zones += T
		for(var/zone/Z in connected_zones)
			if(src in Z.connected_zones)
				Z.connected_zones.Remove(src)
		for(var/connection/C in connections)
			if(C.zone_A == src)
				C.zone_A = null
			if(C.zone_B == src)
				C.zone_B = null
			air_master.connections_to_check += C
		return 1


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
					if(istype(O) && O.ZCanPass(T) && !(O in open) && !(O in closed))
						open += O
			else
				doors += T
				open -= T
				continue

			open -= T
			closed += T

	for(var/turf/T in doors)
		var/force_connection = 1
		var/turf/O = get_step(T,NORTH)
		if(O in closed)
			closed += T
			continue
		else if(T.ZCanPass(O))
			force_connection = 0

		O = get_step(T,WEST)
		if(O in closed)
			closed += T
			continue
		else if(force_connection && T.ZCanPass(O))
			force_connection = 0

		if(force_connection)
			O = get_step(T,SOUTH)
			if(O in closed)
				closed += T
			else if(!T.ZCanPass(O) && get_step(T,EAST) in closed)
				closed += T


	return closed

turf/proc/ZCanPass(turf/T, var/include_space = 0)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.
	if(!istype(T))
		return 0

	if(istype(T,/turf/space) && !include_space)
		return 0
	else
		if(T.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(null, T, 1.5, 1))
				return 0

		for(var/obj/obstacle in T)
			if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
				continue
			if(!obstacle.CanPass(null, src, 1.5, 1))
				return 0

		return 1

turf/proc/ZAirPass(turf/T)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.
	if(!istype(T))
		return 0

	if(T.blocks_air||blocks_air)
		return 0

	for(var/obj/obstacle in src)
		if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
			continue
		if(!obstacle.CanPass(null, T, 0, 0))
			return 0

	for(var/obj/obstacle in T)
		if(istype(obstacle,/obj/machinery/door) && !istype(obstacle,/obj/machinery/door/window))
			continue
		if(!obstacle.CanPass(null, src, 0, 0))
			return 0

	return 1