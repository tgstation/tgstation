//These landmarks can be placed in rooms/ruins to set the baseturfs of every turf in the area. Easier than having potentially unlimited subtypes of every turf or having to manually edit the turfs in the map editor

/obj/effect/baseturf_helper
	name = "lava baseturf editor"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	var/baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface

/obj/effect/baseturf_helper/Initialize()
	. = ..()
	var/area/thearea = get_area(src)
	for(var/turf/T in get_area_turfs(thearea, z))
		if(T.baseturf != T.type) //Don't break indestructible walls and the like
			T.baseturf = baseturf
	qdel(src)