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

/turf/unsimulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/unsimulated/wall/oldspace
	name = "solidified space"
	desc = "The laws of physics don't seem to apply to this. No one knows why."
	icon = 'icons/turf/space.dmi'
	icon_state = "oldspace"
	opacity = 0
	density = 1
	blocks_air = 1