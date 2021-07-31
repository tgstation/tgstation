/obj/effect/spawner/random/contraband
	name = "contraband loot spawner"
	desc = "Pstttthhh! Pass it under the table."

/obj/effect/spawner/random/contraband/narcotics
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

/obj/effect/spawner/random/contraband/permabrig_weapon
	name = "permabrig weapon spawner"
	loot = list(
		/obj/item/kitchen/knife/shiv = 5,
		/obj/item/kitchen/knife/shiv/carrot = 5,
		/obj/item/tailclub = 5, //want to buy makeshift wooden club sprite
		/obj/item/kitchen/knife = 3,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/grenade/smokebomb = 1,
	)

/obj/effect/spawner/random/contraband/permabrig_gear
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

/obj/effect/spawner/random/contraband/prison
	name = "prison loot spawner"
	loot = list(
		/obj/effect/spawner/random/entertainment/cigarette = 20,
		/obj/effect/spawner/random/contraband/narcotics = 10,
		/obj/effect/spawner/random/contraband/permabrig_weapon = 10,
		/obj/effect/spawner/random/contraband/permabrig_gear = 10,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 5,
		/obj/effect/spawner/random/entertainment/lighter = 5,
		/obj/effect/spawner/random/food_or_drink/booze = 5,
	)
