/obj/effect/spawner/random/contraband
	name = "contraband loot spawner"
	desc = "Pstttthhh! Pass it under the table."
	icon_state = "prisoner"
	loot = list(
		/obj/item/poster/random_contraband = 40,
		/obj/item/food/grown/cannabis = 40,
		/obj/item/clothing/mask/gas/syndicate = 30,
		/obj/item/clothing/neck/necklace/dope = 30,
		/obj/item/food/grown/cannabis/rainbow = 20,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe = 20,
		/obj/item/toy/cards/deck/syndicate = 20,
		/obj/item/clothing/under/syndicate/tacticool = 20,
		/obj/item/food/grown/cannabis/white = 10,
		/obj/item/storage/box/fireworks/dangerous = 10,
		/obj/item/storage/pill_bottle/zoom = 10,
		/obj/item/storage/pill_bottle/happy = 10,
		/obj/item/storage/pill_bottle/lsd = 10,
		/obj/item/storage/pill_bottle/aranesp = 10,
		/obj/item/storage/pill_bottle/stimulant = 10,
		/obj/item/food/drug/saturnx = 5,
		/obj/item/food/drug/meth_crystal = 5,
		/obj/item/food/drug/opium = 5,
		/obj/item/reagent_containers/cup/blastoff_ampoule = 5,
		/obj/item/food/drug/moon_rock = 5,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = 10,
		/obj/item/storage/box/donkpockets = 10,
		/obj/effect/spawner/random/contraband/plus = 10,
		/obj/item/reagent_containers/applicator/pill/maintenance = 5,
		/obj/item/survivalcapsule/fishing = 5,
	)


/obj/effect/spawner/random/contraband/make_item(spawn_loc, type_path_to_make)
	var/obj/item/made = ..()
	ADD_TRAIT(made, TRAIT_CONTRABAND, INNATE_TRAIT)
	return made

/obj/effect/spawner/random/contraband/plus
	name = "contraband loot spawner plus"
	desc = "Where'd ya find this?"
	loot = list(
		/obj/item/clothing/under/syndicate = 20,
		/obj/item/reagent_containers/cup/bottle/thermite = 20,
		/obj/item/restraints/legcuffs/beartrap = 10,
		/obj/item/food/drug/saturnx = 5,
		/obj/item/food/drug/meth_crystal = 5,
		/obj/item/food/drug/opium = 5,
		/obj/item/reagent_containers/cup/blastoff_ampoule = 5,
		/obj/item/food/drug/moon_rock = 5,
		/obj/item/grenade/empgrenade = 5,
		/obj/item/survivalcapsule/fishing/hacked = 1,
		/obj/effect/spawner/random/contraband/armory = 1,
	)

/obj/effect/spawner/random/contraband/armory
	name = "armory loot spawner"
	icon_state = "pistol"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol/contraband = 80,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 50,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 30,
		/obj/item/grenade/clusterbuster/teargas = 20,
		/obj/item/grenade/clusterbuster = 20,
		/obj/item/gun/ballistic/automatic/pistol/deagle/contraband,
		/obj/item/gun/ballistic/revolver/mateba = 9,
		/obj/item/gun/ballistic/revolver/reverse/mateba = 1,
	)

/obj/effect/spawner/random/contraband/narcotics
	name = "narcotics loot spawner"
	icon_state = "pill"
	loot = list(
		/obj/item/reagent_containers/syringe/contraband/space_drugs,
		/obj/item/reagent_containers/syringe/contraband/methamphetamine,
		/obj/item/reagent_containers/syringe/contraband/bath_salts,
		/obj/item/reagent_containers/syringe/contraband/fentanyl,
		/obj/item/reagent_containers/syringe/contraband/morphine,
		/obj/item/food/drug/saturnx,
		/obj/item/reagent_containers/cup/blastoff_ampoule,
		/obj/item/food/drug/moon_rock,
		/obj/item/food/drug/meth_crystal,
		/obj/item/food/drug/opium,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/psicodine,
		/obj/item/storage/box/flat/fentanylpatches,
	)

/obj/effect/spawner/random/contraband/permabrig_weapon
	name = "permabrig weapon spawner"
	icon_state = "shiv"
	loot = list(
		/obj/item/knife/shiv = 5,
		/obj/item/knife/shiv/carrot = 5,
		/obj/item/tailclub = 5, //want to buy makeshift wooden club sprite
		/obj/item/knife = 3,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/grenade/smokebomb = 1,
	)

/obj/effect/spawner/random/contraband/permabrig_gear
	name = "permabrig gear spawner"
	icon_state = "handcuffs"
	loot = list(
		/obj/item/toy/crayon/spraycan,
		/obj/item/crowbar,
		/obj/item/flashlight/seclite,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/restraints/handcuffs,
		/obj/item/paper/fluff/jobs/prisoner/letter,
		/obj/item/storage/wallet/random,
		/obj/item/modular_computer/pda,
		/obj/item/radio/off,
	)

