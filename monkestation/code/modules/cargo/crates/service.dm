/datum/supply_pack/service/glassware
	name = "Glassware Crate"
	desc = "Printing too much trouble? Buy our bulk glassware package today!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/beakers,
					/obj/item/storage/box/drinkingglasses = 2,
					/obj/item/reagent_containers/cup/glass/shaker,
					/obj/item/reagent_containers/cup/glass/flask = 2)
	crate_name = "glassware crate"

/datum/supply_pack/service/janitor/janicart
	name = "Janicart Crate"
	desc = "You'd better not have wrecked the last one joyriding."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/vehicle/ridden/janicart,
					/obj/item/key/janitor)
	crate_name = "janicart crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/birthday
	name = "Birthday Bash Pack"
	desc = "This is for that corgi, isn't it..."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/toy/balloon = 5,
					/obj/item/reagent_containers/spray/chemsprayer/party = 3,
					/obj/item/clothing/head/costume/party = 5,
					/obj/item/food/cake/birthday,
					/obj/item/plate/small = 5,
					/obj/item/a_gift/recursive)
	crate_name = "Birthday Crate"

/datum/supply_pack/service/jukebox
	name = "Jukebox Beacon Crate"
	desc = "Last one stolen? Broken? Burnt down in an insurance scam? then this crate is for you. Contains one Jukebox Beacon."
	cost = CARGO_CRATE_VALUE * 20 //the crew shouldnt be able to just buy 15 jukeboxes all playing among us at the same time
	contains = list(/obj/item/jukebox_beacon)
	crate_name = "jukebox beacon crate"

/datum/supply_pack/service/cassettes
	name = "Bulk Cassette Crate"
	desc = "In the unlikely event all your cassettes are the same, or the likely event youve run out of songs to play, this crate is here to help you, contains 10 Approved Cassettes for use in the DJ Station."
	cost = CARGO_CRATE_VALUE * 4
	contains = list()
	crate_name = "cassette crate"

/datum/supply_pack/service/cassettes/fill(obj/structure/closet/crate/our_crate)
	for(var/id in unique_random_tapes(10))
		new /obj/item/device/cassette_tape(our_crate, id)

/datum/supply_pack/service/blankcassettes
	name = "Blank Cassettes Crate"
	desc = "in the VERY unlikely event you have run out of blank cassettes, you can get 10 blank ones here. Contains 10 blank cassettes for use in Walkmans."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/device/cassette_tape/blank = 10)
	crate_name = "cassette crate"

/datum/supply_pack/service/walkmen
	name = "Walkman Crate"
	desc = "In the EXTREMELY unlikely event you have run out of walkmans in the library, this crate has 5 walkman devices for listening to cassettes personally. Cassettes Sold Seperately."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/device/walkman = 5)
	crate_name = "walkman crate"

/datum/supply_pack/service/cassettedeck
	name = "Advanced Cassette Deck Crate"
	desc = "In the event you simply refuse to interact with the Curator at all. Contains 1 Advanced Cassette Deck and a wrench for moving it."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/machinery/cassette/adv_cassette_deck,
					/obj/item/wrench)
	crate_name = "cassette deck crate"
	crate_type = /obj/structure/closet/crate/large
