/obj/item/weapon/storage/box/syndicate

/obj/item/weapon/storage/box/syndicate/New()
	..()
	switch (pickweight(list("bloodyspai" = 3, "stealth" = 2, "bond" = 2, "screwed" = 2, "sabotage" = 3, "guns" = 2, "murder" = 2, "implant" = 1, "hacker" = 3, "darklord" = 1, "sniper" = 1, "metaops" = 1, "ninja" = 1)))
		if("bloodyspai") // 27 tc now this is more right
			new /obj/item/clothing/under/chameleon(src) // 2 tc since it's not the full set
			new /obj/item/clothing/mask/chameleon(src) // Goes with above
			new /obj/item/weapon/card/id/syndicate(src) // 2 tc
			new /obj/item/clothing/shoes/chameleon(src) // 2 tc
			new /obj/item/device/camera_bug(src) // 1 tc
			new /obj/item/device/multitool/ai_detect(src) // 1 tc
			new /obj/item/device/encryptionkey/syndicate(src) // 2 tc
			new /obj/item/weapon/reagent_containers/syringe/mulligan(src) // 4 tc
			new /obj/item/weapon/switchblade(src) //I'll count this as 2 tc
			new /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate (src) // 2 tc this shit heals
			new /obj/item/device/flashlight/emp(src) // 2 tc
			new /obj/item/device/chameleon(src) // 7 tc

		if("stealth") // 31 tc
			new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow(src)
			new /obj/item/weapon/pen/sleepy(src)
			new /obj/item/device/healthanalyzer/rad_laser(src)
			new /obj/item/device/chameleon(src)
			new /obj/item/weapon/soap/syndie(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)

		if("bond") // 29 tc
			new /obj/item/weapon/gun/ballistic/automatic/pistol(src)
			new /obj/item/weapon/suppressor(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/reagent_containers/syringe/nanoboost(src)

		if("screwed") // 29 tc
			new /obj/item/device/sbeacondrop/bomb(src)
			new /obj/item/weapon/grenade/syndieminibomb(src)
			new /obj/item/device/sbeacondrop/powersink(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			new /obj/item/device/encryptionkey/syndicate(src)

		if("guns") // 28 tc now
			new /obj/item/weapon/gun/ballistic/revolver(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/grenade/plastic/c4(src)
			new /obj/item/clothing/gloves/color/latex/nitrile(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/clothing/under/suit_jacket/really_black(src)

		if("murder") // 28 tc now
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/clothing/shoes/chameleon(src)
			new /obj/item/device/encryptionkey/syndicate(src)
			new /obj/item/weapon/grenade/syndieminibomb(src)

		if("implant") // 55+ tc holy shit what the fuck this is a lottery disguised as fun boxes isn't it?
			new /obj/item/weapon/implanter/freedom(src)
			new /obj/item/weapon/implanter/uplink/precharged(src)
			new /obj/item/weapon/implanter/emp(src)
			new /obj/item/weapon/implanter/comstimms(src)
			new /obj/item/weapon/implanter/explosive(src)
			new /obj/item/weapon/implanter/storage(src)

		if("hacker") // 26 tc
			new /obj/item/weapon/aiModule/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			new /obj/item/weapon/aiModule/toyAI(src)
			new /obj/item/device/multitool/ai_detect(src)

		if("lordsingulo") // 24 tc
			new /obj/item/device/sbeacondrop(src)
			new /obj/item/clothing/suit/space/syndicate/black/red(src)
			new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
			new /obj/item/weapon/card/emag(src)

		if("sabotage") // 26 tc now
			new /obj/item/weapon/grenade/plastic/c4 (src)
			new /obj/item/weapon/grenade/plastic/c4 (src)
			new /obj/item/device/doorCharge(src)
			new /obj/item/device/doorCharge(src)
			new /obj/item/device/camera_bug(src)
			new /obj/item/device/sbeacondrop/powersink(src)
			new /obj/item/weapon/cartridge/syndicate(src)
			new /obj/item/weapon/storage/toolbox/syndicate(src) //To actually get to those places
			new /obj/item/pizzabox/bomb

		if("darklord") //20 tc + tk + summon item close enough for now
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/weapon/melee/energy/sword/saber(src)
			new /obj/item/weapon/dnainjector/telemut/darkbundle(src)
			new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/chameleon(src) //because slipping while being a dark lord sucks
			new /obj/item/weapon/spellbook/oneuse/summonitem(src)

		if("sniper") //This shit is unique so can't really balance it around tc, also no silencer because getting killed without ANY indicator on what killed you sucks
			new /obj/item/weapon/gun/ballistic/automatic/sniper_rifle(src) // 12 tc
			new /obj/item/ammo_box/magazine/sniper_rounds/penetrator(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/clothing/gloves/color/latex/nitrile(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/clothing/under/suit_jacket/really_black(src)

		if("metaops") // 30 tc
			new /obj/item/clothing/suit/space/hardsuit/syndi(src) // 8 tc
			new /obj/item/weapon/gun/ballistic/automatic/shotgun/bulldog/unrestricted(src) // 8 tc
			new /obj/item/weapon/implanter/explosive(src) // 2 tc
			new /obj/item/ammo_box/magazine/m12g/buckshot(src) // 2 tc
			new /obj/item/ammo_box/magazine/m12g/buckshot(src) // 2 tc
			new /obj/item/weapon/grenade/plastic/c4 (src) // 1 tc
			new /obj/item/weapon/grenade/plastic/c4 (src) // 1 tc
			new /obj/item/weapon/card/emag(src) // 6 tc

		if("ninja") // 33 tc worth
			new /obj/item/weapon/katana(src) // Unique , hard to tell how much tc this is worth. 8 tc?
			new /obj/item/weapon/implanter/comstimms(src) // 8 tc
			new /obj/item/weapon/throwing_star(src) // ~5 tc for all 6
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/storage/belt/chameleon(src) // Unique but worth at least 2 tc
			new /obj/item/weapon/card/id/syndicate(src) // 2 tc
			new /obj/item/device/chameleon(src) // 7 tc


/obj/item/weapon/storage/box/syndie_kit/imp_comstimms
	name = "boxed combat stimulant implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_comstimms/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/comstimms(O)
	O.update_icon()
