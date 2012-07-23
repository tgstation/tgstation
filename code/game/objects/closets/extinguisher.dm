/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	var/obj/item/weapon/extinguisher/has_extinguisher = new/obj/item/weapon/extinguisher
	var/opened = 0



/obj/structure/extinguisher_cabinet/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (isrobot(usr))
		return
	if (istype(O, /obj/item/weapon/extinguisher))
		if(!has_extinguisher && opened)
			user.drop_item(O)
			src.contents += O
			has_extinguisher = O
			user << "\blue You place the extinguisher in the [src.name]."
		else
			opened = !opened
	else
		opened = !opened
	update_icon()



/obj/structure/extinguisher_cabinet/attack_hand(mob/user as mob)
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		has_extinguisher = null
		user << "\blue You take the extinguisher from the [name]."
		opened = 1
	else
		opened = !opened
	update_icon()



/obj/structure/extinguisher_cabinet/attack_paw(mob/user as mob)
	attack_hand(user)
	return



/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/weapon/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"