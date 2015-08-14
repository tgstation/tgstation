/obj/item/weapon/implantcase
	name = "glass case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = 1.0
	var/obj/item/weapon/implant/imp = null


/obj/item/weapon/implantcase/update_icon()
	if(imp)
		icon_state = "implantcase-[imp.item_color]"
	else
		icon_state = "implantcase-0"


/obj/item/weapon/implantcase/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "glass case- '[t]'"
		else
			name = "glass case"
	else if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		if(!imp)	return
		if(!imp.allow_reagents)	return
		if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
			user << "<span class='notice'>[src] is full.</span>"
		else
			W.reagents.trans_to(imp, 5)
			user << "<span class='notice'>You inject 5 units of the solution. The syringe now contains [W.reagents.total_volume] units.</span>"
	else if(istype(W, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/I = W
		if(I.imp)
			if((imp || I.imp.implanted))
				return
			I.imp.loc = src
			imp = I.imp
			I.imp = null
			update_icon()
			I.update_icon()
		else
			if(imp)
				if(I.imp)
					return
				imp.loc = I
				I.imp = imp
				imp = null
				update_icon()
			I.update_icon()


/obj/item/weapon/implantcase/tracking
	name = "glass case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/tracking/New()
	imp = new /obj/item/weapon/implant/tracking(src)
	..()


/obj/item/weapon/implantcase/explosive
	name = "glass case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/explosive/New()
	imp = new /obj/item/weapon/implant/explosive(src)
	..()


/obj/item/weapon/implantcase/chem
	name = "glass case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/chem/New()
	imp = new /obj/item/weapon/implant/chem(src)
	..()


/obj/item/weapon/implantcase/loyalty
	name = "glass case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty(src)
	..()

/obj/item/weapon/implantcase/weapons_auth
	name = "glass case- 'Firearms Authentication'"
	desc = "A case containing a firearms authentication implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/weapons_auth/New()
	imp = new /obj/item/weapon/implant/weapons_auth(src)
	..()
