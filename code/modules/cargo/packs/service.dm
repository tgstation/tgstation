/datum/supply_pack/service
	group = "Service"

/datum/supply_pack/service/cargo_supples
	name = "Cargo Supplies Crate"
	desc = "Sold everything that wasn't bolted down? You can get right \
		back to work with this crate containing stamps, an export scanner, \
		destination tagger, hand labeler and some package wrapping."
	cost = CARGO_CRATE_VALUE * 1.75
	contains = list(/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/universal_scanner,
					/obj/item/dest_tagger,
					/obj/item/hand_labeler,
					/obj/item/stack/package_wrap,
				)
	crate_name = "cargo supplies crate"

/datum/supply_pack/service/noslipfloor
	name = "High-traction Floor Tiles"
	desc = "Make slipping a thing of the past with thirty industrial-grade anti-slip floor tiles!"
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_JANITOR
	contains = list(/obj/item/stack/tile/noslip/thirty)
	crate_name = "high-traction floor tiles crate"

/datum/supply_pack/service/janitor
	name = "Janitorial Supplies Crate"
	desc = "Fight back against dirt and grime with Nanotrasen's Janitorial Essentials™! \
		Contains three buckets, caution signs, and cleaner grenades. Also has a single mop, \
		broom, spray cleaner, rag, and trash bag."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_JANITOR
	contains = list(/obj/item/reagent_containers/cup/bucket = 3,
					/obj/item/mop,
					/obj/item/pushbroom,
					/obj/item/clothing/suit/caution = 3,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/cup/rag,
					/obj/item/grenade/chem_grenade/cleaner = 3,
				)
	crate_name = "janitorial supplies crate"

/datum/supply_pack/service/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	desc = "The keystone to any successful janitor. As long as you have feet, this pair \
		of galoshes will keep them firmly planted on the ground. Also contains a janitorial cart."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/structure/mop_bucket/janitorialcart,
					/obj/item/clothing/shoes/galoshes,
				)
	crate_name = "janitorial cart crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/janitor/janitank
	name = "Janitor Backpack Crate"
	desc = "Call forth divine judgement upon dirt and grime with this high capacity janitor \
		backpack. Contains 500 units of station-cleansing cleaner."
	cost = CARGO_CRATE_VALUE * 2
	access = ACCESS_JANITOR
	contains = list(/obj/item/watertank/janitor)
	crate_name = "janitor backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/mule
	name = "MULEbot Crate"
	desc = "Pink-haired Quartermaster not doing her job? Replace her with this tireless worker, today! \
		Contains one MULEbot."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_name = "\improper MULEbot Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/party
	name = "Party Equipment"
	desc = "Celebrate both life and death on the station with Nanotrasen's Party Essentials™! \
		Contains seven colored glowsticks, six beers, six sodas, two ales, and a bottle of patron, \
		goldschlager, and shaker!"
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/cup/glass/shaker,
					/obj/item/reagent_containers/cup/glass/bottle/patron,
					/obj/item/reagent_containers/cup/glass/bottle/goldschlager,
					/obj/item/reagent_containers/cup/glass/bottle/ale = 2,
					/obj/item/storage/cans/sixbeer,
					/obj/item/storage/cans/sixsoda,
					/obj/item/flashlight/glowstick,
					/obj/item/flashlight/glowstick/red,
					/obj/item/flashlight/glowstick/blue,
					/obj/item/flashlight/glowstick/cyan,
					/obj/item/flashlight/glowstick/orange,
					/obj/item/flashlight/glowstick/yellow,
					/obj/item/flashlight/glowstick/pink,
				)
	crate_name = "party equipment crate"

/datum/supply_pack/service/carpet
	name = "Premium Carpet Crate"
	desc = "Iron floor tiles getting on your nerves? These stacks of extra soft carpet \
		will tie any room together. Contains 100 tiles each of regular and black carpet."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/tile/carpet/fifty = 2,
					/obj/item/stack/tile/carpet/black/fifty = 2)
	crate_name = "premium carpet crate"

/datum/supply_pack/service/carpet_exotic
	name = "Exotic Carpet Crate"
	desc = "Exotic carpets straight from Space Russia, for all your decorating needs. \
		Contains 100 tiles each of 8 different flooring patterns."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/stack/tile/carpet/blue/fifty = 2,
					/obj/item/stack/tile/carpet/cyan/fifty = 2,
					/obj/item/stack/tile/carpet/green/fifty = 2,
					/obj/item/stack/tile/carpet/orange/fifty = 2,
					/obj/item/stack/tile/carpet/purple/fifty = 2,
					/obj/item/stack/tile/carpet/red/fifty = 2,
					/obj/item/stack/tile/carpet/royalblue/fifty = 2,
					/obj/item/stack/tile/carpet/royalblack/fifty = 2,
				)
	crate_name = "exotic carpet crate"

/datum/supply_pack/service/carpet_neon
	name = "Simple Neon Carpet Crate"
	desc = "Simple rubbery mats with phosphorescent lining. Contains 120 tiles \
		each of 13 color variants. Limited edition release."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/stack/tile/carpet/neon/simple/white/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/black/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/red/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/orange/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/yellow/sixty =2,
					/obj/item/stack/tile/carpet/neon/simple/lime/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/green/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/teal/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/cyan/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/blue/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/purple/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/violet/sixty = 2,
					/obj/item/stack/tile/carpet/neon/simple/pink/sixty = 2,
				)
	crate_name = "neon carpet crate"

