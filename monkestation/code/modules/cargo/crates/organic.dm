/datum/supply_pack/organic/combomeal
	name = "Burger Combo Crate"
	desc = "We value our customers at the Greasy Griddle, so much so that we're willing to deliver -just for you.- Contains two combo meals, consisting of a Burger, Fries, and pack of chicken nuggets!"
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/food/burger/cheese,
		/obj/item/food/burger/cheese,
		/obj/item/food/fries,
		/obj/item/food/fries,
		/obj/item/storage/fancy/nugget_box,
		/obj/item/storage/fancy/nugget_box,
	)
	crate_name = "burger-n-nuggs combo meal"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/organic/fiestatortilla
	name = "Fiesta Crate"
	desc = "Spice up the kitchen with this fiesta themed food order! Contains 8 tortilla based food items and some hot-sauce."
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(
		/obj/item/food/taco,
		/obj/item/food/taco,
		/obj/item/food/taco/plain,
		/obj/item/food/taco/plain,
		/obj/item/food/enchiladas,
		/obj/item/food/enchiladas,
		/obj/item/food/carneburrito,
		/obj/item/food/cheesyburrito,
		/obj/item/reagent_containers/cup/bottle/capsaicin,
	)
	crate_name = "fiesta crate"

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
