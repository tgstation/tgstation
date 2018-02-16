//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect



/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/baseturf = null
	layer = POINT_LAYER

/obj/effect/baseturf_helper/Initialize()
	. = ..()
	var/area/thearea = get_area(src)
	for(var/turf/T in get_area_turfs(thearea, z))
		replace_baseturf(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	if(thing.baseturfs != thing.type)
		thing.baseturfs = baseturf

/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/open/space

/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/open/floor/plating/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/open/floor/plating/beach/water

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/open/lava/smooth

/obj/effect/baseturf_helper/lava_land/surface
	name = "lavaland baseturf editor"
	baseturf = /turf/open/lava/smooth/lava_land_surface

// Does the same thing as baseturf_helper but only the specified kinds of turf (the kind it's placed on or varedited)
/obj/effect/baseturf_helper/picky
	var/list/whitelist
	// Can be mapedited as: a single type, a list of types, or a typecache-like list
	// The first 2 make a typecache of the given values
	// The last uses it as is

/obj/effect/baseturf_helper/picky/Initialize()
	if(!whitelist)
		whitelist = list(loc.type)
	else if(!islist(whitelist))
		whitelist = list(whitelist)
	else if(whitelist[whitelist[1]]) // Checking if it's a typecache-like list
		return ..()
	whitelist = typecacheof(whitelist)
	return ..()

/obj/effect/baseturf_helper/picky/replace_baseturf(turf/thing)
	if(!whitelist[thing.type])
		return
	return ..()

/obj/effect/baseturf_helper/picky/lava_land/plating
	name = "picky lavaland plating baseturf helper"
	baseturf = /turf/open/floor/plating/lavaland_baseturf

/obj/effect/baseturf_helper/picky/lava_land/basalt
	name = "picky lavaland basalt baseturf helper"
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface


/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

/obj/effect/mapping_helpers/Initialize()
	..()
	return INITIALIZE_HINT_QDEL

//needs to do its thing before spawn_rivers() is called
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	T.flags_1 |= NO_LAVA_GEN_1

//Contains the list of planetary z-levels defined by the planet_z helper.
GLOBAL_LIST_EMPTY(z_is_planet)

/obj/effect/mapping_helpers/planet_z //adds the map it is on to the z_is_planet list
	name = "planet z helper"
	layer = POINT_LAYER

/obj/effect/mapping_helpers/planet_z/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	GLOB.z_is_planet["[T.z]"] = TRUE