/datum/supply_pack/service/lightbulbs
	name = "Replacement Lights"
	desc = "May the light of Aether shine upon this station! Or at least, the light of \
		forty-two light tubes and twenty one light bulbs."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/lights/mixed = 3)
	crate_name = "replacement lights"

/datum/supply_pack/service/minerkit
	name = "Shaft Miner Starter Kit"
	desc = "All the miners died too fast? Assistant wants to get a taste of life off-station? \
		Either way, this kit is the best way to turn a regular crewman into an ore-producing, \
		monster-slaying machine. Contains meson goggles, a pickaxe, advanced mining scanner, \
		cargo headset, ore bag, gasmask, an explorer suit and a miner ID upgrade."
	cost = CARGO_CRATE_VALUE * 4
	access = ACCESS_QM
	access_view = ACCESS_MINING_STATION
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
	crate_name = "shaft miner starter kit"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/survivalknives
	name = "Survival Knives Crate"
	desc = "Contains three sharpened survival knives. Each knife guaranteed to fit snugly \
		inside any Nanotrasen-standard boot."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/knife/combat/survival = 3)
	crate_name = "survival knife crate"

/datum/supply_pack/service/wedding
	name = "Wedding Crate"
	desc = "Everything you need to host a wedding! Now you just need an officiant. \
		Contains a wedding dress, tuxedo, cummerbund, wedding veil, three bouquets, \
		and a bottle of champagne."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/clothing/under/dress/wedding_dress,
					/obj/item/clothing/under/suit/tuxedo,
					/obj/item/storage/belt/fannypack/cummerbund,
					/obj/item/clothing/head/costume/weddingveil,
					/obj/item/bouquet,
					/obj/item/bouquet/sunflower,
					/obj/item/bouquet/poppy,
					/obj/item/reagent_containers/cup/glass/bottle/champagne,
				)
	crate_name = "wedding crate"

/// Box of 7 grey IDs.
/datum/supply_pack/service/greyidbox
	name = "Grey ID Card Multipack Cate"
	desc = "A convenient crate containing a box of seven cheap ID cards in a handy wallet-sized form factor. \
		Cards come in every colour you can imagne, as long as it's grey."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/box/ids)
	crate_name = "basic id card crate"

/// Single silver ID.
/datum/supply_pack/service/silverid
	name = "Silver ID Card Crate"
	desc = "Did we forget to hire any Heads of Staff? Recruit your own with this high value ID card \
		capable of holding advanced levels of access in a handy wallet-sized form factor."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/card/id/advanced/silver)
	crate_name = "silver id card crate"

/datum/supply_pack/service/emptycrate
	name = "Empty Crate"
	desc = "It's an empty crate, for all your storage needs."
	cost = CARGO_CRATE_VALUE * 1.4 //Net Zero Profit.
	contains = list()
	crate_name = "crate"

/datum/supply_pack/service/randomized/donkpockets
	name = "Donk Pocket Variety Crate"
	desc = "Featuring a line up of Donk Co.'s most popular pastry! Contains \
		a random assortment of Donk Pocket boxes."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/storage/box/donkpockets/donkpocketspicy,
					/obj/item/storage/box/donkpockets/donkpocketteriyaki,
					/obj/item/storage/box/donkpockets/donkpocketpizza,
					/obj/item/storage/box/donkpockets/donkpocketberry,
					/obj/item/storage/box/donkpockets/donkpockethonk,
				)
	crate_name = "donk pocket crate"

/datum/supply_pack/service/randomized/donkpockets/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 3)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/service/randomized/ready_donk
	name = "Ready-Donk Variety Crate"
	desc = "Featuring a line up of Donk Co.'s most popular pastry! Contains \
		a random assortment of Ready Donk products."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/food/ready_donk,
					/obj/item/food/ready_donk/mac_n_cheese,
					/obj/item/food/ready_donk/donkhiladas,
				)
	crate_name = "\improper Ready-Donk crate"

/datum/supply_pack/service/randomized/ready_donk/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 3)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/service/coffeekit
	name = "Coffee Equipment Crate"
	desc = "A complete kit to setup your own cozy coffee shop, the coffeemaker is for some reason not included."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/storage/box/coffeepack/robusta,
		/obj/item/storage/box/coffeepack,
		/obj/item/reagent_containers/cup/coffeepot,
		/obj/item/storage/fancy/coffee_condi_display,
		/obj/item/reagent_containers/cup/glass/bottle/juice/cream,
		/obj/item/reagent_containers/condiment/milk,
		/obj/item/reagent_containers/condiment/soymilk,
		/obj/item/reagent_containers/condiment/sugar,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel, //one extra syrup as a treat
	)
	crate_name = "coffee equipment crate"

/datum/supply_pack/service/coffeemaker
	name = "Impressa Coffeemaker Crate"
	desc = "An assembled Impressa model coffeemaker."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/machinery/coffeemaker/impressa)
	crate_name = "coffeemaker crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/aquarium_kit
	name = "Aquarium Kit"
	desc = "Everything you need to start your own aquarium. Contains aquarium construction kit, \
		fish catalog, fish food and three freshwater fish from our collection."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/book/manual/fish_catalog,
					/obj/item/storage/fish_case/random/freshwater = 3,
					/obj/item/fish_feed,
					/obj/item/storage/box/aquarium_props,
					/obj/item/aquarium_kit,
				)
	crate_name = "aquarium kit crate"
	crate_type = /obj/structure/closet/crate/wooden
