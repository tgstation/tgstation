/obj/effect/decal
	name = "decal"
	anchored = 1
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)
