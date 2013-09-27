/obj/item/weapon/storage/box/syndicate/
	New()
		..()
		switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "assassin" = 1, "cuban" = 1, "guns" = 1, "knight" = 1, "freedom" = 1, "hacker" = 1, "lordsingulo" = 1, "smoothoperator" = 1, "darklord" = 1)))
			if("bloodyspai") //Deception.
				new /obj/item/clothing/under/chameleon(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/weapon/stamp/chameleon(src) //Why the hell not?
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("stealth") //Pure stealth.
				new /obj/item/weapon/card/emag(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/device/multitool/ai_detect(src)
				new /obj/item/device/camera_bug(src)
				new /obj/item/device/chameleon(src)
				return

			if("assassin") //Murder alongside stealth.
				new /obj/item/weapon/cartridge/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/weapon/soap/syndie(src)
			//	new /obj/item/weapon/pinpointer/advpinpointer(src) //If this gets added, uncomment it.
				return

			if("cuban") //Syndicates win.
				new /obj/item/device/sbeacondrop/bomb(src)
				new /obj/item/device/sbeacondrop/bomb(src)
				new /obj/item/weapon/grenade/syndieminibomb(src)
				new /obj/item/weapon/grenade/syndieminibomb(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				return

			if("guns") //Ranged combat centric.
				new /obj/item/weapon/gun/projectile(src)
				new /obj/item/ammo_magazine/a357(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/gun/energy/crossbow(src)
				return

			if("knight") //Melee centric.
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/weapon/shield/energy(src) //So now we can see energy shields outside of nuclear emergency
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				return

			if("freedom") //Escape artist
				var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src) //Escape from cuffs.
				O.imp = new /obj/item/weapon/implant/freedom(O)
				var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src) //Escape from perma.
				U.imp = new /obj/item/weapon/implant/uplink(U)
				var/obj/item/weapon/implanter/A = new /obj/item/weapon/implanter(src) //Escape from stuns.
				A.imp = new /obj/item/weapon/implant/adrenalin(A)
				var/obj/item/weapon/implanter/E = new /obj/item/weapon/implanter(src) //Escape from borgs.
				E.imp = new /obj/item/weapon/implant/emp(E)
				return

			if("hacker") //Tools helpful to go against and eventually subvert silicons.
				new /obj/item/weapon/aiModule/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/device/encryptionkey/binary(src)
				new /obj/item/device/multitool/ai_detect(src)
				new /obj/item/device/flashlight/emp/(src)
				return

			if("lordsingulo") //The only kit not changed.
				new /obj/item/device/sbeacondrop(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				return

			if("smoothoperator") //So many goddamn gimmick stuff.
				new /obj/item/weapon/gun/projectile/pistol(src)
				new /obj/item/ammo_magazine/mc10mm(src)
				new /obj/item/weapon/silencer(src)
				new /obj/item/weapon/soap/syndie(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/device/multitool/ai_detect(src)
				new /obj/item/clothing/under/suit_jacket(src)
				new /obj/item/clothing/shoes/laceup(src)
			//	new /obj/item/weapon/pinpointer/advpinpointer(src) //If this gets added, uncomment it.
				return

			if("darklord")
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/weapon/dnainjector/telemut/darkbundle(src)
				new /obj/item/clothing/head/chaplain_hood(src)
				new /obj/item/clothing/suit/chaplain_hoodie(src)
				new /obj/item/weapon/card/id/syndicate(src)
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
	O.update_icon()
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
	O.update_icon()
	..()
	return*/

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update_icon()
	return

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	return

/obj/item/weapon/storage/box/syndie_kit/emp
	name = "EMP kit"

/obj/item/weapon/storage/box/syndie_kit/emp/New()
	..()
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/implanter/emp/(src)
	new /obj/item/device/flashlight/emp/(src)
	return