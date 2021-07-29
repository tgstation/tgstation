/obj/effect/spawner/random/entertainment
	name = "entertainment loot spawner"
	desc = "It's time to paaaaaarty!"

/obj/effect/spawner/random/entertainment/musical_instrument
	name = "musical instrument spawner"
	// enable the music icons later after PR gets merged - 7/29/2021
	//icon = 'icons/obj/musician.dmi'
	//icon_state = "random_instrument"
	loot = list(
		/obj/item/instrument/violin = 5,
		/obj/item/instrument/banjo = 5,
		/obj/item/instrument/guitar = 5,
		/obj/item/instrument/eguitar = 5,
		/obj/item/instrument/glockenspiel = 5,
		/obj/item/instrument/accordion = 5,
		/obj/item/instrument/trumpet = 5,
		/obj/item/instrument/saxophone = 5,
		/obj/item/instrument/trombone = 5,
		/obj/item/instrument/recorder = 5,
		/obj/item/instrument/harmonica = 5,
		/obj/item/instrument/bikehorn = 2,
		/obj/item/instrument/violin/golden = 2,
		/obj/item/instrument/musicalmoth = 1,
	)

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

/obj/effect/spawner/random/entertainment/dice
	name = "dice spawner"
	loot = list(
		/obj/item/dice/d4,
		/obj/item/dice/d6,
		/obj/item/dice/d8,
		/obj/item/dice/d10,
		/obj/item/dice/d12,
		/obj/item/dice/d20,
	)

/obj/effect/spawner/random/entertainment/cigarette_pack
	name = "cigarette pack spawner"
	loot = list(
		/obj/item/storage/fancy/cigarettes = 3,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 1,
	)

/obj/effect/spawner/random/entertainment/cigarette
	name = "cigarette spawner"
	loot = list(
		/obj/item/clothing/mask/cigarette/space_cigarette = 3,
		/obj/item/clothing/mask/cigarette/rollie/cannabis = 3,
		/obj/item/clothing/mask/cigarette/rollie/nicotine = 3,
		/obj/item/clothing/mask/cigarette/dromedary = 2,
		/obj/item/clothing/mask/cigarette/uplift = 2,
		/obj/item/clothing/mask/cigarette/robust = 2,
		/obj/item/clothing/mask/cigarette/carp = 1,
		/obj/item/clothing/mask/cigarette/robustgold = 1,
	)

/obj/effect/spawner/random/entertainment/cigar
	name = "cigar spawner"
	loot = list(
		/obj/item/clothing/mask/cigarette/cigar = 3,
		/obj/item/clothing/mask/cigarette/cigar/havana = 2,
		/obj/item/clothing/mask/cigarette/cigar/cohiba = 1,
	)

/obj/effect/spawner/random/entertainment/wallet_lighter
	name = "lighter wallet spawner"
	loot = list( // these fit inside a wallet
		/obj/item/match = 10,
		/obj/item/lighter/greyscale = 10,
		/obj/item/lighter = 1,
	)

/obj/effect/spawner/random/entertainment/lighter
	name = "lighter spawner"
	loot = list(
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/greyscale = 10,
		/obj/item/lighter = 1,
	)

/obj/effect/spawner/random/entertainment/wallet_storage
	name = "wallet contents spawner"
	lootcount = 1
	loot = list(	// random photos would go here. IF I HAD ONE. :'(
		/obj/item/lipstick/random,
		/obj/item/reagent_containers/pill/maintenance,
		/obj/effect/spawner/random/food_or_drink/seed,
		/obj/effect/spawner/random/medical/minor_healing,
		/obj/effect/spawner/random/medical/injector,
		/obj/effect/spawner/random/entertainment/coin,
		/obj/effect/spawner/random/entertainment/dice,
		/obj/effect/spawner/random/entertainment/cigarette,
		/obj/effect/spawner/random/entertainment/wallet_lighter,
		/obj/effect/spawner/random/bureaucracy/paper,
		/obj/effect/spawner/random/bureaucracy/crayon,
		/obj/effect/spawner/random/bureaucracy/pen,
		/obj/effect/spawner/random/bureaucracy/stamp,
		/obj/effect/spawner/random/techstorage/data_disk,
	)
