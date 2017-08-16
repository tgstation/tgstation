/turf/open/indestructible/reebe_void
	name = "void"
	icon_state = "reebe"
	layer = SPACE_LAYER
	baseturf = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE

/turf/open/indestructible/reebe_void/Enter(atom/movable/AM, atom/old_loc)
	if(!..())
		return FALSE
	else
		if(istype(AM, /obj/structure/window))
			return FALSE
		if(istype(AM, /obj/item/projectile))
			return TRUE
		if(((locate(/obj/effect/clockwork/reebe_exit) in src) && GLOB.ark_of_the_clockwork_justicar && GLOB.ark_of_the_clockwork_justicar.active) || \
		(locate(/obj/structure/lattice/clockwork) in src) || \
		(locate(/obj/structure/lattice/catwalk/clockwork) in src))
			return TRUE
		return FALSE