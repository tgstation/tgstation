/obj/machinery/airalarm
	icon = 'modular_bandastation/aesthetics/airalarm/icons/airalarm.dmi'
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	switch(dir) // TODO: do it in dmi
		if(NORTH)
			dir = SOUTH
		if(SOUTH)
			dir = NORTH
		if(EAST)
			dir = WEST
		if(WEST)
			dir = EAST

/obj/item/wallframe/airalarm
	icon = 'modular_bandastation/aesthetics/airalarm/icons/airalarm.dmi'
