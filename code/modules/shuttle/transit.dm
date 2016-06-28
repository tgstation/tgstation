/obj/effect/landmark/transit
	name = "transit space marker"
	desc = "This indicates where transit space begins and ends."
	invisibility = FALSE
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"

/obj/effect/landmark/transit/New()
	. = ..()
	transit_markers += src

/obj/effect/landmark/transit/Destroy()
	transit_markers -= src
	. = ..()
