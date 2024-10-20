// Small visual effect imparted onto rusted things by rust heretics.
/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = LOWER_RUNE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6, 6)
	pixel_x = rand(-6, 6)
	icon_state = "small_rune_[rand(1, 12)]"
	update_appearance()
