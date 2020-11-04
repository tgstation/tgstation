/atom/movable/spawner/trap
	name = "random trap"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap_rand"

/atom/movable/spawner/trap/Initialize(mapload)
	..()
	var/new_type = pick(subtypesof(/obj/structure/trap) - typesof(/obj/structure/trap/ctf))
	new new_type(get_turf(src))
	return INITIALIZE_HINT_QDEL
