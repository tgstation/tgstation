/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave1"
	color = "#ffff00"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 150

/obj/effect/blessing/Initialize(mapload)
	var/turf/T = get_turf(src)
	if(GLOB.blessings[T])
		// already blessing in this location
		return INITIALIZE_HINT_QDEL
	else
		GLOB.blessings[T] = src
		. = ..()

/obj/effect/blessing/Destroy()
	var/turf/T = get_turf(src)
	GLOB.blessings[T] = null
	. = ..()
