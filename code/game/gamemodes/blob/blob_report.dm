/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0
	var/num_territories = 1//Number of total valid territories for gang mode


/datum/station_state/proc/count(count_territories)
	for(var/turf/T in block(locate(1,1,1), locate(world.maxx,world.maxy,1)))

		if(isfloorturf(T))
			var/turf/open/floor/TF = T
			if(!(TF.burnt))
				src.floor += 12
			else
				src.floor += 1

		if(iswallturf(T))
			var/turf/closed/wall/TW = T
			if(TW.intact)
				src.wall += 2
			else
				src.wall += 1

		if(istype(T, /turf/closed/wall/r_wall))
			var/turf/closed/wall/r_wall/TRW = T
			if(TRW.intact)
				src.r_wall += 2
			else
				src.r_wall += 1


		for(var/obj/O in T.contents)
			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/GR = O
				if(!GR.broken)
					src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(ismachinery(O))
				src.mach += 1

	if(count_territories)
		var/list/valid_territories = list()
		for(var/area/A in world) //First, collect all area types on the station zlevel
			if(A.z in GLOB.station_z_levels)
				if(!(A.type in valid_territories) && A.valid_territory)
					valid_territories |= A.type
		if(valid_territories.len)
			num_territories = valid_territories.len //Add them all up to make the total number of area types
		else
			to_chat(world, "ERROR: NO VALID TERRITORIES")

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)
		return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall/ max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)
