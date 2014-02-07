/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null			// Used so cleanbots can't claim a mess.
	mouse_opacity=0 // So it's not completely impossible to fix the brig after some asshole bombs and then dirt grenades the place. - N3X
	w_type=NOT_RECYCLABLE

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	..()


/obj/effect/decal/cleanable/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/mop))
		return ..()
	return 0 // No more "X HITS THE BLOOD WITH AN RCD"