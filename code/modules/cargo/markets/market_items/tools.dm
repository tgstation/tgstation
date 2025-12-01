/datum/market_item/tool
	category = "Tools"
	abstract_path = /datum/market_item/tool

/datum/market_item/tool/blackmarket_telepad
	name = "Black Market LTSRBT"
	desc = "Need a faster and better way of transporting your illegal goods from and to the \
		station? Fear not, the Long-To-Short-Range-Bluespace-Transceiver is here to help. \
		Contains a LTSRBT circuit. Bluespace crystals and ansible not included."
	item = /obj/item/circuitboard/machine/ltsrbt
	stock_min = 2
	stock_max = 4
	price_min = CARGO_CRATE_VALUE * 2.5
	price_max = CARGO_CRATE_VALUE * 3.25
	availability_prob = 100

/datum/market_item/tool/caravan_wrench
	name = "Experimental Wrench"
	desc = "The extra fast and handy wrench you always wanted!"
	item = /obj/item/wrench/caravan
	stock = 1

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_wirecutters
	name = "Experimental Wirecutters"
	desc = "The extra fast and handy wirecutters you always wanted!"
	item = /obj/item/wirecutters/caravan
	stock = 1

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_screwdriver
	name = "Experimental Screwdriver"
	desc = "The extra fast and handy screwdriver you always wanted!"
	item = /obj/item/screwdriver/caravan
	stock = 1

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_crowbar
	name = "Experimental Crowbar"
	desc = "The extra fast and handy crowbar you always wanted!"
	item = /obj/item/crowbar/red/caravan
	stock = 1

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/binoculars
	name = "Binoculars"
	desc = "Increase your sight by 150% with this handy Tool!"
	item = /obj/item/binoculars
	stock = 1

	price_min = CARGO_CRATE_VALUE * 1.75
	price_max = CARGO_CRATE_VALUE * 4
	availability_prob = 30

/datum/market_item/tool/riot_shield
	name = "Riot Shield"
	desc = "Protect yourself from an unexpected Riot at your local Police department!"
	item = /obj/item/shield/riot

	price_min = CARGO_CRATE_VALUE * 2.25
	price_max = CARGO_CRATE_VALUE * 3.25
	stock_max = 2
	availability_prob = 50

/datum/market_item/tool/thermite_bottle
	name = "Thermite Bottle"
	desc = "50u of Thermite to assist in creating a quick access point or get away!"
	item = /obj/item/reagent_containers/cup/bottle/thermite

	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 30

/**
 * # Fake N-spect scanner black market entry
 */
/datum/market_item/tool/fake_scanner
	name = "Clowny N-spect scanner"
	desc = "This UPGRADED N-spect scanner can play FIVE HIGH-QUALITY SOUNDS (fork required for sound adjustment not included) and print reports \
	LIGHTNING FAST (screwdriver necessary to activate maximum speed not included). We make no claims as to the usefulness of the reports printed by this. \
	Any and all implied warranties are void if the device is touched, moved, kicked, thrown or modified with bananium sheets. Batteries included. \
	Crowbar necessary to change batteries and adjust settings not included."
	item = /obj/item/inspector/clown

	price_min = CARGO_CRATE_VALUE * 1.15
	price_max = CARGO_CRATE_VALUE * 1.615
	stock_max = 2
	availability_prob = 50

/datum/market_item/tool/program_disk
	name = "Bootleg Data Disk"
	desc = "A data disk containing EXCLUSIVE and LIMITED modular programs. Legally, we're not allowed to tell you how we acquired them."
	item = /obj/item/computer_disk/black_market
	price_min = CARGO_CRATE_VALUE * 0.75
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 3
	availability_prob = 40
