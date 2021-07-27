/obj/effect/spawner/lootdrop/contraband
	name = "contraband loot spawner"
	desc = "Pstttthhh! Pass it under the table."

/obj/effect/spawner/lootdrop/contraband/crate
	name = "illegal crate spawner" //USE PROMO CODE "SELLOUT" FOR 20% OFF!
	lootdoubles = FALSE
	loot = list(
		"" = 80,
	/obj/structure/closet/crate/secure/loot = 20,
	)

/obj/effect/spawner/lootdrop/contraband/armory
	name = "armory loot spawner"
	loot = list(
	/obj/item/gun/ballistic/automatic/pistol = 8,
	/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
	/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
	/obj/item/grenade/clusterbuster/teargas = 2,
	/obj/item/grenade/clusterbuster = 2,
	/obj/item/gun/ballistic/automatic/pistol/deagle,
	/obj/item/gun/ballistic/revolver/mateba,
	)

/obj/effect/spawner/lootdrop/contraband/narcotics
	name = "narcotics loot spawner"
	loot = list(
	/obj/item/reagent_containers/syringe/contraband/space_drugs,
	/obj/item/reagent_containers/syringe/contraband/krokodil,
	/obj/item/reagent_containers/syringe/contraband/crank,
	/obj/item/reagent_containers/syringe/contraband/methamphetamine,
	/obj/item/reagent_containers/syringe/contraband/bath_salts,
	/obj/item/reagent_containers/syringe/contraband/fentanyl,
	/obj/item/reagent_containers/syringe/contraband/morphine,
	/obj/item/storage/pill_bottle/happy,
	/obj/item/storage/pill_bottle/lsd,
	/obj/item/storage/pill_bottle/psicodine,
	)

/obj/effect/spawner/lootdrop/contraband/permabrig_weapon
	name = "permabrig weapon spawner"
	loot = list(
	/obj/item/kitchen/knife/shiv = 4,
	/obj/item/kitchen/knife/shiv/carrot = 4,
	/obj/item/tailclub = 2, //want to buy makeshift wooden club sprite
	/obj/item/kitchen/knife = 2,
	/obj/item/assembly/flash/handheld = 1,
	/obj/item/grenade/smokebomb = 1,
	)

/obj/effect/spawner/lootdrop/contraband/permabrig_gear
	name = "permabrig gear spawner"
	loot = list(
	/obj/item/toy/crayon/spraycan,
	/obj/item/crowbar,
	/obj/item/flashlight/seclite,
	/obj/item/restraints/handcuffs/cable/zipties,
	/obj/item/restraints/handcuffs,
	/obj/item/paper/fluff/jobs/prisoner/letter,
	/obj/item/storage/wallet/random,
	/obj/item/pda,
	/obj/item/radio/off,
	)

/obj/effect/spawner/lootdrop/contraband/prison
	name = "prison loot spawner"
	loot = list(
	/obj/effect/spawner/lootdrop/entertainment/cigarette = 20,
	/obj/effect/spawner/lootdrop/contraband/narcotics = 10,
	/obj/effect/spawner/lootdrop/contraband/permabrig_weapon = 10,
	/obj/effect/spawner/lootdrop/contraband/permabrig_gear = 10,
	/obj/effect/spawner/lootdrop/entertainment/cigarette_pack = 5,
	/obj/effect/spawner/lootdrop/entertainment/lighter = 5,
	/obj/effect/spawner/lootdrop/food_or_drink/booze = 5,
	)
