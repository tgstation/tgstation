/obj/effect/spawner/random/entertainment
	name = "entertainment loot spawner"
	desc = "It's time to paaaaaarty!"

/obj/effect/spawner/random/entertainment/arcade
	name = "spawn random arcade machine"
	desc = "Automagically transforms into a random arcade machine. If you see this while in a shift, please create a bug report."
	icon_state = "arcade"
	loot = list(
		/obj/machinery/computer/arcade/orion_trail = 49,
		/obj/machinery/computer/arcade/battle = 49,
		/obj/machinery/computer/arcade/amputation = 2,
	)

/obj/effect/spawner/random/entertainment/musical_instrument
	name = "musical instrument spawner"
	icon_state = "eguitar"
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
	icon_state = "dice"
	loot = list(
		/obj/item/gun/ballistic/revolver/russian = 5,
		/obj/item/clothing/head/costume/ushanka = 3,
		/obj/effect/spawner/random/entertainment/coin = 3,
		/obj/effect/spawner/random/entertainment/money = 3,
		/obj/item/dice/d6 = 3,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka = 1,
	)

/obj/effect/spawner/random/entertainment/coin
	name = "coin spawner"
	icon_state = "coin"
	loot = list(
		/obj/item/coin/iron = 5,
		/obj/item/coin/plastic = 5,
		/obj/item/coin/silver = 4,
		/obj/item/coin/plasma = 4,
		/obj/item/coin/uranium = 3,
		/obj/item/coin/titanium = 3,
		/obj/item/coin/diamond = 2,
		/obj/item/coin/bananium = 2,
		/obj/item/coin/adamantine = 2,
		/obj/item/coin/runite = 2,
		/obj/item/food/chococoin = 2,
		/obj/item/coin/twoheaded = 1,
		/obj/item/coin/antagtoken = 1,
	)

/obj/effect/spawner/random/entertainment/money_small
	name = "small money spawner"
	icon_state = "cash"
	spawn_loot_count = 3
	spawn_loot_split = TRUE
	loot = list(
		/obj/item/stack/spacecash/c1 = 5,
		/obj/item/stack/spacecash/c10 = 3,
		/obj/item/stack/spacecash/c20 = 2,
	)

/obj/effect/spawner/random/entertainment/money
	name = "money spawner"
	icon_state = "cash"
	spawn_loot_count = 3
	spawn_loot_split = TRUE
	loot = list(
		/obj/item/stack/spacecash/c1 = 10,
		/obj/item/stack/spacecash/c10 = 5,
		/obj/item/stack/spacecash/c20 = 3,
		/obj/item/stack/spacecash/c50 = 2,
		/obj/item/stack/spacecash/c100 = 1,
	)

/obj/effect/spawner/random/entertainment/money_medium
	name = "money spawner"
	icon_state = "cash"
	loot = list(
		/obj/item/stack/spacecash/c100 = 25,
		/obj/item/stack/spacecash/c200 = 15,
		/obj/item/stack/spacecash/c50 = 10,
		/obj/item/stack/spacecash/c500 = 5,
		/obj/item/stack/spacecash/c1000 = 1,
	)

/obj/effect/spawner/random/entertainment/money_large
	name = "large money spawner"
	icon_state = "cash"
	spawn_loot_count = 5
	spawn_loot_split = TRUE
	loot = list(
		/obj/item/stack/spacecash/c1 = 100,
		/obj/item/stack/spacecash/c10 = 80,
		/obj/item/stack/spacecash/c20 = 60,
		/obj/item/stack/spacecash/c50 = 40,
		/obj/item/stack/spacecash/c100 = 30,
		/obj/item/stack/spacecash/c200 = 20,
		/obj/item/stack/spacecash/c500 = 10,
		/obj/item/stack/spacecash/c1000 = 5,
		/obj/item/stack/spacecash/c10000 = 1,
	)

/obj/effect/spawner/random/entertainment/drugs
	name = "recreational drugs spawner"
	icon_state = "pill"
	loot = list(
		/obj/item/reagent_containers/cup/glass/bottle/hooch = 50,
		/obj/item/cigarette/rollie/cannabis = 15,
		/obj/item/reagent_containers/syringe = 15,
		/obj/item/cigbutt/roach = 15,
		/obj/item/cigarette/rollie/mindbreaker = 5,
	)

/obj/effect/spawner/random/entertainment/dice
	name = "dice spawner"
	icon_state = "dice_bag"
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
	icon_state = "cigarettes"
	loot = list(
		/obj/item/storage/fancy/cigarettes = 3,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_greytide = 1,
	)

