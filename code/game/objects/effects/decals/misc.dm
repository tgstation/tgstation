/obj/effect/temp_visual/point
	name = "pointer"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "arrow"
	plane = POINT_PLANE
	duration = 25

/obj/effect/temp_visual/point/Initialize(mapload, set_invis = 0)
	. = ..()
	var/atom/old_loc = loc
	abstract_move(get_turf(src))
	pixel_x = old_loc.pixel_x
	pixel_y = old_loc.pixel_y
	invisibility = set_invis

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE

/obj/effect/decal/chempuff/blob_act(obj/structure/blob/B)
	return

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	density = TRUE
