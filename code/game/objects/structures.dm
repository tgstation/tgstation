obj/structure
	icon = 'icons/obj/structures.dmi'
	penetration_dampening = 5

obj/structure/blob_act()
	if(prob(50))
		qdel(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/projectile_check()
	return PROJREACT_OBJS
