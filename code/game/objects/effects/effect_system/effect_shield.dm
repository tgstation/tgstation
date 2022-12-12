/obj/effect/shield
	name = "shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	layer = ABOVE_NORMAL_TURF_LAYER
	flags_1 = PREVENT_CLICK_UNDER_1
	anchored = TRUE
	var/old_max_temperature

/obj/effect/shield/Initialize(mapload)
	. = ..()
	var/turf/location = get_turf(src)
	old_max_temperature = location.max_temperature
	location.max_temperature = INFINITY

/obj/effect/shield/Destroy()
	var/turf/location = get_turf(src)
	location.max_temperature = old_max_temperature
	return ..()

/obj/effect/shield/singularity_act()
	return

/obj/effect/shield/singularity_pull(S, current_size)
	return

