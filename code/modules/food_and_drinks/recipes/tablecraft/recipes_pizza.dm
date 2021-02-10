
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/crafting_recipe/food/margheritapizza
	name = "Margherita pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/cheese = 4,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/margherita
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	name = "Meat pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 4,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/meat
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/arnold
	name = "Arnold pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/arnold
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	name = "Mushroom pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/mushroom = 5
	)
	result = /obj/item/food/pizza/mushroom
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	name = "Vegetable pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/vegetable
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	name = "Donkpocket pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/donkpocket/warm = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/donkpocket
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	name = "Dank pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/dank
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	name = "Sassysage pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meatball = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/sassysage
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/pineapplepizza
	name = "Hawaiian pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/pineappleslice = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/pineapple
	subcategory = CAT_PIZZA
