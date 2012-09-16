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
	new /obj/item/weapon/tank/jetpack/oxygen(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/cell/high(src)
	new /obj/item/weapon/card/id/syndicate(src)
	new /obj/item/device/multitool(src)
	new /obj/item/weapon/shield/energy(src)


/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for nuclear-operative gear."

/obj/structure/closet/syndicate/nuclear/New()
	..()
	sleep(2)
	new /obj/item/ammo_magazine/a12mm(src)
	new /obj/item/ammo_magazine/a12mm(src)
	new /obj/item/ammo_magazine/a12mm(src)
	new /obj/item/ammo_magazine/a12mm(src)
	new /obj/item/ammo_magazine/a12mm(src)
	new /obj/item/weapon/storage/handcuff_kit(src)
	new /obj/item/weapon/storage/flashbang_kit(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/gun/energy/gun(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/device/pda/syndicate(src)
	var/obj/item/device/radio/uplink/U = new(src)
	U.hidden_uplink.uses = 40
	return
