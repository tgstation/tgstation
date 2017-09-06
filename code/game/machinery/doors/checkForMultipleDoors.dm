/obj/machinery/door/proc/checkForMultipleDoors()
	if(!src.loc)
		return FALSE
	for(var/obj/machinery/door/D in src.loc)
		if(!istype(D, /obj/machinery/door/window) && D.density && D != src)
			return FALSE
	return TRUE

/turf/closed/wall/proc/checkForMultipleDoors()
	if(!src.loc)
		return FALSE
	for(var/obj/machinery/door/D in locate(src.x,src.y,src.z))
		if(!istype(D, /obj/machinery/door/window) && D.density)
			return FALSE
	//There are no false wall checks because that would be fucking retarded
	return TRUE