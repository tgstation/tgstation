
//**************************************************************
//
// Map Objects
// ---------------
// Slap these on the map and they do their shit
//
//***************************************************************

/obj/map
	alpha = 255
	invisibility = 101
	mouse_opacity = 0

/obj/map/New()

	..()

	perform_spawn()
	qdel(src)

/obj/map/Destroy()
	return

//Spawn proc that can be modified, so New() can inherit properly
/obj/map/proc/perform_spawn()
	return
