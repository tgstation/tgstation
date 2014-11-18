/obj/structure
	icon = 'icons/obj/structures.dmi'

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/ex_act(severity, specialty = 0)
	if(prob(100 / (2 ** severity - 1) + 25 * specialty))
		qdel(src)
	else
		..(severity, specialty)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	..()