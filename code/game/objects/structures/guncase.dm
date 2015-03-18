//GUNCASES//

/obj/structure/guncase
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "gcase-0-open"
	anchored = 0
	density = 1
	opacity = 0
	var/open = 1
	var/capacity = 4

/obj/structure/guncase/initialize()
	for(var/obj/item/I in loc.contents)
		if(istype(I, /obj/item/weapon/gun/projectile/shotgun))
			I.loc = src
		if(contents.len >= capacity)
			break
	update_icon()

/obj/structure/guncase/update_icon()
	icon_state = "gcase-[contents.len]-[open ? "open" : "closed"]"

/obj/structure/guncase/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/weapon/gun/projectile/shotgun))
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
	if(isrobot(user) || isalien(user))
		return
	if(contents.len && open)
		var/obj/item/weapon/gun/projectile/shotgun/choice = input("Which gun would you like to remove from the case?") as null|obj in contents
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
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

/obj/structure/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "ecase-0-open"
	anchored = 0
	density = 1
	opacity = 0
	var/open = 1
	var/capacity = 4

/obj/structure/ecase/initialize()
	for(var/obj/item/I in loc.contents)
		if(istype(I, /obj/item/weapon/gun/energy/gun))
			I.loc = src
		if(contents.len >= capacity)
			break
	update_icon()

/obj/structure/ecase/update_icon()
	icon_state = "ecase-[contents.len]-[open ? "open" : "closed"]"

/obj/structure/ecase/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/weapon/gun/energy/gun))
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

/obj/structure/ecase/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		return
	if(contents.len && open)
		var/obj/item/weapon/gun/energy/gun/choice = input("Which gun would you like to remove from the case?") as null|obj in contents
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
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