/obj/machinery/door/proc/checkForMultipleDoors()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/door/proc/checkForMultipleDoors() called tick#: [world.time]")
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in src.loc)
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	return 1

/turf/simulated/wall/proc/checkForMultipleDoors()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/simulated/wall/proc/checkForMultipleDoors() called tick#: [world.time]")
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in locate(src.x,src.y,src.z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	//There are no false wall checks because that would be fucking retarded
	return 1