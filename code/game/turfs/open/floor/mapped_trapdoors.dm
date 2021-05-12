
/**
 * # mapped trapdoors!
 *
 * this file is for subtypes of floors to pre-map in.
 * if YOU want to learn more about trapdoors, read about the component at trapdoor.dm
 */

/turf/open/floor/iron/trapdoor

/turf/open/floor/iron/trapdoor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/trapdoor, starts_open = TRUE)
