/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")


/obj/item/storage/belt/proc/can_use()
	if(!ismob(loc)) return 0
	var/mob/M = loc
	if(src in M.get_equipped_items())
		return 1
	else
		return 0


/obj/item/storage/belt/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen))
		return ..()
	playsound(src.loc, "rustle", 50, 1, -5)
	if (!M.restrained() && !M.stat && can_use())
		switch(over_object.name)
			if("r_hand")
				M.u_equip(src)
				M.put_in_r_hand(src)
			if("l_hand")
				M.u_equip(src)
				M.put_in_l_hand(src)
		src.add_fingerprint(usr)
		return



/obj/item/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/tool/crowbar",
		"/obj/item/tool/screwdriver",
		"/obj/item/tool/welder",
		"/obj/item/part/wirecutters",
		"/obj/item/tool/wrench",
		"/obj/item/tool/multitool",
		"/obj/item/tool/flashlight",
		"/obj/item/part/cable_coil",
		"/obj/item/device/scanner/t_ray",
		"/obj/item/device/scanner/atmospheric")


/obj/item/storage/belt/utility/full/New()
	..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/welder(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/part/wirecutters(src)
	new /obj/item/part/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/welder(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/part/wirecutters(src)
	new /obj/item/device/scanner/t_ray(src)



/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/scanner/health",
		"/obj/item/medical/dnainjector",
		"/obj/item/chem/dropper",
		"/obj/item/chem/glass/beaker",
		"/obj/item/chem/glass/bottle",
		"/obj/item/chem/pill",
		"/obj/item/chem/syringe",
		"/obj/item/chem/glass/dispenser",
		"/obj/item/tool/lighter/zippo",
		"/obj/item/storage/fancy/cigarettes",
		"/obj/item/storage/pill_bottle",
		"/obj/item/part/stack/medical",
		"/obj/item/tool/flashlight/pen"
	)


/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 4
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/chem/spray/pepper",
		"/obj/item/security/handcuffs",
		"/obj/item/security/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/ammo/casing/shotgun",
		"/obj/item/weapon/ammo/magazine",
		"/obj/item/chem/food/snacks/donut/normal",
		"/obj/item/chem/food/snacks/donut/jelly"
		)

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/magic/soulstone"
		)

/obj/item/storage/belt/soulstone/full/New()
	..()
	new /obj/item/magic/soulstone(src)
	new /obj/item/magic/soulstone(src)
	new /obj/item/magic/soulstone(src)
	new /obj/item/magic/soulstone(src)
	new /obj/item/magic/soulstone(src)
	new /obj/item/magic/soulstone(src)


/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		"/obj/item/clothing/mask/luchador"
		)