/obj/effect/ripple
	name = "hyperspace ripple"
	desc = "Something is coming through hyperspace, you can see the \
		visual disturbances. It's probably best not to be on top of these \
		when whatever is tunneling comes through."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	alpha = 0

/obj/effect/ripple/New()
	. = ..()
	animate(src, alpha=255, time=SHUTTLE_RIPPLE_TIME)
	// In case something goes wrong, delete us in a bit
	addtimer(src, "delself", 3 * SHUTTLE_RIPPLE_TIME, FALSE)

/obj/effect/ripple/proc/delself()
	qdel(src)
