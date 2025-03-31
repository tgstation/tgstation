
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/crafting_recipe/food/pizza
	added_foodtypes = RAW
	category = CAT_PIZZA

/datum/crafting_recipe/food/pizza/margherita
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/cheese/wedge = 4,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/margherita/raw

/datum/crafting_recipe/food/meatpizza
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 4,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/meat/raw

/datum/crafting_recipe/food/pizza/arnold
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/arnold/raw

/datum/crafting_recipe/food/pizza/mushroom
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/mushroom = 5,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/pizza/mushroom/raw

/datum/crafting_recipe/food/pizza/vegetable
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	result = /obj/item/food/pizza/vegetable/raw

/datum/crafting_recipe/food/pizza/donkpocket
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/donkpocket = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	added_foodtypes = parent_type::added_foodtypes|JUNKFOOD
	result = /obj/item/food/pizza/donkpocket/raw

/datum/crafting_recipe/food/pizza/dank
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/dank/raw

/datum/crafting_recipe/food/pizza/sassysage
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/raw_meatball = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/sassysage/raw

/datum/crafting_recipe/food/pizza/pineapple
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/pineappleslice = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/pizza/pineapple/raw

/datum/crafting_recipe/food/pizza/ants
	reqs = list(
		/obj/item/food/pizzaslice/margherita = 1,
		/datum/reagent/ants = 4
	)
	result = /obj/item/food/pizzaslice/ants
	added_foodtypes = BUGS

/datum/crafting_recipe/food/pizza/energy
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/stock_parts/power_store/cell = 2,
	)
	result = /obj/item/food/pizza/energy/raw
	added_foodtypes = parent_type::added_foodtypes|TOXIC

/datum/crafting_recipe/food/pizza/raw_meat_calzone
	name = "Meat calzone"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/meat/rawcutlet = 3,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/raw_meat_calzone

/datum/crafting_recipe/food/pizza/raw_vegetarian_calzone
	name = "Vegetarian calzone"
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/raw_vegetarian_calzone
