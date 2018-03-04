GLOBAL_LIST_INIT(all_pathfinders, list())
GLOBAL_LIST_INIT(pathfinder_paths, list())
GLOBAL_VAR_INIT(pathfinding_regenerating, FALSE)


proc/generate_pathfinding_list()
	if(GLOB.pathfinding_regenerating)
		return
	goap_debug("Node Graph out of date. Rebuilding...")
	GLOB.pathfinder_paths = list()
	GLOB.pathfinding_regenerating = TRUE
	for(var/P in GLOB.all_pathfinders)
		var/obj/machinery/pathfinder_tile/home_tile = P
		for(var/PT in GLOB.all_pathfinders - home_tile)
			var/obj/machinery/pathfinder_tile/path_to_tile = PT
			var/list/path = get_path_to(home_tile, path_to_tile, /turf/proc/Distance_cardinal, 0, 200)
			GLOB.pathfinder_paths[home_tile][path_to_tile] = path
			CHECK_TICK
		CHECK_TICK
	GLOB.pathfinding_regenerating = FALSE

/obj/machinery/pathfinder_tile
	name = "pathfinder"
	icon = 'icons/obj/goap_pathfinder.dmi'
	icon_state = "pathfinder"
	level = 1
	layer = LOW_OBJ_LAYER
	anchored = 1
	obj_integrity = INFINITY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = FALSE

/obj/machinery/pathfinder_tile/New()
	..()
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/pathfinder_tile/ex_act()
	return FALSE