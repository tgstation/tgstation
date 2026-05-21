
// see code/module/crafting/table.dm

// MEXICAN

/datum/crafting_recipe/food/burrito
	name ="Burrito"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 2
	)
	result = /obj/item/food/burrito
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/cheesyburrito
	name ="Cheesy burrito"
	reqs = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/cheesyburrito
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/carneburrito
	name = "Carne de asada burrito"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/carneburrito
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/fuegoburrito
	name = "Fuego plasma burrito"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/ghost_chili = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/fuegoburrito
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/nachos
	name = "Nachos"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/nachos
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/cheesynachos
	name = "Cheesy nachos"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/cheesynachos
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/cubannachos
	name = "Cuban nachos"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/cubannachos
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/taco
	name ="Classic Taco"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/taco
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_TACO

/datum/crafting_recipe/food/tacoplain
	name ="Plain Taco"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
	)
	result = /obj/item/food/taco/plain
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_TACO

/datum/crafting_recipe/food/enchiladas
	name = "Enchiladas"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 2
	)
	result = /obj/item/food/enchiladas
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/stuffedlegion
	name = "Stuffed legion"
	time = 4 SECONDS
	reqs = list(
		/obj/item/food/meat/steak/goliath = 1,
		/obj/item/organ/monster_core/regenerative_core/legion = 1,
		/datum/reagent/consumable/ketchup = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	result = /obj/item/food/stuffedlegion
	cuisine_category = CUISINE_MEXICAN

/datum/crafting_recipe/food/chipsandsalsa
	name = "Chips and salsa"
	reqs = list(
		/obj/item/food/cornchips = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/chipsandsalsa
	removed_foodtypes = JUNKFOOD
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_CONDIMENT
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/classic_chimichanga
	name = "Classic Chimichanga"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/classic_chimichanga
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/vegetarian_chimichanga
	name = "Vegetarian Chimichanga"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
	)
	result = /obj/item/food/vegetarian_chimichanga
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_BURRITO

/datum/crafting_recipe/food/classic_hard_shell_taco
	name = "Classic Hard-Shell Taco"
	reqs = list(
		/obj/item/food/hard_taco_shell = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/classic_hard_shell_taco
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_TACO

/datum/crafting_recipe/food/plain_hard_shell_taco
	name = "Plain Hard-Shell Taco"
	reqs = list(
		/obj/item/food/hard_taco_shell = 1,
		/obj/item/food/meat/cutlet = 1,
	)
	result = /obj/item/food/plain_hard_shell_taco
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_TACO

/datum/crafting_recipe/food/refried_beans
	name = "Refried Beans"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/soybeans = 2,
		/datum/reagent/water = 5,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/refried_beans
	added_foodtypes = FRIED
	cuisine_category = CUISINE_MEXICAN

/datum/crafting_recipe/food/spanish_rice
	name = "Spanish Rice"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/tomato = 1,
		/datum/reagent/consumable/salt = 1,
		/datum/reagent/consumable/blackpepper = 1,
	)
	result = /obj/item/food/spanish_rice
	removed_foodtypes = BREAKFAST
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_RICE

/datum/crafting_recipe/food/pineapple_salsa
	name = "Pineapple salsa"
	reqs = list(
		/obj/item/food/pineappleslice = 2,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/reagent_containers/cup/bowl = 1,
	)
	result = /obj/item/food/pineapple_salsa
	cuisine_category = CUISINE_MEXICAN
	meal_category = MEAL_APPETIZER
	dish_category = DISH_CONDIMENT
