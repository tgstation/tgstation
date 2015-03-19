//GUNCASES//
/obj/structure/guncase
	name = "gun locker"
	desc = "A locker that holds guns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "gcase-0-open"
	anchored = 0
	density = 1
	opacity = 0
	var/case_type = "gcase"
	var/gun_category = /obj/item/weapon/gun
	var/open = 1
	var/capacity = 4

/obj/structure/guncase/initialize()
	for(var/obj/item/I in loc.contents)
		if(istype(I, gun_category))
			I.loc = src
		if(contents.len >= capacity)
			break
	update_icon()

/obj/structure/guncase/update_icon()
	icon_state = "[case_type]-[contents.len]-[open ? "open" : "closed"]"

/obj/structure/guncase/attackby(obj/item/O, mob/user, params)
	if(isrobot(usr) || isalien(usr))
		return
	if(istype(O, gun_category))
		if(contents.len < 4 && open)
			user.drop_item()
			contents += O
			user << "<span class='notice'>You place [O] in [src].</span>"
			update_icon()
		else
			if(!open)
				open = 1
			else
				open = 0
	else
		if(!open)
			open = 1
		else
			open = 0
		update_icon()

/obj/structure/guncase/attack_hand(mob/user)
	if(isrobot(usr) || isalien(usr))
		return
	if(contents.len && open)
		var/obj/item/weapon/gun/choice = input("Which gun would you like to remove from the case?") as null|obj in contents
		if(choice)
			if(!user.canUseTopic(src))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()
	else
		if(!open)
			open = 1
		else
			open = 0
		update_icon()

/obj/structure/guncase/shotgun
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	case_type = "gcase"
	gun_category = /obj/item/weapon/gun/projectile/shotgun

/obj/structure/guncase/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	icon_state = "ecase-0-open"
	case_type = "ecase"
	gun_category = /obj/item/weapon/gun/energy/gun