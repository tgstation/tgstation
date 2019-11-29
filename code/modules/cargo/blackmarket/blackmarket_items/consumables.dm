/datum/blackmarket_item/consumable
	category = "Consumables"

/datum/blackmarket_item/consumable/clown_tears
	name = "Bowl of Clowns Tears"
	desc = "Guaranteed fresh from Weepy Boggins Tragic Kitchen"
	item = /obj/item/reagent_containers/food/snacks/soup/clownstears
	stock = 1

	price_min = 500
	price_max = 590
	availability_prob = 10

/datum/blackmarket_item/consumable/donk_pocket_box
	name = "Box of Donk Pockets"
	desc = "A well packaged box containing the favourite snack of every spacefarer."
	item = /obj/item/storage/box/donkpockets

	stock_min = 2
	stock_max = 5
	price_min = 200
	price_max = 300
	availability_prob = 80

/datum/blackmarket_item/consumable/suspicious_pills
	name = "Bottle of Suspicious Pills"
	desc = "A random cocktail of luxury drugs that are sure to put a smile on your face!"
	item = /obj/item/storage/pill_bottle

	stock_min = 2
	stock_max = 3
	price_min = 500
	price_max = 1000
	availability_prob = 50

/datum/blackmarket_item/consumable/suspicious_pills/spawn_item(loc)
	var/pillbottle = pick(list(/obj/item/storage/pill_bottle/zoom,
				/obj/item/storage/pill_bottle/happy,
				/obj/item/storage/pill_bottle/lsd,
				/obj/item/storage/pill_bottle/aranesp,
				/obj/item/storage/pill_bottle/stimulant))
	return new pillbottle(loc)
