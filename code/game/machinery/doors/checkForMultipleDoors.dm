/obj/machinery/door/proc/checkForMultipleDoors()
	if(!loc)
		return 0
	for(var/obj/machinery/door/D in loc)
		if(!istype(D, /obj/machinery/door/window) && D.density && D != src)
			return 0
	return 1

/turf/closed/wall/proc/checkForMultipleDoors()
	if(!loc)
		return 0
	for(var/obj/machinery/door/D in locate(x,y,z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return 0
	//There are no false wall checks because that would be fucking retarded
	return 1