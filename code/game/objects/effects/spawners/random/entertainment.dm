/obj/effect/spawner/random/entertainment
	name = "entertainment loot spawner"
	desc = "It's time to paaaaaarty!"

/obj/effect/spawner/random/entertainment/gambling
	name = "gambling valuables spawner"
	loot = list(
		/obj/item/gun/ballistic/revolver/russian = 5,
		/obj/item/clothing/head/ushanka = 3,
		/obj/effect/spawner/random/entertainment/coin = 3,
		/obj/effect/spawner/random/entertainment/money = 3,
		/obj/item/dice/d6 = 3,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka = 1,
	)

/obj/effect/spawner/random/entertainment/drugs
	name = "recreational drugs spawner"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/hooch = 50,
		/obj/item/clothing/mask/cigarette/rollie/cannabis = 15,
		/obj/item/reagent_containers/syringe = 15,
		/obj/item/cigbutt/roach = 15,
		/obj/item/clothing/mask/cigarette/rollie/mindbreaker = 5,
	)
