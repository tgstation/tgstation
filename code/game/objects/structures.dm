/obj/structure
	icon = 'icons/obj/structures.dmi'
	layer = STRUCTURE_LAYER

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/New(nloc)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0
