/**
 * the tram has a few objects mapped onto it at roundstart, by default many of those objects have unwanted properties
 * for example grilles and windows have the atmos_sensitive element applied to them, which makes them register to
 * themselves moving to re register signals onto the turf via connect_loc. this is bad and dumb since it makes the tram
 * more expensive to move.
 *
 * if you map something on to the tram, make SURE if possible that it doesnt have anythign reacting to its own movement
 * it will make the tram more expensive to move and we dont want that because we dont want to return to the days where
 * the tram took a third of the tick per movement when its just carrying its default mapped in objects
 */
/obj/structure/grille/tram/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	//atmos_sensitive applies connect_loc which 1. reacts to movement in order to 2. unregister and register signals to
	//the old and new locs. we dont want that, pretend these grilles and windows are plastic or something idk

/obj/structure/window/reinforced/shuttle/tram/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/shuttle/engine/propulsion/in_wall/tram
	//if this has opacity, then every movement of the tram causes lighting updates
	//DO NOT put something on the tram roundstart that has opacity, it WILL overload SSlighting
	opacity = FALSE

/obj/machinery/door/window/left/tram
/obj/machinery/door/window/right/tram

/obj/machinery/door/window/left/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/door/window/right/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/left/tram, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/right/tram, 0)

