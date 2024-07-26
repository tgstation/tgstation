/**
 * The geyser holding the liquid plasma concentrate that also acts as the final destinations for pipes.
 * This has no real functionality and exists solely to have an in-world item destination to path to.
 */
/obj/structure/liquid_plasma_geyser
	name = "concentrated liquid plasma geyser"
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

/obj/structure/liquid_plasma_geyser/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Toxic Signal")
