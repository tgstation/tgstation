/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	icon_state = "headpike"
	density = 0
	anchored = 1

/obj/structure/headpike/CheckParts(list/parts_list)
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	if(H)
		overlays = H.overlays //head
		update_icon()
		name = "[H.real_name]'s head on a spear"

/obj/structure/headpike/attack_hand(mob/user)
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	var/obj/item/weapon/twohanded/spear/S = locate() in contents
	if(H && S)
		to_chat(user, "<span class='notice'>You take down the head spike.</span>")
		H.forceMove(get_turf(src))
		S.forceMove(get_turf(src))
		qdel(src)
