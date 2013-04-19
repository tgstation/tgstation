/obj/item/storage/box/syndicate/
	New()
		..()
		switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "screwed" = 1, "guns" = 1, "murder" = 1, "freedom" = 1, "hacker" = 1, "lordsingulo" = 1, "smoothoperator" = 1, "darklord" = 1)))
			if("bloodyspai")
				new /obj/item/clothing/under/chameleon(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/security/card/id/syndicate(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("stealth")
				new /obj/item/weapon/gun/energy/crossbow(src)
				new /obj/item/office/pen/paralysis(src)
				new /obj/item/device/chameleon(src)
				return

			if("screwed")
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/item/device/powersink(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				return

			if("guns")
				new /obj/item/weapon/gun/projectile(src)
				new /obj/item/weapon/ammo/magazine/a357(src)
				new /obj/item/security/card/emag(src)
				new /obj/item/weapon/plastique(src)
				return

			if("murder")
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/security/card/emag(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("freedom")
				var/obj/item/medical/implanter/O = new /obj/item/medical/implanter(src)
				O.imp = new /obj/item/medical/implant/freedom(O)
				var/obj/item/medical/implanter/U = new /obj/item/medical/implanter(src)
				U.imp = new /obj/item/medical/implant/uplink(U)
				return

			if("hacker")
				new /obj/item/part/board/aiModule/syndicate(src)
				new /obj/item/security/card/emag(src)
				new /obj/item/part/cipher/binary(src)
				return

			if("lordsingulo")
				new /obj/item/device/sbeacondrop(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				new /obj/item/security/card/emag(src)
				return

			if("smoothoperator")
				new /obj/item/weapon/gun/projectile/pistol(src)
				new /obj/item/weapon/silencer(src)
				new /obj/item/service/soap/syndie(src)
				new /obj/item/storage/bag/trash(src)
				new /obj/item/medical/bodybag(src)
				new /obj/item/clothing/under/suit_jacket(src)
				new /obj/item/clothing/shoes/laceup(src)
				return

			if("darklord")
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/medical/dnainjector/telemut/darkbundle(src)
				new /obj/item/clothing/head/chaplain_hood(src)
				new /obj/item/clothing/suit/chaplain_hoodie(src)
				new /obj/item/security/card/id/syndicate(src)
				return

/obj/item/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/storage/box/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/storage/box/syndie_kit/imp_freedom/New()
	..()
	var/obj/item/medical/implanter/O = new(src)
	O.imp = new /obj/item/medical/implant/freedom(O)
	O.update_icon()
	return

/*/obj/item/storage/box/syndie_kit/imp_compress
	name = "Compressed Matter Implant (with injector)"

/obj/item/storage/syndie_kit/imp_compress/New()
	new /obj/item/medical/implanter/compressed(src)
	..()
	return

/obj/item/storage/syndie_kit/imp_explosive
	name = "Explosive Implant (with injector)"

/obj/item/storage/syndie_kit/imp_explosive/New()
	var/obj/item/medical/implanter/O = new /obj/item/medical/implanter(src)
	O.imp = new /obj/item/medical/implant/explosive(O)
	O.name = "(BIO-HAZARD) BIO-detpack"
	O.update_icon()
	..()
	return*/

/obj/item/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/medical/implanter/O = new(src)
	O.imp = new /obj/item/medical/implant/uplink(O)
	O.update_icon()
	return

/obj/item/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	return
