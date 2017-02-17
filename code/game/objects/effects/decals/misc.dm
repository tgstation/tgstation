/obj/effect/overlay/temp/point
	name = "pointer"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = POINT_LAYER
	duration = 25

/obj/effect/overlay/temp/point/New(atom/target, set_invis = 0)
	..()
	loc = get_turf(target)
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y
	invisibility = set_invis

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER

/obj/effect/decal/sandeffect
	name = "sandy tile"
	icon = 'icons/turf/floors.dmi'
	icon_state = "sandeffect"
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = 1