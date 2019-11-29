/datum/blackmarket_item/tool
	category = "Tools"

/datum/blackmarket_item/tool/caravan_wrench
	name = "Experimental Wrench"
	desc = "The extra fast and handy wrench you always wanted!"
	item = /obj/item/wrench/caravan
	stock = 1

	price_min = 400
	price_max = 800
	availability_prob = 20

/datum/blackmarket_item/tool/caravan_wirecutters
	name = "Experimental Wirecutters"
	desc = "The extra fast and handy wirecutters you always wanted!"
	item = /obj/item/wirecutters/caravan
	stock = 1

	price_min = 400
	price_max = 800
	availability_prob = 20

/datum/blackmarket_item/tool/caravan_screwdriver
	name = "Experimental Screwdriver"
	desc = "The extra fast and handy screwdriver you always wanted!"
	item = /obj/item/screwdriver/caravan
	stock = 1

	price_min = 400
	price_max = 800
	availability_prob = 20

/datum/blackmarket_item/tool/caravan_crowbar
	name = "Experimental Crowbar"
	desc = "The extra fast and handy crowbar you always wanted!"
	item = /obj/item/crowbar/red/caravan
	stock = 1

	price_min = 400
	price_max = 800
	availability_prob = 20

/datum/blackmarket_item/tool/binoculars
	name = "Binoculars"
	desc = "Increase your sight by 150% with this handy Tool!"
	item = /obj/item/twohanded/binoculars
	stock = 1

	price_min = 400
	price_max = 4000
	availability_prob = 30

/datum/blackmarket_item/tool/riot_shield
	name = "Riot Shield"
	desc = "Protect yourself from an unexpected Riot at your local Police department!"
	item = /obj/item/shield/riot
	
	price_min = 200
	price_max = 300
	stock_max = 2
	availability_prob = 50

/datum/blackmarket_item/tool/thermite_bottle
	name = "Thermite Bottle"
	desc = "30u of Thermite to assist in creating a quick access point or get away!"
	item = /obj/item/reagent_containers/glass/bottle

	price_min = 500
	price_max = 1500
	stock_max = 3
	availability_prob = 30

/datum/blackmarket_item/tool/thermite_bottle/spawn_item(loc)
	var/obj/item/reagent_containers/glass/bottle/B = ..()
	B.reagents.add_reagent(/datum/reagent/thermite, 30)
	return B
