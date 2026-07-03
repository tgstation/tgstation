/obj/effect/abstract/landing_zone
	name = "Landing Zone Indicator"
	desc = "Голографическая проекция, обозначающая зону приземления чего-либо. Вероятно, лучше отойти в сторону."
	icon = 'modular_bandastation/shuttles/icons/landing_zone_96x96.dmi'
	icon_state = "target_largebox"
	layer = RIPPLE_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	pixel_x = -32
	pixel_y = -32
	alpha = 150

/obj/effect/abstract/landing_zone/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/abstract/landing_zone/update_overlays()
	. = ..()
	// Set the emissive appearance to make the glow effect
	. += emissive_appearance(icon, icon_state, src)
