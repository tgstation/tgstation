/obj/item/weapon/storage/box/syndicate/

/obj/item/weapon/storage/box/syndicate/New()
	..()
	switch (pickweight(list("bloodyspai" = 1, "stealth" = 1, "bond" = 1, "screwed" = 1, "guns" = 1, "murder" = 1, "implant" = 1, "hacker" = 1, "lordsingulo" = 1, "darklord" = 1)))
		if("bloodyspai")
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/sneakers/syndigaloshes(src)
			new /obj/item/device/camera_bug(src)
			return

		if("stealth")
			new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow(src)
			new /obj/item/weapon/pen/sleepy(src)
			new /obj/item/device/chameleon(src)
			return

		if("bond")
			new /obj/item/weapon/gun/projectile/automatic/pistol(src)
			new /obj/item/weapon/suppressor(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/weapon/card/id/syndicate(src)
			return

		if("screwed")
			new /obj/item/device/sbeacondrop/bomb(src)
			new /obj/item/weapon/grenade/syndieminibomb(src)
			new /obj/item/device/powersink(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			return

		if("guns")
			new /obj/item/weapon/gun/projectile/revolver(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/c4(src)
			new /obj/item/clothing/gloves/color/latex/nitrile(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/clothing/under/suit_jacket/really_black(src)
			return

		if("murder")
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/clothing/shoes/sneakers/syndigaloshes(src)
			return

		if("implant")
			var/obj/item/weapon/implanter/F = new /obj/item/weapon/implanter(src)
			F.imp = new /obj/item/weapon/implant/freedom(F)
			var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
			U.imp = new /obj/item/weapon/implant/uplink(U)
			var/obj/item/weapon/implanter/C = new /obj/item/weapon/implanter(src)
			C.imp = new /obj/item/weapon/implant/emp(C)
			var/obj/item/weapon/implanter/K = new /obj/item/weapon/implanter(src)
			K.imp = new /obj/item/weapon/implant/adrenalin(K)
			var/obj/item/weapon/implanter/S = new /obj/item/weapon/implanter(src)
			S.imp = new /obj/item/weapon/implant/explosive(S)
			S.name += " (explosive)"
			return

		if("hacker")
			new /obj/item/weapon/aiModule/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			new /obj/item/weapon/aiModule/toyAI(src)
			return

		if("lordsingulo")
			new /obj/item/device/sbeacondrop(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			new /obj/item/weapon/card/emag(src)
			return

		if("darklord")
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/weapon/dnainjector/telemut/darkbundle(src)
			new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
			new /obj/item/weapon/card/id/syndicate(src)
			return

/obj/item/weapon/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "boxed freedom implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update_icon()
	return

/*/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "Compressed Matter Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return
*/

/obj/item/weapon/storage/box/syndie_kit/imp_microbomb
	name = "Microbomb Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_microbomb/New()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
	O.update_icon()
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_macrobomb
	name = "Macrobomb Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_macrobomb/New()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/explosive/macro(O)
	O.update_icon()
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "boxed uplink implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/imp_adrenal
	name = "boxed adrenal implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_adrenal/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/adrenalin(O)
	O.update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate, /obj/item/clothing/head/helmet/space/syndicate)
	max_w_class = 3

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate/black/red(src) // Black and red is so in right now
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	return


/obj/item/weapon/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/weapon/storage/box/syndie_kit/emp/New()
	..()
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/implanter/emp/(src)
	new /obj/item/device/flashlight/emp/(src)
	return

/obj/item/weapon/storage/box/syndie_kit/chemical
	name = "boxed chemical kit"

/obj/item/weapon/storage/box/syndie_kit/chemical/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/polonium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/venom(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/neurotoxin2(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/formaldehyde(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/cyanide(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/histamine(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/initropidril(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/pancuronium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/sodium_thiopental(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/coniine(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/curare(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/amanitin(src)
	return
