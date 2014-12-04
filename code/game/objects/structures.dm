/obj/structure
	icon = 'icons/obj/structures.dmi'

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>")
		return 1
	return 0
