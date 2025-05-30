/obj/item/food/float_your_goat
	name = "\improper Float Your Goat"
	desc = "This looks fucking foul, but I guess someone will eat it. Drink it? Your call, man."
	icon = 'troutstation/icons/obj/food/io_foods.dmi'
	icon_state = "float_your_goat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/ketchup = 3,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/milk = 4,
	)
	bite_consumption = 5
	tastes = list("milk" = 4, "bun" = 3, "meat" = 2, "fried onion" = 1, "bell pepper" = 1, "onion" = 1, "tomato" = 1)
	foodtypes = MEAT|VEGETABLES|GRAIN|DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5
	venue_value = FOOD_PRICE_EXOTIC
	trash_type = /obj/item/reagent_containers/cup/glass/drinkingglass
	food_flags = FOOD_TINY_SNOUT_EDIBLE
