/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/obj/item/weapon/implant/imp = null


/obj/item/weapon/implanter/update_icon()
	if(imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"


/obj/item/weapon/implanter/attack(mob/M, mob/user)
	if(!iscarbon(M))
		return
	if(user && imp)
		M.visible_message("<span class='warning'>[user] is attemping to implant [M].</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_after(user, 50)))
			if(user && M && (get_turf(M) == T) && src && imp)
				M.visible_message("<span class='warning'>[M] has been implanted by [user].</span>")
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [name] ([imp.name])  by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] ([imp.name]) to implant [M.name] ([M.ckey])</font>")
				log_attack("<font color='red'>[user.name] ([user.ckey]) implanted [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>")

				user << "<span class='notice'>You implanted the implant into [M].</span>"
				if(imp.implanted(M))
					imp.loc = M
					imp.imp_in = M
					imp.implanted = 1

				imp = null
				update_icon()



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