/**
 * For counting up how much of the station exists at the start of the shift, and how much is left behind by the end of it.
 *
 * "For God's sake, please be careful with those fuel tanks, you're going to set them off and compromise the station's integrity."
 * "Relax boss, everyone knows this station has no integrity."
 * "Yeah, that's why we all like it so much!"
 * * -Recovered engineering chatter from a destroyed NT station, 2557
 */

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0

/datum/station_state/proc/count()
	floor = 0
	wall = 0
	r_wall = 0
	window = 0
	door = 0
	grille = 0
	mach = 0
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/T as anything in Z_TURFS(Z))
			// don't count shuttles since they may have just left
			if(istype(T.loc, /area/shuttle))
				continue

			if(isfloorturf(T))
				var/turf/open/floor/TF = T
				if(TF.burnt)
					floor += 1
				else
					floor += 2

			if(iswallturf(T))
				wall += 1

			if(istype(T, /turf/closed/wall/r_wall))
				var/turf/closed/wall/r_wall/TRW = T
				if(TRW.d_state == INTACT)
					r_wall += 2
				else
					r_wall += 1


			for(var/obj/O in T.contents)
				if(istype(O, /obj/structure/window))
					window += 1
				else if(istype(O, /obj/structure/grille))
					var/obj/structure/grille/GR = O
					if(!GR.broken)
						grille += 1
				else if(istype(O, /obj/machinery/door))
					door += 1
				else if(ismachinery(O))
					mach += 1
				CHECK_TICK
			CHECK_TICK
		CHECK_TICK

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
