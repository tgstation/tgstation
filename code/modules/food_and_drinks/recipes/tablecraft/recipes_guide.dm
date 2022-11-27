// Recipes that provide crafting instructions and don't yield any result

// Food reactions

/datum/crafting_recipe/food/tofu
	name = "Tofu"
	reaction = /datum/chemical_reaction/food/tofu
	result = /obj/item/food/tofu
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/candycorn
	name = "Candy corn"
	reaction = /datum/chemical_reaction/food/candycorn
	result = /obj/item/food/candy_corn
	subcategory = CAT_PASTRY
	is_guide = TRUE

/datum/crafting_recipe/food/chocolatepudding
	name = "Chocolate pudding"
	reaction = /datum/chemical_reaction/food/chocolatepudding
	result = /datum/reagent/consumable/chocolatepudding
	subcategory = CAT_PASTRY
	is_guide = TRUE

/datum/crafting_recipe/food/vanillapudding
	name = "Vanilla  pudding"
	reaction = /datum/chemical_reaction/food/vanillapudding
	result = /datum/reagent/consumable/vanillapudding
	subcategory = CAT_PASTRY
	is_guide = TRUE

/datum/crafting_recipe/food/chocolatebar
	name = "Chocolate bar"
	reaction = /datum/chemical_reaction/food/chocolate_bar3
	result = /obj/item/food/chocolatebar
	subcategory = CAT_PASTRY
	is_guide = TRUE

/datum/crafting_recipe/food/chocolatebar/chocomilk
	name = "Chocolate bar (choco milk)"
	reaction = /datum/chemical_reaction/food/chocolate_bar2

/datum/crafting_recipe/food/chocolatebar/vegan
	name = "Chocolate bar (vegan)"
	reaction = /datum/chemical_reaction/food/chocolate_bar

/datum/crafting_recipe/food/soysauce
	name = "Soy sauce"
	reaction = /datum/chemical_reaction/food/soysauce
	result = /datum/reagent/consumable/soysauce
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/corn_syrup
	name = "Corn syrup"
	reaction = /datum/chemical_reaction/food/corn_syrup
	result = /datum/reagent/consumable/corn_syrup
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/caramel
	name = "Caramel"
	reaction = /datum/chemical_reaction/food/caramel
	result = /datum/reagent/consumable/caramel
	subcategory = CAT_PASTRY
	is_guide = TRUE

/datum/crafting_recipe/food/cheesewheel
	name = "Cheese wheel"
	reaction = /datum/chemical_reaction/food/cheesewheel
	result = /obj/item/food/cheese/wheel
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/synthmeat
	name = "Synthetic meat"
	reaction = /datum/chemical_reaction/food/synthmeat
	result = /obj/item/food/meat/slab/synthmeat
	subcategory = CAT_MEAT
	is_guide = TRUE

/datum/crafting_recipe/food/imitationcarpmeat
	name = "Carp fillet imitation"
	reaction = /datum/chemical_reaction/food/imitationcarpmeat
	result = /obj/item/food/fishmeat/carp/imitation
	subcategory = CAT_SEAFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/dough
	name = "Dough"
	reaction = /datum/chemical_reaction/food/dough
	result = /obj/item/food/dough
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/cakebatter
	name = "Cake batter"
	reaction = /datum/chemical_reaction/food/cakebatter
	result = /obj/item/food/cakebatter
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/cakebatter/vegan
	name = "Cake batter (vegan)"
	reaction = /datum/chemical_reaction/food/cakebatter/vegan

/datum/crafting_recipe/food/pancakebatter
	name = "Pancake batter"
	result = /datum/reagent/consumable/pancakebatter
	reaction = /datum/chemical_reaction/food/pancakebatter
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/ricebowl
	name = "Bowl of rice"
	result = /obj/item/food/salad/ricebowl
	reaction = /datum/chemical_reaction/food/ricebowl
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/bbqsauce
	name = "BBQ sauce"
	result = /datum/reagent/consumable/bbqsauce
	reaction = /datum/chemical_reaction/food/bbqsauce
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/gravy
	name = "Gravy"
	result = /datum/reagent/consumable/gravy
	reaction = /datum/chemical_reaction/food/gravy
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/mothic_pizza_dough
	name = "Mothic pizza dough"
	result = /obj/item/food/mothic_pizza_dough
	reaction = /datum/chemical_reaction/food/mothic_pizza_dough
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/curd_cheese
	name = "Curd cheese"
	result = /obj/item/food/cheese/curd_cheese
	reaction = /datum/chemical_reaction/food/curd_cheese
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/mozzarella
	name = "Mozzarella"
	result = /obj/item/food/cheese/mozzarella
	reaction = /datum/chemical_reaction/food/mozzarella
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/cornmeal_batter
	name = "Cornmeal batter"
	result = /datum/reagent/consumable/cornmeal_batter
	reaction = /datum/chemical_reaction/food/cornmeal_batter
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/cornbread
	name = "Corn bread"
	result = /obj/item/food/bread/corn
	reaction = /datum/chemical_reaction/food/cornbread
	subcategory = CAT_BREAD
	is_guide = TRUE

/datum/crafting_recipe/food/yoghurt
	name = "Yoghurt"
	result = /datum/reagent/consumable/yoghurt
	reaction = /datum/chemical_reaction/food/yoghurt
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/quality_oil
	name = "Quality oil"
	result = /datum/reagent/consumable/quality_oil
	reaction = /datum/chemical_reaction/food/quality_oil
	subcategory = CAT_MISCFOOD
	is_guide = TRUE

/datum/crafting_recipe/food/quality_oil/upconvert
	reaction = /datum/chemical_reaction/food/quality_oil_upconvert

// Tools

/datum/crafting_recipe/food/flatdough
	name = "Flat dough"
	reqs = list(
		/obj/item/food/dough = 1,
	)
	tool_paths = list(
		/obj/item/kitchen/rollingpin,
	)
	result = /obj/item/food/flatdough
	subcategory = CAT_BREAD
	steps = list(
		"Flatten the dough with a rolling pin"
	)
	is_guide = TRUE

/datum/crafting_recipe/food/friedegg
	name = "Fried egg"
	reqs = list(
		/obj/item/food/egg = 1,
	)
	machinery = list(
		/obj/machinery/griddle,
	)
	result = /obj/item/food/friedegg
	subcategory = CAT_EGG
	steps = list(
		"Break the egg onto a griddle",
		"Fry on the griddle until ready"
	)
	is_guide = TRUE
