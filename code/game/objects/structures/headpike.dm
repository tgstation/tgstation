/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	icon_state = "headpike"
	density = FALSE
	anchored = TRUE

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"


/obj/structure/headpike/CheckParts(list/parts_list)
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	if(H)
		update_icon()
		name = "[H.real_name]'s head on a spear"

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
	var/obj/item/bodypart/head/H = locate() in contents
	var/obj/item/twohanded/spear/S = locate() in contents
	if(H && S)
		to_chat(user, "<span class='notice'>You take down [src].</span>")
		H.forceMove(get_turf(src))
		S.forceMove(get_turf(src))
		qdel()

/obj/structure/headpike/bone/attack_hand(mob/user)
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	var/obj/item/twohanded/bonespear/S = locate() in contents
	if(H && S)
		to_chat(user, "<span class='notice'>You take down [src].</span>")
		H.forceMove(get_turf(src))
		S.forceMove(get_turf(src))
		qdel()
