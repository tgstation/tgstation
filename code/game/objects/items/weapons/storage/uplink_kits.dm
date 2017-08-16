/obj/item/weapon/storage/box/syndicate

/obj/item/weapon/storage/box/syndicate/PopulateContents()
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
			new /obj/item/weapon/reagent_containers/syringe/stimulants(src)

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
			new /obj/item/weapon/melee/transforming/energy/sword/saber(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/clothing/shoes/chameleon(src)
			new /obj/item/device/encryptionkey/syndicate(src)
			new /obj/item/weapon/grenade/syndieminibomb(src)

		if("implant") // 55+ tc holy shit what the fuck this is a lottery disguised as fun boxes isn't it?
			new /obj/item/weapon/implanter/freedom(src)
			new /obj/item/weapon/implanter/uplink/precharged(src)
			new /obj/item/weapon/implanter/emp(src)
			new /obj/item/weapon/implanter/adrenalin(src)
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
			new /obj/item/weapon/cartridge/virus/syndicate(src)
			new /obj/item/weapon/storage/toolbox/syndicate(src) //To actually get to those places
			new /obj/item/pizzabox/bomb

		if("darklord") //20 tc + tk + summon item close enough for now
			new /obj/item/weapon/twohanded/dualsaber(src)
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
			new /obj/item/weapon/implanter/adrenalin(src) // 8 tc
			new /obj/item/weapon/throwing_star(src) // ~5 tc for all 6
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/throwing_star(src)
			new /obj/item/weapon/storage/belt/chameleon(src) // Unique but worth at least 2 tc
			new /obj/item/weapon/card/id/syndicate(src) // 2 tc
			new /obj/item/device/chameleon(src) // 7 tc

/obj/item/weapon/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "boxed freedom implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/PopulateContents()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update_icon()

/obj/item/weapon/storage/box/syndie_kit/imp_microbomb
	name = "Microbomb Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_microbomb/PopulateContents()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
	O.update_icon()

/obj/item/weapon/storage/box/syndie_kit/imp_macrobomb
	name = "Macrobomb Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_macrobomb/PopulateContents()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/explosive/macro(O)
	O.update_icon()

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "boxed uplink implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/PopulateContents()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update_icon()

/obj/item/weapon/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

/obj/item/weapon/storage/box/syndie_kit/bioterror/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/syringe/bioterror(src)

/obj/item/weapon/storage/box/syndie_kit/imp_adrenal
	name = "boxed adrenal implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_adrenal/PopulateContents()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/adrenalin(O)
	O.update_icon()

/obj/item/weapon/storage/box/syndie_kit/imp_storage
	name = "boxed storage implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_storage/PopulateContents()
	new /obj/item/weapon/implanter/storage(src)

/obj/item/weapon/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate, /obj/item/clothing/head/helmet/space/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/box/syndie_kit/space/PopulateContents()
	new /obj/item/clothing/suit/space/syndicate/black/red(src) // Black and red is so in right now
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)

/obj/item/weapon/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/weapon/storage/box/syndie_kit/emp/PopulateContents()
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/grenade/empgrenade(src)
	new /obj/item/weapon/implanter/emp(src)

/obj/item/weapon/storage/box/syndie_kit/chemical
	name = "boxed chemical kit"
	storage_slots = 14

/obj/item/weapon/storage/box/syndie_kit/chemical/PopulateContents()
	new /obj/item/weapon/reagent_containers/glass/bottle/polonium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/venom(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/neurotoxin2(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/formaldehyde(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/spewium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/cyanide(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/histamine(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/initropidril(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/pancuronium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/sodium_thiopental(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/coniine(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/curare(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/amanitin(src)
	new /obj/item/weapon/reagent_containers/syringe(src)

/obj/item/weapon/storage/box/syndie_kit/nuke
	name = "box"

/obj/item/weapon/storage/box/syndie_kit/nuke/PopulateContents()
	new /obj/item/weapon/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/weapon/paper/guides/antag/nuke_instructions(src)

/obj/item/weapon/storage/box/syndie_kit/supermatter
	name = "box"

/obj/item/weapon/storage/box/syndie_kit/supermatter/PopulateContents()
	new /obj/item/weapon/scalpel/supermatter(src)
	new /obj/item/weapon/hemostat/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/weapon/paper/guides/antag/supermatter_sliver(src)

/obj/item/weapon/storage/box/syndie_kit/tuberculosisgrenade
	name = "boxed virus grenade kit"

/obj/item/weapon/storage/box/syndie_kit/tuberculosisgrenade/PopulateContents()
	new /obj/item/weapon/grenade/chem_grenade/tuberculosis(src)
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/hypospray/medipen/tuberculosiscure(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/tuberculosiscure(src)

/obj/item/weapon/storage/box/syndie_kit/chameleon
	name = "chameleon kit"

/obj/item/weapon/storage/box/syndie_kit/chameleon/PopulateContents()
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
/obj/item/weapon/storage/box/syndie_kit/throwing_weapons/PopulateContents()
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/throwing_star(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)
	new /obj/item/weapon/restraints/legcuffs/bola/tactical(src)

/obj/item/weapon/storage/box/syndie_kit/cutouts/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/rainbow(src)

/obj/item/weapon/storage/box/syndie_kit/romerol/PopulateContents()
	new /obj/item/weapon/reagent_containers/glass/bottle/romerol(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	new /obj/item/weapon/reagent_containers/dropper(src)

/obj/item/weapon/storage/box/syndie_kit/ez_clean/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/weapon/grenade/chem_grenade/ez_clean(src)

/obj/item/weapon/storage/box/hug/reverse_revolver/PopulateContents()
	new /obj/item/weapon/gun/ballistic/revolver/reverse(src)

/obj/item/weapon/storage/box/syndie_kit/mimery/PopulateContents()
	new /obj/item/weapon/spellbook/oneuse/mimery_blockade(src)
	new /obj/item/weapon/spellbook/oneuse/mimery_guns(src)
