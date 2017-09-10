//Foreshadows a servant warping in.
/obj/effect/clockwork/warp_marker
	name = "illuminant marker"
	desc = "A silhouette of dim light. It's getting brighter!"
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/effects/genetics.dmi'
	icon_state = "servitude"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	alpha = 0
	light_color = "#FFE48E"
	light_range = 2
	light_power = 0.7

/obj/effect/clockwork/warp_marker/Initialize(mapload, mob/living/servant)
	. = ..()
	animate(src, alpha = 255, time = 50)
	QDEL_IN(src, 55)

/obj/effect/clockwork/warp_marker/Destroy()
	animate(src, alpha = 0, time = 5)
	sleep(5)
	. = ..()