/obj/effect/spawner/random/entertainment/cigarette
	name = "cigarette spawner"
	icon_state = "cigarettes"
	loot = list(
		/obj/item/cigarette/space_cigarette = 3,
		/obj/item/cigarette/rollie/cannabis = 3,
		/obj/item/cigarette/rollie/nicotine = 3,
		/obj/item/cigarette/dromedary = 2,
		/obj/item/cigarette/uplift = 2,
		/obj/item/cigarette/robust = 2,
		/obj/item/cigarette/carp = 1,
		/obj/item/cigarette/robustgold = 1,
		/obj/item/cigarette/greytide = 3,
	)

/obj/effect/spawner/random/entertainment/cigar
	name = "cigar spawner"
	icon_state = "cigarettes"
	loot = list(
		/obj/item/cigarette/cigar = 3,
		/obj/item/cigarette/cigar/havana = 2,
		/obj/item/cigarette/cigar/cohiba = 1,
	)

/obj/effect/spawner/random/entertainment/wallet_lighter
	name = "lighter wallet spawner"
	icon_state = "lighter"
	loot = list( // these fit inside a wallet
		/obj/item/match = 10,
		/obj/item/lighter/greyscale = 10,
		/obj/item/lighter = 1,
	)

/obj/effect/spawner/random/entertainment/lighter
	name = "lighter spawner"
	icon_state = "lighter"
	loot = list(
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/greyscale = 10,
		/obj/item/lighter = 1,
	)

/obj/effect/spawner/random/entertainment/wallet_storage
	name = "wallet contents spawner"
	icon_state = "wallet"
	spawn_loot_count = 1
	loot = list(	// random photos would go here. IF I HAD ONE. :'(
		/obj/item/lipstick/random,
		/obj/item/reagent_containers/applicator/pill/maintenance,
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

/obj/effect/spawner/random/entertainment/deck
	name = "deck spawner"
	icon_state = "deck"
	loot = list(
		/obj/item/toy/cards/deck = 5,
		/obj/item/toy/cards/deck/kotahi = 2,
		/obj/item/toy/cards/deck/wizoff = 2,
		/obj/item/toy/cards/deck/tarot = 1,
	)

/obj/effect/spawner/random/entertainment/toy_figure
	name = "toy figure spawner"
	icon_state = "toy"
	loot_subtype_path = /obj/item/toy/figure
	loot = list()

/obj/effect/spawner/random/entertainment/toy
	name = "toy spawner"
	icon_state = "toy"
	loot = list()

/obj/effect/spawner/random/entertainment/toy/Initialize(mapload)
	loot += GLOB.arcade_prize_pool
	return ..()

/obj/effect/spawner/random/entertainment/plushie
	name = "plushie spawner"
	icon_state = "plushie"
	loot = list( // the plushies that aren't of things trying to kill you
		/obj/item/toy/plush/carpplushie, // well, maybe they can be something that tries to kill you a little bit
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/lizard_plushie,
		/obj/item/toy/plush/snakeplushie,
		/obj/item/toy/plush/plasmamanplushie,
		/obj/item/toy/plush/human,
		/obj/item/toy/plush/beeplushie,
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/pkplush,
		/obj/item/toy/plush/horse,
		/obj/item/toy/plush/monkey,
	)

/obj/effect/spawner/random/entertainment/plushie_delux
	name = "plushie delux spawner"
	icon_state = "plushie"
	loot = list(
		// common plushies
		/obj/item/toy/plush/slimeplushie = 5,
		/obj/item/toy/plush/lizard_plushie = 5,
		/obj/item/toy/plush/snakeplushie = 5,
		/obj/item/toy/plush/plasmamanplushie = 5,
		/obj/item/toy/plush/beeplushie = 5,
		/obj/item/toy/plush/moth = 5,
		/obj/item/toy/plush/pkplush = 5,
		/obj/item/toy/plush/human = 5,
		/obj/item/toy/plush/horse = 5,
		// rare plushies
		/obj/item/toy/plush/carpplushie = 3,
		/obj/item/toy/plush/lizard_plushie/green = 3,
		/obj/item/toy/plush/lizard_plushie/space/green = 3,
		/obj/item/toy/plush/rouny = 3,
		/obj/item/toy/plush/abductor = 3,
		/obj/item/toy/plush/abductor/agent = 3,
		/obj/item/toy/plush/shark = 3,
		/obj/item/toy/plush/unicorn = 3,
		/obj/item/toy/plush/monkey = 3,
		// super rare plushies
		/obj/item/toy/plush/bubbleplush = 2,
		/obj/item/toy/plush/ratplush = 2,
		/obj/item/toy/plush/narplush = 2,
	)

/obj/effect/spawner/random/entertainment/colorful_grenades
	name = "colorful/glitter grenades spawner"
	loot = list(
		/obj/item/grenade/chem_grenade/glitter/pink,
		/obj/item/grenade/chem_grenade/glitter/blue,
		/obj/item/grenade/chem_grenade/glitter,
		/obj/item/grenade/chem_grenade/colorful
	)
