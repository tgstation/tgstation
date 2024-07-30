/obj/structure/wargame_hologram
	name = "broken holographic wargame marker"
	desc = "You have a feeling like this is supposed to be telling you something, but the hologram must have broken."
	icon = 'modular_doppler/wargaming/icons/projectors_and_holograms.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	max_integrity = 1
	obj_flags = UNIQUE_RENAME
	/// What object created this projection? Can be null as a projector isn't required for this to exist
	var/obj/item/wargame_projector/projector

/obj/structure/wargame_hologram/Initialize(mapload, source_projector)
	. = ..()
	if(source_projector)
		projector = source_projector
		LAZYADD(projector.projections, src)

/obj/structure/wargame_hologram/Destroy()
	if(projector)
		LAZYREMOVE(projector.projections, src)
		projector = null
	return ..()

/obj/structure/wargame_hologram/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)

/// Projections for 'moving vessels' in order from smallest to largest representation

/obj/structure/wargame_hologram/strike_craft
	name = "strike craft marker"
	desc = "A hologram of a single strike craft."
	icon_state = "strikesingle"

/obj/structure/wargame_hologram/strike_craft
	name = "skiff marker"
	desc = "A hologram of a single utility skiff."
	icon_state = "strike_utility"

/obj/structure/wargame_hologram/strike_craft/wing
	name = "strike craft wing marker"
	desc = "A hologram of a wing of strike craft."
	icon_state = "strikewing"

/obj/structure/wargame_hologram/ship_marker
	name = "small vessel marker"
	desc = "A hologram of a small frigate."
	icon_state = "smallship"

/obj/structure/wargame_hologram/ship_marker/medium
	name = "medium vessel marker"
	desc = "A hologram of a destroyer."
	icon_state = "mediumship"

/obj/structure/wargame_hologram/ship_marker/large
	name = "large vessel marker"
	desc = "A hologram of a large cruiser."
	icon_state = "bigship"

/obj/structure/wargame_hologram/ship_marker/large/alternate
	name = "alternate large vessel marker"
	desc = "A hologram of a massive ship."
	icon_state = "bigship_alternate"

/obj/structure/wargame_hologram/unidentified
	name = "unidentified contact marker"
	desc = "A hologram standing for an unidentified contact."
	icon_state = "unidentified"

/*
Projections for misc stuff, like stations, scout probes, or incoming missiles
*/

/obj/structure/wargame_hologram/missile_warning
	name = "in-flight missile marker"
	desc = "A hologram of a missile currently in flight."
	icon_state = "missile"

/obj/structure/wargame_hologram/probe
	name = "probe marker"
	desc = "A hologram of a scout probe."
	icon_state = "probe"

/obj/structure/wargame_hologram/stationary_structure
	name = "station marker"
	desc = "A hologram of a space station."
	icon_state = "station"

/obj/structure/wargame_hologram/stationary_structure/platform
	name = "platform marker"
	desc = "A hologram of a small space platform."
	icon_state = "platform"

/*
Projections for space 'terrain' like asteroids and dust clouds
*/

/obj/structure/wargame_hologram/dust
	name = "dust field marker"
	desc = "A hologram of a field of stellar dust of some sort."
	icon_state = "dustcloud"

/obj/structure/wargame_hologram/asteroid
	name = "small asteroid marker"
	desc = "A hologram of a small asteroid."
	icon_state = "asteroidsmall"

/obj/structure/wargame_hologram/asteroid/large
	name = "large asteroid marker"
	desc = "A hologram of a large asteroid."
	icon_state = "asteroidlarge"

/obj/structure/wargame_hologram/asteroid/cluster
	name = "asteroid cluster marker"
	desc = "A hologram of a cluster of asteroids."
	icon_state = "asteroidcluster"

/obj/structure/wargame_hologram/planet
	name = "planetary body marker"
	desc = "A hologram of a planet."
	icon_state = "planet"
