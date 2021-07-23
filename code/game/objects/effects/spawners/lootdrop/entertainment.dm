/obj/effect/spawner/lootdrop/entertainment
	name = "entertainment loot spawner"
	desc = "It's time to paaaaaarty!"

/obj/effect/spawner/lootdrop/entertainment/musical_instrument
	name = "musical instrument spawner"
	icon = 'icons/obj/musician.dmi'
	icon_state = "random_instrument"
	loot = list(
		/obj/item/instrument/violin = 3,
		/obj/item/instrument/banjo = 3,
		/obj/item/instrument/guitar = 3,
		/obj/item/instrument/eguitar = 3,
		/obj/item/instrument/glockenspiel = 3,
		/obj/item/instrument/accordion = 3,
		/obj/item/instrument/trumpet = 3,
		/obj/item/instrument/saxophone = 3,
		/obj/item/instrument/trombone = 3,
		/obj/item/instrument/recorder = 3,
		/obj/item/instrument/harmonica = 3,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/instrument/violin/golden = 1,
	)

/obj/effect/spawner/lootdrop/entertainment/gambling
	name = "gambling valuables spawner"
	loot = list(
		/obj/item/gun/ballistic/revolver/russian = 5,
		/obj/item/clothing/head/ushanka = 3,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/coin/gold,
		/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka,
	)

/obj/effect/spawner/lootdrop/entertainment/drugs
	name = "recreational drugs spawner"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/hooch = 50,
		/obj/item/clothing/mask/cigarette/rollie/cannabis = 15,
		/obj/item/reagent_containers/syringe = 15,
		/obj/item/cigbutt/roach = 15,
		/obj/item/clothing/mask/cigarette/rollie/mindbreaker = 5,
	)

/obj/effect/spawner/lootdrop/entertainment/wallet_loot
	name = "wallet contents spawner"
	lootcount = 1
	loot = list(
		list(
			// Same weights as contraband loot cigarettes (with no packs)
			/obj/item/clothing/mask/cigarette/space_cigarette = 4,
			/obj/item/clothing/mask/cigarette/robust = 2,
			/obj/item/clothing/mask/cigarette/carp = 3,
			/obj/item/clothing/mask/cigarette/uplift = 2,
			/obj/item/clothing/mask/cigarette/dromedary = 3,
			/obj/item/clothing/mask/cigarette/robustgold = 1,
			/obj/item/clothing/mask/cigarette/rollie/cannabis = 4,
		) = 1,
		list(
			/obj/item/flashlight/pen = 90,
			/obj/item/flashlight/pen/paramedic = 10,
		) = 1,
		list( // The same seeds in the Supply "Seeds Crate"
			/obj/item/seeds/chili = 1,
			/obj/item/seeds/cotton = 1,
			/obj/item/seeds/berry = 1,
			/obj/item/seeds/corn = 1,
			/obj/item/seeds/eggplant = 1,
			/obj/item/seeds/tomato = 1,
			/obj/item/seeds/soya = 1,
			/obj/item/seeds/wheat = 1,
			/obj/item/seeds/wheat/rice = 1,
			/obj/item/seeds/carrot = 1,
			/obj/item/seeds/sunflower = 1,
			/obj/item/seeds/rose = 1,
			/obj/item/seeds/chanter = 1,
			/obj/item/seeds/potato = 1,
			/obj/item/seeds/sugarcane = 1,
		) = 1,
		list(
			/obj/item/stack/medical/suture = 1,
			/obj/item/stack/medical/mesh = 1,
			/obj/item/stack/medical/gauze = 1,
		) = 1,
		list(
			/obj/item/toy/crayon/red = 1,
			/obj/item/toy/crayon/orange = 1,
			/obj/item/toy/crayon/yellow = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/toy/crayon/blue = 1,
			/obj/item/toy/crayon/purple = 1,
			/obj/item/toy/crayon/black = 1,
			/obj/item/toy/crayon/rainbow = 1,
		) = 1,
		list(
			/obj/item/coin/iron = 1,
			/obj/item/coin/silver = 1,
			/obj/item/coin/diamond = 1,
			/obj/item/coin/plasma = 1,
			/obj/item/coin/uranium = 1,
			/obj/item/coin/titanium = 1,
			/obj/item/coin/bananium = 1,
			/obj/item/coin/adamantine = 1,
			/obj/item/coin/mythril = 1,
			/obj/item/coin/plastic = 1,
			/obj/item/coin/runite = 1,
			/obj/item/coin/twoheaded = 1,
			/obj/item/coin/antagtoken = 1,
		) = 1,
		list(
			/obj/item/dice/d4 = 1,
			/obj/item/dice/d6 = 1,
			/obj/item/dice/d8 = 1,
			/obj/item/dice/d10 = 1,
			/obj/item/dice/d12 = 1,
			/obj/item/dice/d20 = 1,
		) = 1,
		list(
			/obj/item/disk/data = 99,
			/obj/item/disk/nuclear/fake/obvious = 1,
		) = 1,
		/obj/item/implanter = 1,
		list(
			/obj/item/lighter = 25,
			/obj/item/lighter/greyscale = 75,
		) = 1,
		/obj/item/lipstick/random = 1,
		/obj/item/match = 1,
		/obj/item/paper/pamphlet/gateway = 1,
		list(
			/obj/item/pen = 1,
			/obj/item/pen/blue = 1,
			/obj/item/pen/red = 1,
			/obj/item/pen/fourcolor = 1,
			/obj/item/pen/fountain = 1,
		) = 1,
		// random photos would go here. IF I HAD ONE. :'(
		/obj/item/reagent_containers/dropper = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/pill/maintenance = 1,
		/obj/item/screwdriver = 1,
		list(
			/obj/item/stamp = 50,
			/obj/item/stamp/denied = 50,
		) = 1,
	)
