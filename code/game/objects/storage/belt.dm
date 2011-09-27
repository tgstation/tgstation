/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT | TABLEPASS | ONBELT


	proc/can_use()
		if(!ismob(loc)) return 0
		var/mob/M = loc
		if(src in M.get_equipped_items())
			return 1
		else
			return 0


	MouseDrop(obj/over_object as obj, src_location, over_location)
		var/mob/M = usr
		if(!istype(over_object, /obj/screen))
			return ..()
		playsound(src.loc, "rustle", 50, 1, -5)
		if (!M.restrained() && !M.stat && can_use())
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return


	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if(src.loc == user)
			playsound(src.loc, "rustle", 50, 1, -5)
			if (user.s_active)
				user.s_active.close(user)
			src.show_to(user)
		else
			return ..()



/obj/item/weapon/storage/belt/utility
	name = "utility belt"
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer")


/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/weapon/cable_coil(src,30,pick("red","yellow"))



/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen"
	)


/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 4
	can_hold = list(
		"/obj/item/weapon/flashbang",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine"
		)