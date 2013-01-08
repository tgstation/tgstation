/obj/item/weapon/storage/box/syndicate/
	New()
		..()
		switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "screwed" = 1, "guns" = 1, "murder" = 1, "freedom" = 1, "hacker" = 1, "lordsingulo" = 1)))
			if ("bloodyspai")
				new /obj/item/clothing/under/chameleon(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if ("stealth")
				new /obj/item/weapon/gun/energy/crossbow(src)
				new /obj/item/weapon/pen/paralysis(src)
				new /obj/item/device/chameleon(src)
				return

			if ("screwed")
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/item/device/powersink(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				return

			if ("guns")
				new /obj/item/weapon/gun/projectile(src)
				new /obj/item/ammo_magazine/a357(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/plastique(src)
				return

			if ("murder")
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("freedom")
				var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
				O.imp = new /obj/item/weapon/implant/freedom(O)
				var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
				U.imp = new /obj/item/weapon/implant/uplink(U)
				return

			if ("hacker")
				new /obj/item/weapon/aiModule/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/device/encryptionkey/binary(src)
				return

			if ("lordsingulo")
				new /obj/item/device/radio/beacon/syndicate(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				return

/obj/item/weapon/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	return

/*/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "Compressed Matter Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return

/obj/item/weapon/storage/syndie_kit/imp_explosive
	name = "Explosive Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_explosive/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
	O.name = "(BIO-HAZARD) BIO-detpack"
	O.update()
	..()
	return*/

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()
	return

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	return
