/datum/market_item/consumable
	category = "Consumables"
	abstract_path = /datum/market_item/consumable

/datum/market_item/consumable/clown_tears
	name = "Bottle of Clown's Tears"
	desc = "Guaranteed fresh from Weepy Boggins Tragic Kitchen"
	item = /obj/item/reagent_containers/cup/bottle/clownstears
	stock = 1

	price_min = CARGO_CRATE_VALUE * 2.6
	price_max = CARGO_CRATE_VALUE * 3
	availability_prob = 10

/datum/market_item/consumable/donk_pocket_box
	name = "Box of Donk Pockets"
	desc = "A well packaged box containing the favourite snack of every spacefarer."
	item = /obj/item/storage/box/donkpockets

	stock_min = 2
	stock_max = 5
	price_min = CARGO_CRATE_VALUE * 1.375
	price_max = CARGO_CRATE_VALUE * 1.825
	availability_prob = 80

/datum/market_item/consumable/donk_pocket_box/spawn_item(loc)
	var/static/list/choices
	if(isnull(choices))
		choices = list()
		for(var/boxtype in typesof(/obj/item/storage/box/donkpockets))
			choices[boxtype] = 3
		choices[/obj/item/storage/box/donkpockets/donkpocketgondola] = 1
	item = pick_weight(choices)
	return ..()

/datum/market_item/consumable/suspicious_pills
	name = "Bottle of Suspicious Pills"
	desc = "A random cocktail of luxury drugs that are sure to put a smile on your face!"
	item = /obj/item/storage/pill_bottle

	stock_min = 2
	stock_max = 3
	price_min = CARGO_CRATE_VALUE * 0.625
	price_max = CARGO_CRATE_VALUE * 1.25
	availability_prob = 50

/datum/market_item/consumable/suspicious_pills/spawn_item(loc)
	item = pick(list(/obj/item/storage/pill_bottle/zoom,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/aranesp,
		/obj/item/storage/pill_bottle/stimulant,
		/obj/item/storage/pill_bottle/maintenance_pill,
	))
	return ..()

/datum/market_item/consumable/floor_pill
	name = "Strange Pill"
	desc = "The Russian Roulette of the Maintenance Tunnels."
	item = /obj/item/reagent_containers/applicator/pill/maintenance

	stock_min = 5
	stock_max = 35
	price_min = CARGO_CRATE_VALUE * 0.05
	price_max = CARGO_CRATE_VALUE * 0.3
	availability_prob = 50

/datum/market_item/consumable/pumpup
	name = "Maintenance Pump-Up"
	desc = "Resist any Baton stun with this handy device!"
	item = /obj/item/reagent_containers/hypospray/medipen/pumpup

	stock_max = 3
	price_min = CARGO_CRATE_VALUE * 0.25
	price_max = CARGO_CRATE_VALUE * 0.75
	availability_prob = 90

/datum/market_item/consumable/methshipment
	name = "Wholesale Methaphemtamine Shipment"
	desc = "Dealer quantity! Don't get high on your own supply. Or do. You already bought it."
	item = /obj/item/storage/box/methdealer

	stock_min = 1
	stock_max = 3
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 1.5
	availability_prob = 25

/datum/market_item/consumable/opiumshipment
	name = "Wholesale Opium Shipment"
	desc = "Are your coworkers stressed? We've got vice in bulk."
	item = /obj/item/storage/box/opiumdealer

	stock_min = 1
	stock_max = 3
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 1.2
	availability_prob = 35

/datum/market_item/consumable/kronkshipment
	name = "Wholesale Kronkaine Shipment"
	desc = "Warning! Security might actually care about this one!"
	item = /obj/item/storage/box/kronkdealer

	stock_min = 1
	stock_max = 3
	price_min = CARGO_CRATE_VALUE * 1
	price_max = CARGO_CRATE_VALUE * 2
	availability_prob = 15

/datum/market_item/consumable/methaphetamine
	name = "Crystal Meth"
	desc = "A big rock, for when you just need a hit."
	item = /obj/item/food/drug/meth_crystal

	stock_min = 1
	stock_max = 5
	price_min = CARGO_CRATE_VALUE * 0.4
	price_max = CARGO_CRATE_VALUE * 0.5
	availability_prob = 35

/datum/market_item/consumable/heroin
	name = "Heroin"
	desc = "Chase the dragon."
	item = /obj/item/food/drug/opium

	stock_min = 1
	stock_max = 5
	price_min = CARGO_CRATE_VALUE * 0.35
	price_max = CARGO_CRATE_VALUE * 0.5
	availability_prob = 45

/datum/market_item/consumable/kronkaine
	name = "Kronkaine"
	desc = "An 8⁸ ball, this is hardly ever on the market!"
	item = /obj/item/food/drug/moon_rock

	stock_min = 1
	stock_max = 2
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 1
	availability_prob = 15
