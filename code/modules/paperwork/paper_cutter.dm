/obj/structure/papercutter
	name = "paper cutter"
	desc = "Standard office equipment. Precisely cuts paper using a large blade."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papercutter-cutter"
	var/obj/item/weapon/paper/storedpaper = null
	var/obj/item/weapon/hatchet/cutterblade/storedcutter = null
	var/cuttersecured = 1


/obj/structure/papercutter/New()
	storedcutter = new /obj/item/weapon/hatchet/cutterblade(src)


/obj/structure/papercutter/update_icon()
	overlays.Cut()
	if(!storedcutter)
		icon_state = "papercutter"
	else
		icon_state = "papercutter-cutter"
	if(storedpaper)
		overlays += "paper"
	return


/obj/structure/papercutter/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/weapon/paper) && !storedpaper)
		if(!user.drop_item())
			return
		playsound(loc, "pageturn", 60, 1)
		user << "<span class='notice'>You place \the [P] in [src].</span>"
		P.loc = src
		storedpaper = P
		update_icon()
		return
	if(istype(P, /obj/item/weapon/hatchet/cutterblade) && !storedcutter)
		if(!user.drop_item())
			return
		user << "<span class='notice'>You replace [src]'s [P].</span>"
		P.loc = src
		storedcutter = P
		update_icon()
		return
	if(istype(P, /obj/item/weapon/screwdriver) && storedcutter)
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		user << "<span class='notice'>\The [storedcutter] has been [cuttersecured ? "unsecured" : "secured"].</span>"
		cuttersecured = !cuttersecured
		return
	..()


/obj/structure/papercutter/attack_hand(mob/user)
	..()
	src.add_fingerprint(user)
	if(!storedcutter)
		user << "<span class='notice'>The cutting blade is gone! You can't use \the [src] now.</span>"
		return

	if(storedcutter && !cuttersecured)
		user << "<span class='notice'>You remove [src]'s [storedcutter].</span>"
		user.put_in_hands(storedcutter)
		storedcutter = null
		update_icon()

	if(storedcutter && storedpaper)
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1)
		user << "<span class='notice'>You neatly cut \the [storedpaper].</span>"
		storedpaper = null
		qdel(storedpaper)
		new /obj/item/weapon/paperslip(src.loc)
		new /obj/item/weapon/paperslip(src.loc)
		update_icon()


/obj/item/weapon/paperslip
	name = "paper slip"
	desc = "A little slip of paper left over after a larger piece was cut. Whoa."
	icon_state = "paperslip"
	icon = 'icons/obj/bureaucracy.dmi'
	burn_state = FLAMMABLE
	burntime = 3

/obj/item/weapon/paperslip/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/weapon/hatchet/cutterblade
	name = "paper cutter"
	desc = "The blade of a paper cutter. Most likely removed for polishing or sharpening."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "cutterblade"
	item_state = "knife"
