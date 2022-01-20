/datum/market_item/misc
	category = "Miscellaneous"

/datum/market_item/misc/Clear_PDA
	name = "Clear PDA"
	desc = "Show off your style with this limited edition clear PDA!."
	item = /obj/item/pda/clear

	price_min = CARGO_CRATE_VALUE * 1.25
	price_max = CARGO_CRATE_VALUE *3
	stock_max = 2
	availability_prob = 50

/datum/market_item/misc/jade_Lantern
	name = "Jade Lantern"
	desc = "Found in a box labeled 'Danger: Radioactive'. Probably safe."
	item = /obj/item/flashlight/lantern/jade

	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE * 2.5
	stock_max = 2
	availability_prob = 45

/datum/market_item/misc/cap_gun
	name = "Cap Gun"
	desc = "Prank your friends with this harmless gun! Harmlessness guranteed."
	item = /obj/item/toy/gun

	price_min = CARGO_CRATE_VALUE * 0.25
	price_max = CARGO_CRATE_VALUE
	stock_max = 6
	availability_prob = 80

/datum/market_item/misc/shoulder_holster
	name = "Shoulder holster"
	desc = "Yeehaw, hardboiled friends! This holster is the first step in your dream of becoming a detective and being allowed to shoot real guns!"
	item = /obj/item/storage/belt/holster

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 8
	availability_prob = 60

/datum/market_item/misc/holywater
	name = "Flask of holy water"
	desc = "Father Lootius' own brand of ready-made holy water."
	item = /obj/item/reagent_containers/food/drinks/bottle/holywater

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 3
	availability_prob = 40

/datum/market_item/misc/holywater/spawn_item(loc)
	if (prob(6.66))
		return new /obj/item/reagent_containers/glass/beaker/unholywater(loc)
	return ..()

/datum/market_item/misc/strange_seed
	name = "Strange Seeds"
	desc = "An Exotic Variety of seed that can contain anything from glow to acid."
	item = /obj/item/seeds/random

	price_min = CARGO_CRATE_VALUE * 1.6
	price_max = CARGO_CRATE_VALUE * 1.8
	stock_min = 2
	stock_max = 5
	availability_prob = 50

/datum/market_item/misc/smugglers_satchel
	name = "Smuggler's Satchel"
	desc = "This easily hidden satchel can become a versatile tool to anybody with the desire to keep certain items out of sight and out of mind."
	item = /obj/item/storage/backpack/satchel/flat/empty

	price_min = CARGO_CRATE_VALUE * 3.75
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 30
