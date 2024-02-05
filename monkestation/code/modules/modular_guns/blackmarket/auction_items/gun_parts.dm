/datum/market_item/auction/gun_part
	markets = list(/datum/market/auction/guns)
	stock_max = 1
	availability_prob = 100
	category = "Gun Part"
	auction_weight = 5

/datum/market_item/auction/gun_part/mk58
	name = "MK 58 Reciever"
	desc = "An illegal mk 58 reciever for all your gun needs."
	item = /obj/item/gun/ballistic/modular/mk_58

	price_min = CARGO_CRATE_VALUE * 2.5
	price_max = CARGO_CRATE_VALUE * 5

/datum/market_item/auction/gun_part/cirno
	name = "MK 58 Cirno keychain"
	desc = "Cirno in keychain form"
	item = /obj/item/attachment/keychain/mk_58/cirno

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3
	auction_weight = 3

/datum/market_item/auction/gun_part/mk58_switch
	name = "MK 58 Illegal Switch"
	desc = "Super Illegal."
	item = /obj/item/attachment/underbarrel/mk_58/makeshift/illegal_switch

	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 6
	auction_weight = 1

/datum/market_item/auction/gun_part/mk58_suppressor
	name = "MK 58 Suppressor"
	desc = "Super Illegal."
	item = /obj/item/attachment/barrel/mk58/suppressor

	price_min = CARGO_CRATE_VALUE * 2.5
	price_max = CARGO_CRATE_VALUE * 7
	auction_weight = 3
