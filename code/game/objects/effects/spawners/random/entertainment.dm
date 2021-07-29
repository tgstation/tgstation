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

/obj/effect/spawner/random/entertainment/coin
	name = "coin spawner"
	loot = list(
		/obj/item/coin/iron = 10,
		/obj/item/coin/silver = 3,
		/obj/item/coin/plasma = 3,
		/obj/item/coin/uranium = 3,
		/obj/item/coin/titanium = 3,
		/obj/item/coin/diamond = 2,
		/obj/item/coin/bananium = 2,
		/obj/item/coin/adamantine = 2,
		/obj/item/coin/mythril = 2,
		/obj/item/coin/plastic = 2,
		/obj/item/coin/runite = 2,
		/obj/item/coin/twoheaded = 1,
		/obj/item/coin/antagtoken = 1,
	)

/obj/effect/spawner/random/entertainment/money
	name = "money spawner"
	lootcount = 3
	fan_out_items = TRUE
	loot = list(
		/obj/item/stack/spacecash/c1 = 10,
		/obj/item/stack/spacecash/c10 = 5,
		/obj/item/stack/spacecash/c20 = 3,
		/obj/item/stack/spacecash/c50 = 2,
		/obj/item/stack/spacecash/c100 = 1,
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
