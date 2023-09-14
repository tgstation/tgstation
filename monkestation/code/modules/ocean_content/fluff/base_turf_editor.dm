/obj/effect/base_turf_modifier
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"

	var/turf/baseturf_change



/obj/effect/base_turf_modifier/Initialize(mapload)
	. = ..()
	if(!baseturf_change)
		qdel(src)
		return
	var/turf/get_turf = get_turf(src)
	get_turf.baseturfs = baseturf_change
	qdel(src)


/obj/effect/base_turf_modifier/pit
	baseturf_change = /turf/open/floor/plating/ocean/pit
