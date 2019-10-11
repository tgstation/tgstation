/obj/effect/shield
	/var/old_heat_capacity
	/var/turf/location
	name = "shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	layer = ABOVE_NORMAL_TURF_LAYER
	flags_1 = PREVENT_CLICK_UNDER_1

/obj/effect/shield/Initialize()
	. = ..()
	location = get_turf(src)	
	old_heat_capacity=location.heat_capacity
	location.heat_capacity = INFINITY

/obj/effect/shield/Destroy()
	location = get_turf(src)	
	location.heat_capacity=old_heat_capacity
	..()

/obj/effect/shield/singularity_act()
	return
	
