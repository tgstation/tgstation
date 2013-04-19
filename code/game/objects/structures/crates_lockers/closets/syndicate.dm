/obj/structure/closet/syndicate
	name = "armoury closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"


/obj/structure/closet/syndicate/personal
	desc = "It's a storage unit for operative gear."

/obj/structure/closet/syndicate/personal/New()
	..()
	sleep(2)
	new /obj/item/clothing/tank/jetpack/oxygen(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/tool/crowbar/red(src)
	new /obj/item/part/cell/high(src)
	new /obj/item/security/card/id/syndicate(src)
	new /obj/item/tool/multitool(src)
	new /obj/item/weapon/shield/energy(src)


/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for nuclear-operative gear."

/obj/structure/closet/syndicate/nuclear/New()
	..()
	sleep(2)
	new /obj/item/weapon/ammo/magazine/a12mm(src)
	new /obj/item/weapon/ammo/magazine/a12mm(src)
	new /obj/item/weapon/ammo/magazine/a12mm(src)
	new /obj/item/weapon/ammo/magazine/a12mm(src)
	new /obj/item/weapon/ammo/magazine/a12mm(src)
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/device/pinpointer/nukeop(src)
	new /obj/item/device/pinpointer/nukeop(src)
	new /obj/item/device/pinpointer/nukeop(src)
	new /obj/item/device/pinpointer/nukeop(src)
	new /obj/item/device/pinpointer/nukeop(src)
	new /obj/item/device/pda/syndicate(src)
	var/obj/item/device/radio/uplink/U = new(src)
	U.hidden_uplink.uses = 40
	return

/obj/structure/closet/syndicate/resources/
	desc = "An old, dusty locker."

	New()
		..()
		var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
		var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
		var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
		var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK


		sleep(2)

		var/pickednum = rand(1, 50)

		//Sad trombone
		if(pickednum == 1)
			var/obj/item/office/paper/P = new /obj/item/office/paper(src)
			P.name = "IOU"
			P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"

		//Metal (common ore)
		if(pickednum >= 2)
			new /obj/item/part/stack/sheet/metal(src, rand(common_min, common_max))

		//Glass (common ore)
		if(pickednum >= 5)
			new /obj/item/part/stack/sheet/glass(src, rand(common_min, common_max))

		//Plasteel (common ore) Because it has a million more uses then plasma
		if(pickednum >= 10)
			new /obj/item/part/stack/sheet/plasteel(src, rand(common_min, common_max))

		//Plasma (rare ore)
		if(pickednum >= 15)
			new /obj/item/part/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

		//Silver (rare ore)
		if(pickednum >= 20)
			new /obj/item/part/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

		//Gold (rare ore)
		if(pickednum >= 30)
			new /obj/item/part/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

		//Uranium (rare ore)
		if(pickednum >= 40)
			new /obj/item/part/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

		//Diamond (rare HONK)
		if(pickednum >= 45)
			new /obj/item/part/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

		//Jetpack (You hit the jackpot!)
		if(pickednum == 50)
			new /obj/item/clothing/tank/jetpack/carbondioxide(src)

		return

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

	New()
		var/list/resources = list(
		/obj/item/part/stack/sheet/metal,
		/obj/item/part/stack/sheet/glass,
		/obj/item/part/stack/sheet/mineral/gold,
		/obj/item/part/stack/sheet/mineral/silver,
		/obj/item/part/stack/sheet/mineral/plasma,
		/obj/item/part/stack/sheet/mineral/uranium,
		/obj/item/part/stack/sheet/mineral/diamond,
		/obj/item/part/stack/sheet/mineral/clown,
		/obj/item/part/stack/sheet/plasteel,
		/obj/item/part/stack/rods
		)

		sleep(2)

		for(var/i = 0, i<2, i++)
			for(var/res in resources)
				var/obj/item/part/stack/R = new res(src)
				R.amount = R.max_amount

		return