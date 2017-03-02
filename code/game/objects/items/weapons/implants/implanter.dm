/obj/item/weapon/implanter
	name = "implanter"
	desc = "A sterile automatic implant injector."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL=600, MAT_GLASS=200)
	var/obj/item/weapon/implant/imp = null


/obj/item/weapon/implanter/update_icon()
	if(imp)
		icon_state = "implanter1"
		origin_tech = imp.origin_tech
	else
		icon_state = "implanter0"
		origin_tech = initial(origin_tech)


/obj/item/weapon/implanter/attack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(user && imp)
		if(M != user)
			M.visible_message("<span class='warning'>[user] is attemping to implant [M].</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_mob(user, M, 50)))
			if(src && imp)
				if(imp.implant(M, user))
					if (M == user)
						user << "<span class='notice'>You implant yourself.</span>"
					else
						M.visible_message("[user] has implanted [M].", "<span class='notice'>[user] implants you.</span>")
					imp = null
					update_icon()
				else
					user << "<span class='warning'>[src] fails to implant [M].</span>"

/obj/item/weapon/implanter/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_held_item() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "implanter ([t])"
		else
			name = "implanter"
	else
		return ..()

/obj/item/weapon/implanter/New()
	..()
	update_icon()




/obj/item/weapon/implanter/adrenalin
	name = "implanter (adrenalin)"

/obj/item/weapon/implanter/adrenalin/New()
	imp = new /obj/item/weapon/implant/adrenalin(src)
	..()


/obj/item/weapon/implanter/emp
	name = "implanter (EMP)"

/obj/item/weapon/implanter/emp/New()
	imp = new /obj/item/weapon/implant/emp(src)
	..()
