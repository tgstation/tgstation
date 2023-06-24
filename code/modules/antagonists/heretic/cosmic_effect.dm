/obj/effect/cosmic_diamond
	name = "Cosmic Diamond"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_diamond"
	anchored = TRUE

/obj/effect/temp_visual/cosmic_cloud
	name = "Cosmic Cloud"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_cloud"
	anchored = TRUE
	duration = 8

/obj/effect/temp_visual/cosmic_explosion
	name = "Cosmic Explosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "cosmic_explosion"
	anchored = TRUE
	duration = 5
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/space_explosion
	name = "Space Explosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "space_explosion"
	anchored = TRUE
	duration = 5
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/cosmic_domain
	name = "Cosmic Domain"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "cosmic_domain"
	anchored = TRUE
	duration = 6
	pixel_x = -64
	pixel_y = -64

/obj/effect/temp_visual/cosmic_gem
	name = "cosmic gem"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_gem"
	duration = 12

/obj/effect/temp_visual/cosmic_gem/Initialize(mapload)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
