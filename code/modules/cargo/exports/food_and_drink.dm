//How I'm laying this out is in a much more painless way than giving every single food and drink it's own export datum.
//At the time of writing, we have some 200-300 food items overall, not counting custom foods. Let's not think about custom foods.
//6 Tiers to start with, working from cheapest (Available roundstart) to most expensive (Has to be made with considerable luck and preperation.)

/datum/export/food
	cost = 10 // Default cost, Because something WILL get missed somewhere. Perhaps out of active ignorance or not.
	unit_name = "serving"
	message = "of food"
	export_types = list(/obj/item/reagent_containers/food/snacks)
	include_subtypes = TRUE
	exclude_types = list(/obj/item/reagent_containers/food/snacks/grown)

/datum/export/food/get_cost(obj/O, allowed_categories, apply_elastic)
	. = ..()
	var/obj/item/reagent_containers/food/snacks/sold_food = O
	if(sold_food.silver_spawned)
		return FOOD_WORTHLESS
	return sold_food.value
