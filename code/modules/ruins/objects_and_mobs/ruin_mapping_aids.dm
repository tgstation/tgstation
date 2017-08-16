//These landmarks can be placed in rooms/ruins to set the baseturfs of every turf in the area. Easier than having potentially unlimited subtypes of every turf or having to manually edit the turfs in the map editor

/obj/effect/baseturf_helper
	name = "baseturf editor"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	var/baseturf = null
	layer = POINT_LAYER

/obj/effect/baseturf_helper/Initialize()
	. = ..()
	var/area/thearea = get_area(src)
	for(var/turf/T in get_area_turfs(thearea, z))
		if(T.baseturf != T.type) //Don't break indestructible walls and the like
			T.baseturf = baseturf
	qdel(src)


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
