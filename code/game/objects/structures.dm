/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8

/obj/structure/New()
	..()
	if(smooth)
		smooth_icon(src)
		smooth_icon_neighbors(src)
		icon_state = ""

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	if(smooth)
		smooth_icon_neighbors(src)
	..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0
