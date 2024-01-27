/datum/crafting_recipe/food/raw_corndog
	name = "raw corndog on a stick"
	reqs = list(
		/obj/item/food/raw_sausage_stick = 1,
		/datum/reagent/consumable/cornmeal_batter = 10,
	)
	result = /obj/item/food/raw_corndog
	category = CAT_MEAT

/datum/crafting_recipe/food/raw_corndog_rod
	name = "raw corndog on a rod"
	reqs = list(
		/obj/item/food/raw_sausage_stick/rod = 1,
		/datum/reagent/consumable/cornmeal_batter = 10,
	)
	result = /obj/item/food/raw_corndog/rod
	category = CAT_MEAT

/datum/crafting_recipe/food/corndog
	machinery = list(/obj/machinery/oven)
	steps = list("Bake in the oven until ready")
	category = CAT_MEAT
	non_craftable = TRUE
	reqs = list(/obj/item/food/raw_corndog= 1)
	result = /obj/item/food/corndog

/datum/crafting_recipe/food/corndog/rod
	reqs = list(/obj/item/food/raw_corndog/rod = 1)
	result = /obj/item/food/corndog/rod

/datum/crafting_recipe/food/fullcondiment
	name = "corndog with toppings"
	reqs = list(
		/obj/item/food/corndog = 1,
		/datum/reagent/consumable/ketchup = 5,
	)
	result = /obj/item/food/corndog/fullcondiment
	category = CAT_MEAT

/datum/crafting_recipe/food/fullcondiment/rod
	name = "corndog with toppings... on a rod!"
	reqs = list(
		/obj/item/food/corndog/rod = 1,
		/datum/reagent/consumable/ketchup = 5,
	)
	result = /obj/item/food/corndog/fullcondiment/rod
	category = CAT_MEAT

/datum/crafting_recipe/food/NarDog
	name = "Nar'Dog"
	desc = "A demonic corndog of occult origin, it glows with an unholy power..." //overwrites default description to avoid metadata being displayed in the craft menu
	reqs = list(
	/obj/item/food/corndog = 1, //YOU'RE GOING TO USE THE POPSICLE STICK AND YOU'RE GOING TO LIKE IT!!!
	/datum/reagent/consumable/ethanol/narsour = 20,
	/datum/reagent/brimdust = 15
	)
	result = /obj/item/food/corndog/NarDog
	category = CAT_MEAT
