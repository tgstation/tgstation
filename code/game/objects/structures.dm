/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	var/health = 0

/obj/structure/init_material()
	if(material)
		health *= material.health_multiplier
	..()
/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0
