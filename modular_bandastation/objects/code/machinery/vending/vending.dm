//MARK: Vending Machines

// Robotics Wardrobe
/obj/machinery/vending/wardrobe/robo_wardrobe
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "robodrobe"
	panel_type = "panel19"
	light_mask = null

/obj/machinery/vending/wardrobe/robo_wardrobe/build_inventories(start_empty)
	products |= list(
		/obj/item/clothing/head/beret = 2,
		/obj/item/clothing/head/cowboy/roboticist = 2,
		/obj/item/clothing/head/soft/roboticist_cap = 2,
		/obj/item/clothing/suit/hooded/roboticist_cloak = 2,
		/obj/item/clothing/suit/toggle/jacket/roboticist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/red = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/hoodie = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt/red = 2,
		/obj/item/clothing/suit/jacket/bomber/roboticist =2,
		)
	. = ..()

// CentCom NT Ammunition
/obj/machinery/vending/nta
	name = "\improper NT Ammunition"
	desc = "A special equipment vendor."
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "nta"
	product_ads = "Если ты увидел меня - сообщи разработчикам!"
	vend_reply = "Не нужно меня использовать, скорее сообщи разработчикам!"
	onstation = FALSE
	all_products_free = TRUE
	products = list(
		/obj/item/toy/plush/moth = 1
	)
	refill_canister = /obj/item/vending_refill/nta

/obj/item/vending_refill/nta
	machine_name = "NT Ammunition"
	icon = 'modular_bandastation/objects/icons/obj/machines/vending_restock.dmi'
	icon_state = "refill_nta"
	light_color = LIGHT_COLOR_BLUE

// Light Gear
/obj/machinery/vending/nta/light
	name = "\improper NT Ammunition - Light Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор средства для подавления беспорядков и нелетального задержания."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снярядись на задание!"
	vend_reply = "Слава Нанотрейзен!"

	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/shotgun/riot = 10,
				/obj/item/gun/energy/disabler = 8,
				/obj/item/gun/ballistic/automatic/pistol/gp9 = 8,
				/obj/item/gun/energy/disabler/smg = 5,
				/obj/item/gun/energy/e_gun = 3,
				/obj/item/gun/energy/ionrifle = 2,
				/obj/item/gun/energy/e_gun/dragnet = 5,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/storage/box/rubbershot = 10,
				/obj/item/storage/box/beanbag = 10,
				/obj/item/storage/box/breacherslug = 3,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/rubber = 10,
				/obj/item/ammo_box/magazine/c9x25mm_pistol = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 2,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 2,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/flashbang = 7,
				/obj/item/grenade/barrier = 7,
				/obj/item/ammo_box/c9x25mm/rubber = 3,
				/obj/item/ammo_box/c9x25mm = 3,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/baton = 3,
				/obj/item/melee/baton/security/loaded = 8,
				/obj/item/clothing/head/helmet/swat/nanotrasen = 8,
				/obj/item/clothing/suit/armor/swat/ert = 8,
				/obj/item/clothing/head/helmet/toggleable/riot = 8,
				/obj/item/clothing/suit/armor/riot = 8,
				/obj/item/clothing/head/helmet/alt = 8,
				/obj/item/clothing/suit/armor/bulletproof = 8,
				/obj/item/shield/riot = 5,
				/obj/item/shield/riot/tele = 3,
				/obj/item/shield/riot/flash = 3,
				/obj/item/clothing/mask/gas/sechailer/swat = 8,
				/obj/item/clothing/glasses/hud/security/sunglasses = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 5,
				/obj/item/clothing/gloves/combat = 8,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/storage/belt/security/webbing/ert = 5,
				/obj/item/storage/belt/military/assault/ert = 5,
				/obj/item/clothing/accessory/holster/tacticool = 3,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/handcuffs = 20,
				/obj/item/restraints/legcuffs/bola/energy = 10,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/regular = 5,
				/obj/item/storage/medkit/advanced = 2,
				/obj/item/storage/medkit/o2 = 3,
				/obj/item/storage/medkit/toxin = 3,
				/obj/item/storage/medkit/brute = 3,
				/obj/item/storage/medkit/fire = 3,
				/obj/item/storage/medkit/surgery = 1,
				/obj/item/reagent_containers/medigel/aiuri = 3,
				/obj/item/reagent_containers/medigel/libital = 3,
			),
		),
	)

