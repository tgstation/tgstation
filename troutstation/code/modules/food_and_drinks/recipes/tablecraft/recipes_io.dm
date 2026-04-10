/datum/crafting_recipe/food/space_shuttle_jelly
	name = "Space Shuttle Jelly"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 10,
	)
	result = /obj/item/food/space_shuttle_jelly
	cuisine_category = CUISINE_IO
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/raw_dim_sim
	name = "raw dim sim"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/raw_meatball = 1,
		/obj/item/food/grown/cabbage = 1,
		/datum/reagent/consumable/salt = 2,
		/datum/reagent/consumable/blackpepper = 2,
	)
	result = /obj/item/food/raw_dim_sim
	cuisine_category = CUISINE_IO
	dish_category = DISH_BURRITO
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/microwave/dim_sim
	reqs = list(/obj/item/food/raw_dim_sim = 1)
	result = /obj/item/food/dim_sim
	removed_foodtypes = RAW
	added_foodtypes = FRIED
	cuisine_category = CUISINE_IO
	dish_category = DISH_BURRITO
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/democracy_sausage
	name = "democracy sausage"
	reqs = list(
		/obj/item/food/sausage = 1,
		/obj/item/food/onion_slice = 2,
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/breadslice/plain = 1,
	)
	result = /obj/item/food/democracy_sausage
	cuisine_category = CUISINE_IO
	dish_category = DISH_BREAD
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/lamington
	name = "lamington"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/desiccated_coconut = 2,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/lamington
	removed_foodtypes = JUNKFOOD
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/lamington_slice
	reqs = list(/obj/item/food/lamington = 1)
	result = /obj/item/food/lamington_slice
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/JC_lamington
	name = "jam and cream lamington"
	reqs = list(
		/obj/item/food/lamington = 1,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/berryjuice = 5,
	)
	result = /obj/item/food/JC_lamington
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/JC_lamington_slice
	reqs = list(/obj/item/food/JC_lamington = 1)
	result = /obj/item/food/JC_lamington_slice
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/vegemite_toast
	name = "\improper Vegemite toast"
	reqs = list(
		/datum/reagent/consumable/vegemite = 10,
		/obj/item/food/griddle_toast = 1,
	)
	result = /obj/item/food/vegemite_toast
	added_foodtypes = VEGETABLES | BREAKFAST
	cuisine_category = CUISINE_IO
	dish_category = DISH_BREAD
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/cheese_vegemite_scroll
	name = "cheese and Vegemite scroll"
	reqs = list(
		/datum/reagent/consumable/vegemite = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/cheese_vegemite_scroll
	added_foodtypes = VEGETABLES
	cuisine_category = CUISINE_IO
	dish_category = DISH_BREAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/fairy_bread
	name = "fairy bread"
	reqs = list(
		/obj/item/food/butterslice = 1,
		/datum/reagent/consumable/sprinkles = 2,
		/obj/item/food/breadslice/plain = 1,
	)
	result = /obj/item/food/fairy_bread
	added_foodtypes = SUGAR
	removed_foodtypes = JUNKFOOD
	cuisine_category = CUISINE_IO
	dish_category = DISH_BREAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/golden_gaytime
	name = "\improper Golden Gaytime"
	reqs = list(
		/obj/item/popsicle_stick = 1,
		/datum/reagent/consumable/caramel = 4,
		/datum/reagent/consumable/ice = 2,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 2,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/food/popsicle/golden_gaytime
	added_foodtypes = DAIRY
	removed_foodtypes = JUNKFOOD
	cuisine_category = CUISINE_IO
	dish_category = DISH_FROZEN
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/pie_floater
	name = "pie floater"
	reqs = list(
		/datum/reagent/consumable/nutriment/soup/pea = 30,
		/obj/item/food/pie/meatpie = 1,
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/pie_floater
	added_foodtypes = VEGETABLES
	cuisine_category = CUISINE_IO
	dish_category = DISH_PIE
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/vanilla_slice
	name = "vanilla slice"
	reqs = list(
		/datum/reagent/consumable/vanillapudding = 20,
		/obj/item/food/pastrybase = 4,
		/datum/reagent/consumable/sugar = 10,
	)
	result = /obj/item/food/vanilla_slice
	added_foodtypes = SUGAR
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/vanilla_slice_slice
	reqs = list(/obj/item/food/vanilla_slice = 1)
	result = /obj/item/food/vanilla_slice_slice
	cuisine_category = CUISINE_IO
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT
