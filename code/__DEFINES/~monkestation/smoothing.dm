#define SMOOTH_ADAPTERS_WALLS list( \
		/turf/closed/wall = "wall", \
		/obj/structure/falsewall = "wall", \
		/obj/machinery/door/airlock = "wall", \
)

// wall don't need adapter with another wall
#define SMOOTH_ADAPTERS_WALLS_FOR_WALLS list( \
		/obj/machinery/door/airlock = "wall", \
		/turf/closed/wall = "wall", \
)

#define SMOOTH_ADAPTERS_ICON 'monkestation/icons/obj/structures/window/adapters.dmi'

