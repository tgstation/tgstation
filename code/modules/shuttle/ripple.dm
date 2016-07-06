/obj/effect/overlay/temp/ripple
	name = "hyperspace ripple"
	desc = "Something is coming through hyperspace, you can see the \
		visual disturbances. It's probably best not to be on top of these \
		when whatever is tunneling comes through."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = 1
	alpha = 0

	duration = 3 * SHUTTLE_RIPPLE_TIME

/obj/effect/overlay/temp/ripple/New()
	. = ..()
	animate(src, alpha=255, time=SHUTTLE_RIPPLE_TIME)
