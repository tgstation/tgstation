/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave1"
	color = "#ffff00"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_OPEN_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 150

/obj/effect/blessing/Initialize(mapload)
	. = ..()
	for(var/obj/effect/blessing/B in loc)
		if(B != src)
			return INITIALIZE_HINT_QDEL
