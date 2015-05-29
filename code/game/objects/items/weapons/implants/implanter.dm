/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = 2.0
	var/obj/item/weapon/implant/imp = null


/obj/item/weapon/implanter/update_icon()
	if(imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"


/obj/item/weapon/implanter/attack(mob/living/carbon/M, mob/user)
	if(!iscarbon(M))
		return
	if(user && imp)
		M.visible_message("<span class='warning'>[user] is attemping to implant [M].</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_after(user, 50)))
			if(user && M && (get_turf(M) == T) && src && imp)
				M.visible_message("[user] has implanted [M].", "<span class='notice'>[user] implants you with the implant.</span>")
				add_logs(user, M, "implanted", object="[name]")
				user << "<span class='notice'>You implant the implant into [M].</span>"
				if(imp.implanted(M))
					imp.loc = M
					imp.imp_in = M
					imp.implanted = 1

				imp = null
				update_icon()
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					H.sec_hud_set_implants()



/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"

/obj/item/weapon/implanter/loyalty/New()
	imp = new /obj/item/weapon/implant/loyalty(src)
	..()
	update_icon()


/obj/item/weapon/implanter/explosive
	name = "implanter-explosive"

/obj/item/weapon/implanter/explosive/New()
	imp = new /obj/item/weapon/implant/explosive(src)
	..()
	update_icon()


/obj/item/weapon/implanter/adrenalin
	name = "implanter-adrenalin"

/obj/item/weapon/implanter/adrenalin/New()
	imp = new /obj/item/weapon/implant/adrenalin(src)
	..()
	update_icon()


/obj/item/weapon/implanter/emp
	name = "implanter-EMP"

/obj/item/weapon/implanter/emp/New()
	imp = new /obj/item/weapon/implant/emp(src)
	..()
	update_icon()
