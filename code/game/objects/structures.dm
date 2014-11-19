/obj/structure
	icon = 'icons/obj/structures.dmi'

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	..()