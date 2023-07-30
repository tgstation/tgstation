/obj/machinery/camera
	icon = 'modular_bandastation/aesthetics/cameras/icons/cameras.dmi'
	// TODO: camera_in_use

/obj/machinery/camera/Initialize(mapload, obj/structure/camera_assembly/old_assembly)
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
