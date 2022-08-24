/obj/effect/spawner/random/contraband
	name = "contraband loot spawner"
	desc = "Pstttthhh! Pass it under the table."
	icon_state = "prisoner"

/obj/effect/spawner/random/contraband/armory
	name = "armory loot spawner"
	icon_state = "pistol"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
		/obj/item/grenade/clusterbuster/teargas = 2,
		/obj/item/grenade/clusterbuster = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/revolver/mateba,
	)

/obj/effect/spawner/random/contraband/narcotics
	name = "narcotics loot spawner"
	icon_state = "pill"
	loot = list(
		/obj/item/reagent_containers/syringe/contraband/space_drugs,
		/obj/item/reagent_containers/syringe/contraband/krokodil,
		/obj/item/reagent_containers/syringe/contraband/methamphetamine,
		/obj/item/reagent_containers/syringe/contraband/bath_salts,
		/obj/item/reagent_containers/syringe/contraband/fentanyl,
		/obj/item/reagent_containers/syringe/contraband/morphine,
		/obj/item/reagent_containers/syringe/contraband/saturnx,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/psicodine,
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
		/obj/item/modular_computer/tablet/pda,
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
