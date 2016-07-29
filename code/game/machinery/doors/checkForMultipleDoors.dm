/obj/machinery/door/proc/checkForMultipleDoors()
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in src.loc)
<<<<<<< HEAD
		if(!istype(D, /obj/machinery/door/window) && D.density && D != src)
			return 0
	return 1

/turf/closed/wall/proc/checkForMultipleDoors()
=======
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	return 1

/turf/simulated/wall/proc/checkForMultipleDoors()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!src.loc)
		return 0
	for(var/obj/machinery/door/D in locate(src.x,src.y,src.z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	//There are no false wall checks because that would be fucking retarded
	return 1