/obj/effect/spawner/random/contraband/prison
	name = "prison loot spawner"
	icon_state = "prisoner_shoes"
	loot = list(
		/obj/effect/spawner/random/entertainment/cigarette = 20,
		/obj/effect/spawner/random/contraband/narcotics = 10,
		/obj/effect/spawner/random/contraband/permabrig_weapon = 10,
		/obj/effect/spawner/random/contraband/permabrig_gear = 10,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 5,
		/obj/effect/spawner/random/entertainment/lighter = 5,
		/obj/effect/spawner/random/food_or_drink/booze = 5,
	)

/obj/effect/spawner/random/contraband/cannabis
	name = "Random Cannabis Spawner" //blasphemously overpowered, use extremely sparingly (if at all)
	icon_state = "cannabis"
	loot = list(
		/obj/item/food/grown/cannabis = 25,
		/obj/item/food/grown/cannabis/white = 25,
		/obj/item/food/grown/cannabis/death = 24,
		/obj/item/food/grown/cannabis/rainbow = 25,
		/obj/item/food/grown/cannabis/ultimate = 1, //very rare on purpose
	)

/obj/effect/spawner/random/contraband/cannabis/lizardsgas
	loot = list(
		/obj/item/food/grown/cannabis = 24,
		/obj/item/food/grown/cannabis/white = 15,
		/obj/item/food/grown/cannabis/death = 45, //i mean, it's been there for a while?
		/obj/item/food/grown/cannabis/rainbow = 15,
		/obj/item/food/grown/cannabis/ultimate = 1,
	)

/obj/effect/spawner/random/contraband/landmine
	name = "landmine spawner"
	loot = list(
		/obj/effect/mine/explosive/light = 10,
		/obj/effect/mine/explosive/flame = 10,
		/obj/effect/mine/explosive/flash = 15,
		/obj/effect/mine/explosive = 2,
		/obj/item/restraints/legcuffs/beartrap/prearmed = 5, //not really a landmine, but still a good threat
		/obj/effect/mine/shrapnel = 5,
	)

/obj/effect/spawner/random/contraband/qm_rocket
	name = "QMs dud rocket spawner"
	loot = list(
		/obj/item/ammo_casing/rocket/reverse = 85,
		/obj/item/ammo_casing/rocket = 15,
	)

/obj/effect/spawner/random/contraband/grenades
	name = "grenades spawner"
	loot = list(
		/obj/item/grenade/chem_grenade/metalfoam,
		/obj/item/grenade/chem_grenade/cleaner,
		// /obj/effect/spawner/random/entertainment/colorful_grenades, /// BANDASATION REMOVAL - Remove Fun
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/grenade/spawnergrenade/syndiesoap,
		/obj/effect/spawner/random/contraband/grenades/dangerous,
	)

/obj/effect/spawner/random/contraband/grenades/dangerous
	name = "dangerous grenades spawner"
	loot = list(
		/obj/item/grenade/flashbang = 3,
		/obj/item/grenade/chem_grenade/teargas = 2,
		/obj/item/grenade/iedcasing/spawned = 2,
		/obj/item/grenade/empgrenade = 2,
		/obj/item/grenade/antigravity = 2,
		/obj/effect/spawner/random/contraband/grenades/cluster = 1,
		/obj/effect/spawner/random/contraband/grenades/lethal = 1,
	)

/obj/effect/spawner/random/contraband/grenades/cluster
	name = "clusterbusters spawner"
	loot = list(
		/obj/item/grenade/clusterbuster/smoke = 4,
		/obj/item/grenade/clusterbuster/metalfoam = 4,
		/obj/item/grenade/clusterbuster/cleaner = 4,
		/obj/item/grenade/clusterbuster = 3,
		/obj/item/grenade/clusterbuster/teargas = 3,
		/obj/item/grenade/clusterbuster/antiweed = 3,
		/obj/item/grenade/clusterbuster/soap = 2,
		/obj/item/grenade/clusterbuster/emp = 1,
		/obj/item/grenade/clusterbuster/spawner_spesscarp = 1,
		/obj/item/grenade/clusterbuster/facid = 1,
		/obj/item/grenade/clusterbuster/inferno = 1,
		/obj/item/grenade/clusterbuster/clf3 = 1,
	)

/obj/effect/spawner/random/contraband/grenades/lethal
	name = "lethal grenades spawner"
	loot = list(
		/obj/item/grenade/chem_grenade/incendiary = 3,
		/obj/item/grenade/chem_grenade/facid = 3,
		/obj/item/grenade/chem_grenade/ez_clean = 3,
		/obj/item/grenade/chem_grenade/clf3 = 2,
		/obj/item/grenade/gluon = 2,
		/obj/item/grenade/chem_grenade/holy = 2,
		/obj/item/grenade/spawnergrenade/spesscarp = 1,
		/obj/item/grenade/spawnergrenade/cat = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/chem_grenade/bioterrorfoam = 1,
	)