// Heavy Gear
/obj/machinery/vending/nta/heavy
	name = "\improper NT Ammunition - Heavy Gear"
	desc = "Раздатчик специального оборудования для отрядов быстрого реагирования от дочерней компании \"NT Ammunition\". На выбор штурмовое снаряжение и средства для проведения сложных боевых операций."
	product_ads = "Круши черепа синдиката!;Не забывай, спасать - полезно!;Бжж-Бзз-з!;Обезопасить, Удержать, Сохранить!;Стоять, снярядись на задание!"
	vend_reply = "Слава Нанотрейзен!"
	product_categories = list(
		list(
			"name" = "Weapon",
			"icon" = "gun",
			"products" = list(
				/obj/item/gun/ballistic/automatic/pistol/gp9 = 5,
				/obj/item/gun/ballistic/automatic/battle_rifle = 3,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
				/obj/item/gun/energy/e_gun/nuclear = 5,
				/obj/item/gun/energy/e_gun/stun = 5,
				/obj/item/gun/energy/e_gun/lethal = 5,
				/obj/item/gun/ballistic/automatic/laser = 4,
				/obj/item/gun/energy/laser/carbine = 5,
				/obj/item/gun/energy/ionrifle/carbine = 4,
				/obj/item/gun/ballistic/automatic/proto/unrestricted = 3,
				/obj/item/gun/ballistic/automatic/wt550 = 3,
				/obj/item/gun/grenadelauncher = 1,
			),
		),

		list(
			"name" = "Ammo & Grenades",
			"icon" = "box",
			"products" = list(
				/obj/item/storage/box/rubbershot = 8,
				/obj/item/storage/box/lethalshot = 8,
				/obj/item/storage/box/breacherslug = 4,
				/obj/item/storage/box/slugs = 8,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/rubber = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp = 5,
				/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = 5,
				/obj/item/ammo_box/magazine/m38 = 10,
				/obj/item/ammo_box/magazine/m38/dumdum = 5,
				/obj/item/ammo_box/magazine/m38/flare = 5,
				/obj/item/ammo_box/magazine/m38/iceblox = 5,
				/obj/item/ammo_box/magazine/m38/hotshot = 5,
				/obj/item/ammo_box/magazine/m38/true = 5,
				/obj/item/ammo_box/magazine/recharge = 10,
				/obj/item/ammo_box/magazine/smgm9mm = 10,
				/obj/item/ammo_box/magazine/smgm9mm/ap = 5,
				/obj/item/ammo_box/magazine/smgm9mm/fire = 5,
				/obj/item/ammo_box/magazine/wt550m9 = 10,
				/obj/item/ammo_box/magazine/wt550m9/wtap = 5,
				/obj/item/ammo_box/magazine/wt550m9/wtic = 5,
				/obj/item/grenade/chem_grenade/teargas = 7,
				/obj/item/grenade/flashbang = 7,
				/obj/item/grenade/barrier = 7,
				/obj/item/grenade/frag = 7,
				/obj/item/grenade/chem_grenade/incendiary = 7,
			),
		),

		list(
			"name" = "Equipment",
			"icon" = "hand-fist",
			"products" = list(
				/obj/item/melee/curator_whip = 2,
				/obj/item/melee/baton/security/loaded/hos = 10,
				/obj/item/clothing/head/helmet/marine = 8,
				/obj/item/clothing/suit/armor/vest/marine = 8,
				/obj/item/clothing/head/helmet/marine/pmc = 8,
				/obj/item/clothing/suit/armor/vest/marine/pmc = 8,
				/obj/item/shield/riot/tele = 5,
				/obj/item/shield/riot/flash = 5,
				/obj/item/clothing/mask/gas/sechailer/swat = 8,
				/obj/item/clothing/glasses/hud/security/sunglasses = 8,
				/obj/item/clothing/gloves/tackler/combat/insulated = 8,
				/obj/item/clothing/gloves/combat = 8,
				/obj/item/storage/belt/bandolier = 3,
				/obj/item/storage/backpack/ert/security = 8,
				/obj/item/mod/control/pre_equipped/responsory/security = 5,
				/obj/item/mod/control/pre_equipped/responsory/commander = 1,
				/obj/item/mod/control/pre_equipped/responsory/medic = 1,
				/obj/item/mod/control/pre_equipped/responsory/engineer = 1,
				/obj/item/clothing/accessory/holster/tacticool = 5,
				/obj/item/storage/belt/military/ert = 8,
				/obj/item/storage/belt/military/holster = 8,
				/obj/item/storage/belt/military/army = 8,
				/obj/item/flashlight/seclite = 8,
				/obj/item/restraints/handcuffs = 20,
				/obj/item/restraints/legcuffs/bola/energy = 10,
				/obj/item/restraints/legcuffs/bola/tactical = 5,
			),
		),

		list(
			"name" = "Medical",
			"icon" = "briefcase",
			"products" = list(
				/obj/item/storage/medkit/advanced = 2,
				/obj/item/storage/medkit/o2 = 2,
				/obj/item/storage/medkit/toxin = 2,
				/obj/item/storage/medkit/tactical_lite = 2,
				/obj/item/storage/medkit/tactical = 2,
				/obj/item/storage/medkit/tactical/premium = 1,
				/obj/item/defibrillator/compact/combat/loaded/nanotrasen = 2,
				/obj/item/storage/medkit/surgery = 1,
				/obj/item/reagent_containers/hypospray/combat = 3,
				/obj/item/reagent_containers/hypospray/medipen/stimpack = 5,
				/obj/item/reagent_containers/medigel/synthflesh = 3,
				/obj/item/storage/pill_bottle/mannitol = 3,
				/obj/item/storage/pill_bottle/mutadone = 3,
			),
		),
	)

