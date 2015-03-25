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
			updateUsrDialog()
		else
			open = !open
			update_icon()
	else
		open = !open
		update_icon()

/obj/structure/guncase/attack_hand(mob/user)
	if(isrobot(usr) || isalien(usr))
		return
	if(contents.len && open)
		var/dat = "<HEAD><TITLE>[name]</TITLE></HEAD><center>"
		for(var/i = contents.len, i >= 1, i--)
			var/obj/item/O = contents[i]
			dat += "<a href='?src=\ref[src];retrieve=\ref[O]'>[O.name]</a><br>"
		dat += "</center>"
		usr << browse(dat, "window=guncase;size=350x300")
	else
		open = !open
		update_icon()

/obj/structure/guncase/Topic(href, href_list)
	if(href_list["retrieve"])
		usr << browse("", "window=guncase")
		var/obj/item/O = locate(href_list["retrieve"])
		if(!usr.canUseTopic(src))
			return
		if(ishuman(usr))
			if(!usr.get_active_hand())
				usr.put_in_hands(O)
			else
				O.loc = get_turf(src)
			update_icon()
			updateUsrDialog()


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