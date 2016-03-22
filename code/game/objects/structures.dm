/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8

/obj/structure/New()
	..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
		icon_state = ""
	if(ticker)
		cameranet.updateVisibility(src)

/obj/structure/blob_act()
	if(!density)
		qdel(src)
	if(prob(50))
		qdel(src)

/obj/structure/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	if(opacity)
		UpdateAffectingLights()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		return 1
	return 0

/obj/structure/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)
	interact(user)

/obj/structure/interact(mob/user)
	ui_interact(user)

/obj/structure/ui_act(action, params)
	..()
	add_fingerprint(usr)

/obj/structure/proc/deconstruct(forced = FALSE)
	qdel(src)
