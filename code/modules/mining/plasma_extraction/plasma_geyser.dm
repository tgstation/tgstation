/**
 * The geyser holding the liquid plasma concentrate that also acts as the final destinations for pipes.
 * This has no real functionality and exists solely to have an in-world item destination to path to.
 */
/obj/structure/liquid_plasma_geyser
	name = "concentrated liquid plasma geyser"
	desc = "A small yet very deep geyser of concentrated liquid plasma. Very toxic fumes spitting out, \
		you should make sure you've got the proper gear to handle this."
	icon = 'icons/obj/mining_zones/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

/obj/structure/liquid_plasma_geyser/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Toxic Signal")
	particles = new /particles/smoke/plasma()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/liquid_plasma_geyser/Destroy(force)
	QDEL_NULL(particles)
	return ..()

/obj/structure/liquid_plasma_geyser/update_overlays()
	. = ..()
	var/mutable_appearance/plasma_overlay = mutable_appearance('icons/obj/mining_zones/terrain.dmi', "[icon_state]_soup")
	plasma_overlay.color = COLOR_PLASMIUM_PURPLE
	. += plasma_overlay
