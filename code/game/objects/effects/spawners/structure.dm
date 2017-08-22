/*
Because mapping is already tedious enough this spawner let you spawn generic
"sets" of objects rather than having to make the same object stack again and
again.
*/

/obj/effect/spawner/structure
	name = "map structure spawner"
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize()
	..()
	if(spawn_list && spawn_list.len)
		for(var/I in spawn_list)
			new I(get_turf(src))
	qdel(src)


//normal windows

/obj/effect/spawner/structure/window
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "window_spawner"
	name = "window spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/fulltile)

/obj/effect/spawner/structure/window/hollow
	name = "hollow window spawner"
	icon_state = "hwindow_spawner_full"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/corner
	icon_state = "hwindow_spawner_corner_se"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east)

/obj/effect/spawner/structure/window/hollow/corner/northeast
	icon_state = "hwindow_spawner_corner_ne"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)

/obj/effect/spawner/structure/window/hollow/corner/northwest
	icon_state = "hwindow_spawner_corner_nw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/corner/southwest
	icon_state = "hwindow_spawner_corner_sw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/end
	icon_state = "hwindow_spawner_end_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/end/north
	icon_state = "hwindow_spawner_end_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/end/east
	icon_state = "hwindow_spawner_end_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)

/obj/effect/spawner/structure/window/hollow/end/west
	icon_state = "hwindow_spawner_end_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/middle
	icon_state = "hwindow_spawner_ns"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north)

/obj/effect/spawner/structure/window/hollow/middle/vertical
	icon_state = "hwindow_spawner_ew"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/one_side
	icon_state = "hwindow_spawner_single_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window)

/obj/effect/spawner/structure/window/hollow/one_side/north
	icon_state = "hwindow_spawner_single_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/north)

/obj/effect/spawner/structure/window/hollow/one_side/east
	icon_state = "hwindow_spawner_single_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/east)

/obj/effect/spawner/structure/window/hollow/one_side/west
	icon_state = "hwindow_spawner_single_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/spawner/west)


//reinforced

/obj/effect/spawner/structure/window/reinforced
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/reinforced
	name = "hollow reinforced window spawner"
	icon_state = "hrwindow_spawner_full"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/corner
	icon_state = "hrwindow_spawner_corner_se"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/reinforced/corner/northeast
	icon_state = "hrwindow_spawner_corner_ne"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/reinforced/corner/northwest
	icon_state = "hrwindow_spawner_corner_nw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/corner/southwest
	icon_state = "hrwindow_spawner_corner_sw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end
	icon_state = "hrwindow_spawner_end_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end/north
	icon_state = "hrwindow_spawner_end_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end/east
	icon_state = "hrwindow_spawner_end_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/reinforced/end/west
	icon_state = "hrwindow_spawner_end_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/middle
	icon_state = "hrwindow_spawner_ns"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north)

/obj/effect/spawner/structure/window/hollow/reinforced/middle/vertical
	icon_state = "hrwindow_spawner_ew"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/one_side
	icon_state = "hrwindow_spawner_single_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced)

/obj/effect/spawner/structure/window/hollow/reinforced/one_side/north
	icon_state = "hrwindow_spawner_single_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north)

/obj/effect/spawner/structure/window/hollow/reinforced/one_side/east
	icon_state = "hrwindow_spawner_single_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/reinforced/one_side/west
	icon_state = "hrwindow_spawner_single_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/west)


//tinted

/obj/effect/spawner/structure/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile)


//shuttle window

/obj/effect/spawner/structure/window/shuttle
	name = "reinforced tinted window spawner"
	icon_state = "swindow_spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/shuttle)


//plasma windows

/obj/effect/spawner/structure/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/fulltile)

/obj/effect/spawner/structure/window/hollow/plasma
	name = "hollow plasma window spawner"
	icon_state = "phwindow_spawner_full"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/corner
	icon_state = "phwindow_spawner_corner_se"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/corner/northeast
	icon_state = "phwindow_spawner_corner_ne"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/corner/northwest
	icon_state = "phwindow_spawner_corner_nw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/corner/southwest
	icon_state = "phwindow_spawner_corner_sw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/end
	icon_state = "phwindow_spawner_end_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/end/north
	icon_state = "phwindow_spawner_end_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/end/east
	icon_state = "phwindow_spawner_end_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/end/west
	icon_state = "phwindow_spawner_end_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/middle
	icon_state = "phwindow_spawner_ns"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north)

/obj/effect/spawner/structure/window/hollow/plasma/middle/vertical
	icon_state = "phwindow_spawner_ew"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/one_side
	icon_state = "phwindow_spawner_single_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma)

/obj/effect/spawner/structure/window/hollow/plasma/one_side/north
	icon_state = "phwindow_spawner_single_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north)

/obj/effect/spawner/structure/window/hollow/plasma/one_side/east
	icon_state = "phwindow_spawner_single_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/one_side/west
	icon_state = "phwindow_spawner_single_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/spawner/west)


//plasma reinforced

/obj/effect/spawner/structure/window/plasma/reinforced
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced
	name = "hollow reinforced plasma window spawner"
	icon_state = "phrwindow_spawner_full"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/corner
	icon_state = "phrwindow_spawner_corner_se"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/corner/northeast
	icon_state = "phrwindow_spawner_corner_ne"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/corner/northwest
	icon_state = "phrwindow_spawner_corner_nw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/corner/southwest
	icon_state = "phrwindow_spawner_corner_sw"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end
	icon_state = "phrwindow_spawner_end_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end/north
	icon_state = "phrwindow_spawner_end_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end/east
	icon_state = "phrwindow_spawner_end_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end/west
	icon_state = "phrwindow_spawner_end_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/middle
	icon_state = "phrwindow_spawner_ns"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/middle/vertical
	icon_state = "phrwindow_spawner_ew"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/one_side
	icon_state = "phrwindow_spawner_single_s"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/one_side/north
	icon_state = "phrwindow_spawner_single_n"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/one_side/east
	icon_state = "phrwindow_spawner_single_e"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/east)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/one_side/west
	icon_state = "phrwindow_spawner_single_w"
	spawn_list = 	list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/west)
