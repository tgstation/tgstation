/obj/item/weapon/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=2"
	materials = list(MAT_GLASS=500)
	var/obj/item/weapon/implant/imp = null
	var/imp_type


/obj/item/weapon/implantcase/update_icon()
	if(imp)
		icon_state = "implantcase-[imp.item_color]"
		origin_tech = imp.origin_tech
		reagents = imp.reagents
	else
		icon_state = "implantcase-0"
		origin_tech = initial(origin_tech)
		reagents = null


/obj/item/weapon/implantcase/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_held_item() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "implant case - '[t]'"
		else
			name = "implant case"
	else if(istype(W, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/I = W
		if(I.imp)
			if(imp || I.imp.imp_in)
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

	else
		return ..()

/obj/item/weapon/implantcase/Initialize(mapload)
	..()
	if(imp_type)
		imp = new imp_type(src)
	update_icon()


/obj/item/weapon/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."
	imp_type = /obj/item/weapon/implant/tracking

/obj/item/weapon/implantcase/weapons_auth
	name = "implant case - 'Firearms Authentication'"
	desc = "A glass case containing a firearms authentication implant."
	imp_type = /obj/item/weapon/implant/weapons_auth

/obj/item/weapon/implantcase/adrenaline
	name = "implant case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline implant."
	imp_type = /obj/item/weapon/implant/adrenalin
