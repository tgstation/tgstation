// Small visual effect imparted onto rusted things by rust heretics.
/obj/effect/temp_visual/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	duration = 1 MINUTES
	layer = LOW_SIGIL_LAYER
	plane = GAME_PLANE

/obj/effect/temp_visual/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6, 6)
	pixel_x = rand(-6, 6)
	icon_state = "small_rune_[rand(12)]"
	update_appearance()
