/obj/item/weapon/storage/box/syndicate/

/obj/item/weapon/storage/box/syndicate/New()
	..()
	switch (pickweight(list("bloodyspai" = 3, "stealth" = 3, "bond" = 1, "screwed" = 3, "sabotage" = 3, "guns" = 1, "murder" = 2, "implant" = 2, "hacker" = 2, "lordsingulo" = 2, "darklord" = 1)))
		if("bloodyspai")
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/clothing/mask/chameleon(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/chameleon(src)
			new /obj/item/device/camera_bug(src)
			new /obj/item/device/multitool/ai_detect(src)
			new /obj/item/device/encryptionkey/syndicate(src)
			new /obj/item/weapon/reagent_containers/syringe/mulligan(src)
			new /obj/item/weapon/switchblade(src)
			return

		if("stealth")
			new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow(src)
			new /obj/item/weapon/pen/sleepy(src)
			new /obj/item/device/rad_laser(src)
			new /obj/item/device/chameleon(src)
			new /obj/item/weapon/soap/syndie(src)
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
			new /obj/item/device/sbeacondrop/powersink(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			new /obj/item/device/encryptionkey/syndicate(src)
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
			new /obj/item/clothing/shoes/chameleon(src)
			return

		if("implant")
			new /obj/item/weapon/implanter/freedom(src)
			new /obj/item/weapon/implanter/uplink(src)
			new /obj/item/weapon/implanter/emp(src)
			new /obj/item/weapon/implanter/adrenalin(src)
			new /obj/item/weapon/implanter/explosive(src)
			new /obj/item/weapon/implanter/storage(src)
			return

		if("hacker")
			new /obj/item/weapon/aiModule/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			new /obj/item/weapon/aiModule/toyAI(src)
			new /obj/item/device/multitool/ai_detect(src)
			return

		if("lordsingulo")
			new /obj/item/device/sbeacondrop(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			new /obj/item/weapon/card/emag(src)
			return

		if("sabotage")
			new /obj/item/weapon/c4 (src)
			new /obj/item/weapon/c4 (src)
			new /obj/item/device/doorCharge(src)
			new /obj/item/device/doorCharge(src)
			new /obj/item/device/camera_bug(src)
			new /obj/item/device/sbeacondrop/powersink(src)
			new /obj/item/weapon/cartridge/syndicate(src)

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

/obj/item/weapon/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

/obj/item/weapon/storage/box/syndie_kit/bioterror/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)
	return

/obj/item/weapon/storage/box/syndie_kit/imp_adrenal
	name = "boxed adrenal implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_adrenal/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/adrenalin(O)
	O.update_icon()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_storage
	name = "boxed storage implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_storage/New()
	..()
	new /obj/item/weapon/implanter/storage(src)
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
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/implanter/emp(src)

/obj/item/weapon/storage/box/syndie_kit/chemical
	name = "boxed chemical kit"
	storage_slots = 14

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
	new /obj/item/weapon/reagent_containers/syringe(src)
	return

/obj/item/weapon/storage/box/syndie_kit/nuke
	name = "box"

/obj/item/weapon/storage/box/syndie_kit/nuke/New()
	..()
	new /obj/item/weapon/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/weapon/paper/nuke_instructions(src)

/obj/item/weapon/storage/box/syndie_kit/tuberculosisgrenade
	name = "boxed virus grenade kit"

/obj/item/weapon/storage/box/syndie_kit/tuberculosisgrenade/New()
	..()
	new /obj/item/weapon/grenade/chem_grenade/tuberculosis(src)
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/hypospray/medipen/tuberculosiscure(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/tuberculosiscure(src)

/obj/item/weapon/storage/box/syndie_kit/chameleon
	name = "chameleon kit"

/obj/item/weapon/storage/box/syndie_kit/chameleon/New()
	..()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/weapon/storage/backpack/chameleon(src)
	new /obj/item/device/radio/headset/chameleon(src)
	new /obj/item/weapon/stamp/chameleon(src)
	new /obj/item/device/pda/chameleon(src)
	new /obj/item/weapon/gun/energy/laser/chameleon(src)

//5*(2*4) = 5*8 = 45, 45 damage if you hit one person with all 5 stars.
//Not counting the damage it will do while embedded (2*4 = 8, at 15% chance)
/obj/item/weapon/storage/box/syndie_kit/throwing_weapons/New()
	..()
	contents = list()
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)