// Clothing vendors
/obj/machinery/vending/autodrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/ratge = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/chef_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/rank/civilian/chef/red = 2,
		/obj/item/clothing/suit/chef/red = 2,
		/obj/item/clothing/head/chefhat/red = 2,
		/obj/item/clothing/suit/apron/chef/red = 1,
		)
	. = ..()

/obj/machinery/vending/wardrobe/sec_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/security = 3,
		/obj/item/clothing/head/soft/sec/corporate = 3,
		/obj/item/clothing/under/security/formal = 3,
		/obj/item/clothing/under/security/black = 3,
		/obj/item/clothing/under/security/alternative_black = 3,
		/obj/item/clothing/head/sec_beanie = 3,
		/obj/item/clothing/neck/cloak/sec_poncho = 3,
		/obj/item/clothing/under/rank/security/officer/corporate = 3,
		/obj/item/clothing/under/rank/security/officer/skirt/corporate = 3,
		/obj/item/clothing/under/security/alt_skirt = 3,
		/obj/item/clothing/suit/armor/vest/bomber = 3,
		/obj/item/clothing/suit/armor/vest/coat = 3,
		/obj/item/clothing/suit/armor/vest/caftan = 3,
		/obj/item/clothing/under/security/turtleneck = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/science_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/cowboy/science = 3,
		/obj/item/clothing/suit/jacket/bomber/science = 3,
		/obj/item/clothing/neck/cloak/sci_mantle = 3,
		/obj/item/clothing/under/scientist/utility = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/engi_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/engineering/telecomm = 3,
		/obj/item/clothing/under/engineering/telecomm/skirt = 3,
		/obj/item/clothing/under/engineering/mechanic = 3,
		)
	. = ..()

/obj/machinery/vending/wardrobe/medi_wardrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/medical/paramed_light = 3,
		/obj/item/clothing/under/medical/paramed_light/skirt = 3,
		)
	. = ..()
