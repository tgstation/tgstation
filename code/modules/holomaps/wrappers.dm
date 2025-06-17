/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	if(istype(get_area(src), /area))
		LAZYADD(GLOB.station_fire_alarms["[z]"], src)

/obj/machinery/firealarm/Destroy()
	LAZYREMOVE(GLOB.station_fire_alarms["[z]"], src)
	. = ..()
