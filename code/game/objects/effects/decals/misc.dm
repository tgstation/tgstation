<<<<<<< HEAD
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
=======
//This was put here because I don't want to overcomplicate my PR
/obj/effect/decal
	//var/global/list/decals = list()
	plane = PLANE_TURF

/obj/effect/decal/New()
	..()
	decals += src

/obj/effect/decal/Destroy()
	decals -= src
	..()

/obj/effect/decal/point
	name = "arrow"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	layer = 16
	mouse_opacity = 0
	w_type = NOT_RECYCLABLE

//Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	layer = 50

/obj/effect/decal/snow
	name = "snow"
	density = 0
	layer = 2
	icon = 'icons/turf/snow.dmi'
	w_type = NOT_RECYCLABLE


/obj/effect/decal/snow/clean/edge
	icon_state = "snow_corner"

/obj/effect/decal/snow/sand/edge
	icon_state = "gravsnow_corner"

/obj/effect/decal/snow/clean/surround
	icon_state = "snow_surround"

/obj/effect/decal/snow/sand/surround
	icon_state = "gravsnow_surround"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
