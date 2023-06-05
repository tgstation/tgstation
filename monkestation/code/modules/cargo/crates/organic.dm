/datum/supply_pack/organic/foodseeds
	name = "Pampered Pantry Seed Selection"
	desc = "For when your chef has exotic tastes"
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/wheat/meat,
					/obj/item/seeds/chili/ghost,
					/obj/item/seeds/banana/mime,
					/obj/item/seeds/cocoapod/vanillapod,
					/obj/item/seeds/korta_nut/sweet,
					/obj/item/seeds/cherry/blue,
					/obj/item/seeds/pumpkin/blumpkin,
					/obj/item/seeds/grape/green,
					/obj/item/seeds/onion/red,
					/obj/item/seeds/potato/sweet,
					)
	crate_name = "Pampered Pantry Seed Selection"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/baker
	name = "Beginners Bakery"
	desc = "Based? Based on what?"
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/food/pastrybase = 20)

/datum/supply_pack/organic/bowlcrate
	name = "Souper Salad Crate"
	desc = "Twenty bowls and a ladle, for when you can dish it out and they can take it."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/reagent_containers/cup/bowl = 20,
					/obj/item/kitchen/spoon/soup_ladle
	)
	crate_name = "Bulk bowls Crate"
