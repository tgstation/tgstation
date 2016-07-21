/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	var/obj/item/weapon/extinguisher/has_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
		opened = 1
		icon_state = "extinguisher_empty"
	else
		has_extinguisher = new /obj/item/weapon/extinguisher(src)

/obj/structure/extinguisher_cabinet/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				if(has_extinguisher)
					has_extinguisher.loc = src.loc
				qdel(src)
				return
		if(3)
			return


/obj/structure/extinguisher_cabinet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench) && !has_extinguisher)
		user << "<span class='notice'>You start unsecuring [name]...</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 60/I.toolspeed, target = src))
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user << "<span class='notice'>You unsecure [name].</span>"
			new /obj/item/wallframe/extinguisher_cabinet(loc)
			qdel(src)
		return

	if(isrobot(user) || isalien(user))
		return
	if(istype(I, /obj/item/weapon/extinguisher))
		if(!has_extinguisher && opened)
			if(!user.drop_item())
				return
			contents += I
			has_extinguisher = I
			user << "<span class='notice'>You place [I] in [src].</span>"
		else
			opened = !opened
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		user << "<span class='notice'>You take [has_extinguisher] from [src].</span>"
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		user << "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>"
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)
	return

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user) || !istype(user))
		return
	opened = !opened
	update_icon()

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

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "extinguisher_frame"
	result_path = /obj/structure/extinguisher_cabinet
