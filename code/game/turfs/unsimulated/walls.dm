/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	blocks_air = 1

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

/turf/unsimulated/wall/hardrock
	name = "Hard Rock"
	icon_state = "hard_rock"
	desc = "Literally nothing is able to break this apart"

/turf/unsimulated/wall/hardrock/New()

	spawn(1)
		var/turf/T
		if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)) || (istype(get_step(src, NORTH), /turf/simulated/shuttle/floor)) || (istype(get_step(src, NORTH), /turf/simulated/floor/plating/asteroid/airless)))
			T = get_step(src, NORTH)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "hard_rock_side_s")
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)) || (istype(get_step(src, SOUTH), /turf/simulated/floor/plating/asteroid/airless)))
			T = get_step(src, SOUTH)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "hard_rock_side_n")
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)) || (istype(get_step(src, EAST), /turf/simulated/floor/plating/asteroid/airless)))
			T = get_step(src, EAST)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "hard_rock_side_w")
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)) || (istype(get_step(src, WEST), /turf/simulated/floor/plating/asteroid/airless)))
			T = get_step(src, WEST)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "hard_rock_side_e")