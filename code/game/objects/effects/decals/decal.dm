/obj/effect/decal
	name = "decal"
	anchored = 1
	resistance_flags = FIRE_PROOF | UNACIDABLE

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act()
	if(!(resistance_flags & FIRE_PROOF)) //flammable decal or being burned by lava
		qdel(src)
