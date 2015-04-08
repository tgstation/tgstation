//GUNCASES//
/obj/structure/guncase
	name = "gun locker"
	desc = "A locker that holds guns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "shotguncase"
	anchored = 0
	density = 1
	opacity = 0
	var/case_type = null
	var/gun_category = /obj/item/weapon/gun
	var/open = 1
	var/capacity = 4

/obj/structure/guncase/New()
	..()
	update_icon()

/obj/structure/guncase/initialize()
	..()
	for(var/obj/item/I in loc.contents)
		if(istype(I, gun_category))
			I.loc = src
		if(contents.len >= capacity)
			break
	update_icon()

/obj/structure/guncase/update_icon()
	overlays.Cut()
	for(var/i = contents.len, i >= 1, i--)
		overlays += image(icon = src.icon, icon_state = "[case_type]", pixel_x = 4 * (i -1) )
	if(open)
		overlays += "[icon_state]_open"
	else
		overlays += "[icon_state]_door"

/obj/structure/guncase/attackby(obj/item/I, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(I, gun_category))
		if(contents.len < capacity && open)
			user.drop_item()
			contents += I
			user << "<span class='notice'>You place [I] in [src].</span>"
			update_icon()
			return

	open = !open
	update_icon()

/obj/structure/guncase/attack_hand(mob/user)
	if(isrobot(usr) || isalien(usr))
		return
	if(contents.len && open)
		ShowWindow(user)
	else
		open = !open
		update_icon()

/obj/structure/guncase/proc/ShowWindow(mob/user)
	var/dat = {"<div class='block'>
				<h3>Stored Guns</h3>
				<table align='center'>"}
	for(var/i = contents.len, i >= 1, i--)
		var/obj/item/I = contents[i]
		dat += "<tr><A href='?src=\ref[src];retrieve=\ref[I]'>[I.name]</A><br>"
	dat += "</table></div>"

	var/datum/browser/popup = new(user, "gunlocker", "<div align='center'>[name]</div>", 350, 300)
	popup.set_content(dat)
	popup.open(0)

/obj/structure/guncase/Topic(href, href_list)
	if(href_list["retrieve"])
		var/obj/item/O = locate(href_list["retrieve"])
		if(!usr.canUseTopic(src))
			return
		if(ishuman(usr))
			if(!usr.get_active_hand())
				usr.put_in_hands(O)
			else
				O.loc = get_turf(src)
			update_icon()

/obj/structure/guncase/shotgun
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	case_type = "shotgun"
	gun_category = /obj/item/weapon/gun/projectile/shotgun

/obj/structure/guncase/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	icon_state = "ecase"
	case_type = "egun"
	gun_category = /obj/item/weapon/gun/energy/gun
