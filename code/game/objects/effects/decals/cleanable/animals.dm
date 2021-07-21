/obj/effect/decal/cleanable/insectguts
	name = "insect guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

/obj/effect/decal/cleanable/ants
	name = "space ants"
	desc = "A small colony of space ants. They're normally used to the vacuum of space, so they can't climb too well."
	icon = 'icons/obj/objects.dmi'
	icon_state = "spaceants"
	beauty = -150

/obj/effect/decal/cleanable/ants/Initialize(mapload)
	. = ..()
	var/scale = (rand(6, 8) / 10) + (rand(2, 5) / 50)
	transform = matrix(transform, scale, scale, MATRIX_SCALE)
	setDir(pick(GLOB.cardinals))
	reagents.add_reagent(/datum/reagent/ants, rand(2, 5))
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	AddElement(/datum/element/caltrop, min_damage = 0.2, max_damage = 1, flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN | CALTROP_BYPASS_SHOES), soundfile = 'sound/weapons/bite.ogg')
