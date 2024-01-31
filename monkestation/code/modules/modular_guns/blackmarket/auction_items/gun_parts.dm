/datum/market_item/auction/gun_part
	markets = list(/datum/market/blackmarket/auction/guns)
	stock_max = 1
	availability_prob = 100
	category = "Gun Part"

/datum/market_item/auction/gun_part/mk58
	name = "MK 58 Reciever"
	desc = "An illegal mk 58 reciever for all your gun needs."
	item = /obj/item/gun/ballistic/modular/mk_58

	price_min = CARGO_CRATE_VALUE * 2.5
	price_max = CARGO_CRATE_VALUE * 5
