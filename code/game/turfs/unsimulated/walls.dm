/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/unsimulated/wall/normal
	icon_state = "wall"

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/Doorele.dmi'
	icon_state = "door_closed"

turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen.dmi'
	icon_state = "title"
	layer = FLY_LAYER

/turf/unsimulated/wall/other
	icon_state = "r_wall"
	name = "reinforced wall"

/turf/unsimulated/wall/vault
	icon_state = "rockvault"

/turf/unsimulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

/turf/unsimulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/unsimulated/shuttle/wall/interior/copyTurf(turf/T)
	if(T.type != type)
		T = new type(T)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T

/turf/unsimulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/unsimulated/wall/abductor
	icon_state = "alien1"