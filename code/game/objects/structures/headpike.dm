/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	icon_state = "headpike"
	var/obj/item/twohanded/spear/spear = null
	var/obj/item/bodypart/head/victim = null
	var/obj/item/twohanded/bonespear/bonespear = null
	density = FALSE
	anchored = TRUE

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"


/obj/structure/headpike/CheckParts(list/parts_list)
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	var/obj/item/twohanded/spear/S = locate() in contents
	var/obj/item/twohanded/bonespear/BS = locate() in contents
	update_icon()
	victim = H
	name = "[H.real_name]'s head on a spear"
	if(S)
		spear = S
	if(BS)
		bonespear = BS

/obj/structure/headpike/Initialize()
	. = ..()
	pixel_x = rand(-8, 8)

/obj/structure/headpike/update_icon()
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	var/mutable_appearance/MA = new()
	if(H)
		MA.copy_overlays(H)
		MA.pixel_y = 12
		add_overlay(H)

/obj/structure/headpike/attack_hand(mob/user)
	..()
	to_chat(user, "<span class='notice'>You take down [src].</span>")
	victim.forceMove(get_turf(src))
	victim = null
	if(spear)
		spear.forceMove(get_turf(src))
		spear = null
	if(bonespear)
		bonespear.forceMove(get_turf(src))
		bonespear = null
	qdel()