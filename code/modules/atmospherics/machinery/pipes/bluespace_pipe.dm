GLOBAL_LIST_EMPTY(bluespace_pipes)

/obj/machinery/atmospherics/pipe/bluespace
	name = "bluespace pipe"
	desc = "Transmits gas across large distances of space. Developed using bluespace technology."
	icon = 'icons/obj/atmospherics/pipes/bluespace.dmi'
	icon_state = "map"
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	can_buckle = FALSE

/obj/machinery/atmospherics/pipe/bluespace/New()
	icon_state = "pipe"
	GLOB.bluespace_pipes += src
	..()

/obj/machinery/atmospherics/pipe/bluespace/Destroy()
	GLOB.bluespace_pipes -= src
	for(var/p in GLOB.bluespace_pipes)
		var/obj/machinery/atmospherics/pipe/bluespace/P = p
		QDEL_NULL(P.parent)
		P.build_network()
	return ..()

/obj/machinery/atmospherics/pipe/bluespace/SetInitDirections()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/bluespace/pipeline_expansion()
	return ..() + GLOB.bluespace_pipes - src

/obj/machinery/atmospherics/pipe/bluespace/hide()
	update_icon()

/obj/machinery/atmospherics/pipe/bluespace/update_icon(showpipe)
	underlays.Cut()
	var/turf/T = loc
	if(level != 2 && T.intact)
		return //no need to update the pipes if they aren't showing
	var/connected = 0 //Direction bitset
	for(DEVICE_TYPE_LOOP) //adds intact pieces
		if(NODE_I)
			connected |= icon_addintact(NODE_I)
	icon_addbroken(connected) //adds broken pieces

/obj/machinery/atmospherics/pipe/bluespace/paint()
	return FALSE
