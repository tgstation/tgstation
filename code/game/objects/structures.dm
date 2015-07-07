/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	var/can_be_unanchored = 1

/obj/structure/New()
	..()
	if(smooth)
		smoother = new /datum/tile_smoother(src, canSmoothWith, can_be_unanchored)
		smoother.smooth()
		smoother.update_neighbors()
		icon_state = ""

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(opacity)
		UpdateAffectingLights()
	if(smoother)
		smoother.update_neighbors()
	..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0
