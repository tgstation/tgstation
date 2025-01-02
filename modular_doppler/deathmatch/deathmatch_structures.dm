/obj/structure/emergency_shield/timer
	icon_state = "shield-greyscale"
	color = "#ff0000b9"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/emergency_shield/timer/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 15 SECONDS)
