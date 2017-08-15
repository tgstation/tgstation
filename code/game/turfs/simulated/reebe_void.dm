/turf/open/indestructible/reebe_void
	name = "void"
	icon_state = "reebe"
	layer = SPACE_LAYER
	baseturf = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE

/turf/open/indestructible/reebe_void/Enter(atom/movable/AM, atom/old_loc)
	if(..())
		if(istype(AM, /obj/structure/window))
			return FALSE
		if(!((locate(/obj/effect/clockwork/reebe_exit) in src) && GLOB.ark_of_the_clockwork_justicar && GLOB.ark_of_the_clockwork_justicar.active))
			return FALSE
		if(!(locate(/obj/structure/lattice/clockwork) in src))
			return FALSE
		if(!(locate(/obj/structure/lattice/catwalk/clockwork) in src))
			return FALSE
		return TRUE
	return FALSE