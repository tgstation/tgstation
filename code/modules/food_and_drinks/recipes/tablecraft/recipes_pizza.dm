
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/crafting_recipe/food/margheritapizza
	name = "Margherita pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/cheese = 4,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/margherita/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	name = "Meat pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 4,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/meat/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/arnold
	name = "Arnold pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/arnold/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	name = "Mushroom pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/mushroom = 5
	)
	result = /obj/item/food/pizza/mushroom/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	name = "Vegetable pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/vegetable/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	name = "Donkpocket pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/donkpocket = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/donkpocket/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	name = "Dank pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/dank/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	name = "Sassysage pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/raw_meatball = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/sassysage/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/pineapplepizza
	name = "Hawaiian pizza"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/pineappleslice = 3,
		/obj/item/food/cheese = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/pineapple/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/antspizza
	name = "Ant Party pizza"
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/cheese = 2,
		/obj/item/food/grown/tomato = 1,
		/datum/reagent/ants = 20
	)
	result = /obj/item/food/pizza/ants
	subcategory = CAT_PIZZA
