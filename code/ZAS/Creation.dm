zone
	New(turf/start)
		//Get the turfs that are part of the zone using a floodfill method
		if(istype(start,/list))
			contents = start
		else
			contents = FloodFill(start)

		//Change all the zone vars of the turfs, check for space to be added to space_tiles.
		for(var/turf/T in contents)
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
		zones += src

	Del()
		//Ensuring the zone list doesn't get clogged with null values.
		for(var/connection/C in connections)
			del(C)
		zones -= src
		. = ..()

proc/FloodFill(turf/start)
	if(!istype(start))
		return list()
	var
		list
			open = list(start)
			closed = list()

	while(open.len)
		for(var/turf/T in open)
			//Stop if there's a door, even if it's open. These are handled by indirect connection.
			if(!T.HasDoor())

				for(var/d in cardinal)
					var/turf/O = get_step(T,d)
					//Simple pass check.
					if(O.ZCanPass(T) && !(O in open) && !(O in closed))
						open += O

			open -= T
			closed += T

	return closed

turf/proc/ZCanPass(turf/T)
	//Fairly standard pass checks for turfs, objects and directional windows. Also stops at the edge of space.

	if(istype(T,/turf/space)) return 0
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